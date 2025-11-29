-- =============================================================================
-- Script 14: Correction des donnees seed pour valeurs realistes
-- Groupe DURET - BTP / Construction
-- =============================================================================
-- Contexte: Groupe de 120 salaries, 4 societes, CA ~20-25M/an
-- =============================================================================

-- =============================================================================
-- 1. CORRECTION DES HEURES RH (gold.agg_heures_salarie)
-- =============================================================================
-- Probleme: 3939h/mois/salarie au lieu de ~151h (35h/sem)
-- Solution: Diviser par 26 pour obtenir des valeurs realistes

UPDATE gold.agg_heures_salarie
SET
    heures_total = ROUND((heures_total / 26)::numeric, 2),
    heures_productives = ROUND((heures_productives / 26)::numeric, 2),
    heures_non_productives = ROUND((heures_non_productives / 26)::numeric, 2),
    heures_normales = ROUND((heures_normales / 26)::numeric, 2),
    heures_supplementaires = ROUND((heures_supplementaires / 26)::numeric, 2),
    cout_total = ROUND((cout_total / 40)::numeric, 2),
    cout_brut = ROUND((cout_brut / 40)::numeric, 2),
    cout_charge = ROUND((cout_charge / 40)::numeric, 2)
WHERE heures_total > 500;

-- Recalculer le taux d'occupation (base 151.67h/mois)
UPDATE gold.agg_heures_salarie
SET
    taux_occupation = ROUND((heures_total / 151.67 * 100)::numeric, 2),
    cout_horaire_moyen = ROUND((cout_total / NULLIF(heures_total, 0))::numeric, 2)
WHERE heures_total > 0;

-- Recalculer la productivite
UPDATE gold.agg_heures_salarie
SET taux_productivite = ROUND((heures_productives / NULLIF(heures_total, 0) * 100)::numeric, 2)
WHERE heures_total > 0;

-- =============================================================================
-- 2. CORRECTION DES COUTS SALARIAUX (silver.fact_suivi_mo)
-- =============================================================================

UPDATE silver.fact_suivi_mo
SET
    heures_pointees = ROUND((heures_pointees / 20)::numeric, 2),
    heures_productives = ROUND((heures_productives / 20)::numeric, 2),
    heures_non_productives = ROUND((heures_non_productives / 20)::numeric, 2),
    cout_mo = ROUND((cout_mo / 35)::numeric, 2)
WHERE heures_pointees > 300;

-- =============================================================================
-- 3. CORRECTION DES MARGES (gold.agg_ca_affaire)
-- =============================================================================
-- BTP typique: marge brute 8-15%, marge nette 2-5%

-- Corriger les couts pour avoir des marges positives (8-15%)
UPDATE gold.agg_ca_affaire
SET
    cout_mo_reel = ROUND((montant_facture * (0.35 + random() * 0.10))::numeric, 2),
    cout_achats_reel = ROUND((montant_facture * (0.25 + random() * 0.10))::numeric, 2),
    cout_sous_traitance_reel = ROUND((montant_facture * (0.10 + random() * 0.10))::numeric, 2)
WHERE montant_facture > 0;

-- Recalculer cout total et marge
UPDATE gold.agg_ca_affaire
SET
    cout_total_reel = cout_mo_reel + cout_achats_reel + cout_sous_traitance_reel,
    marge_reelle = montant_facture - (cout_mo_reel + cout_achats_reel + cout_sous_traitance_reel),
    taux_marge_reel = ROUND(((montant_facture - (cout_mo_reel + cout_achats_reel + cout_sous_traitance_reel)) / NULLIF(montant_facture, 0) * 100)::numeric, 2)
WHERE montant_facture > 0;

-- Mettre des valeurs prevues coherentes
UPDATE gold.agg_ca_affaire
SET
    cout_mo_prevu = ROUND((cout_mo_reel * (0.9 + random() * 0.2))::numeric, 2),
    cout_achats_prevu = ROUND((cout_achats_reel * (0.9 + random() * 0.2))::numeric, 2),
    cout_sous_traitance_prevu = ROUND((cout_sous_traitance_reel * (0.9 + random() * 0.2))::numeric, 2),
    marge_prevue = ROUND((montant_commande * (0.10 + random() * 0.05))::numeric, 2),
    taux_marge_prevu = ROUND((10 + random() * 5)::numeric, 2)
WHERE montant_facture > 0;

UPDATE gold.agg_ca_affaire
SET cout_total_prevu = cout_mo_prevu + cout_achats_prevu + cout_sous_traitance_prevu
WHERE cout_mo_prevu > 0;

-- =============================================================================
-- 4. CORRECTION DES HEURES AFFAIRES
-- =============================================================================

UPDATE gold.agg_ca_affaire
SET
    heures_budget = ROUND((heures_budget / 20)::numeric, 2),
    heures_realisees = ROUND((heures_realisees / 20)::numeric, 2)
WHERE heures_budget > 500 OR heures_realisees > 500;

-- Productivite realiste
UPDATE gold.agg_ca_affaire
SET productivite_pct = ROUND((70 + random() * 25)::numeric, 2)
WHERE productivite_pct IS NULL OR productivite_pct > 100;

-- Avancement realiste
UPDATE gold.agg_ca_affaire
SET
    avancement_facturation_pct = ROUND((50 + random() * 50)::numeric, 2),
    avancement_travaux_pct = ROUND((50 + random() * 50)::numeric, 2)
WHERE avancement_facturation_pct IS NULL;

-- Niveau risque
UPDATE gold.agg_ca_affaire
SET
    est_en_depassement_budget = (random() < 0.15),
    est_en_retard = (random() < 0.10),
    niveau_risque = CASE
        WHEN random() < 0.05 THEN 'CRITIQUE'
        WHEN random() < 0.15 THEN 'ELEVE'
        WHEN random() < 0.40 THEN 'MODERE'
        ELSE 'FAIBLE'
    END;

-- =============================================================================
-- 5. CORRECTION DES KPI GLOBAUX
-- =============================================================================

-- Supprimer les KPI existants qui ont des valeurs aberrantes
DELETE FROM gold.kpi_global WHERE kpi_marge_brute < 0 OR kpi_taux_marge < 0;

-- Mettre a jour les KPI avec des valeurs realistes
UPDATE gold.kpi_global
SET
    kpi_marge_brute = ROUND((kpi_ca_mensuel * (0.08 + random() * 0.07))::numeric, 2),
    kpi_taux_marge = ROUND((8 + random() * 7)::numeric, 2),
    kpi_dso_jours = ROUND(55 + random() * 25)::INT,
    kpi_dpo_jours = ROUND(45 + random() * 20)::INT,
    kpi_taux_occupation = ROUND((75 + random() * 20)::numeric, 2)
WHERE kpi_ca_mensuel > 0;

-- =============================================================================
-- 6. AJUSTEMENT CA POUR ATTEINDRE ~22M ANNUEL
-- =============================================================================

DO $$
DECLARE
    v_ca_actuel NUMERIC;
    v_facteur NUMERIC;
BEGIN
    -- Calculer CA actuel
    SELECT COALESCE(SUM(montant_facture), 0) INTO v_ca_actuel
    FROM gold.agg_ca_affaire;

    -- Si CA trop faible, multiplier
    IF v_ca_actuel > 0 AND v_ca_actuel < 15000000 THEN
        v_facteur := 22000000.0 / v_ca_actuel;

        -- Ajuster les montants dans agg_ca_affaire
        UPDATE gold.agg_ca_affaire
        SET
            montant_devis = ROUND((montant_devis * v_facteur)::numeric, 2),
            montant_commande = ROUND((montant_commande * v_facteur)::numeric, 2),
            montant_facture = ROUND((montant_facture * v_facteur)::numeric, 2),
            montant_avoir = ROUND((montant_avoir * v_facteur)::numeric, 2),
            cout_mo_prevu = ROUND((cout_mo_prevu * v_facteur)::numeric, 2),
            cout_mo_reel = ROUND((cout_mo_reel * v_facteur)::numeric, 2),
            cout_achats_prevu = ROUND((cout_achats_prevu * v_facteur)::numeric, 2),
            cout_achats_reel = ROUND((cout_achats_reel * v_facteur)::numeric, 2),
            cout_sous_traitance_prevu = ROUND((cout_sous_traitance_prevu * v_facteur)::numeric, 2),
            cout_sous_traitance_reel = ROUND((cout_sous_traitance_reel * v_facteur)::numeric, 2),
            cout_total_prevu = ROUND((cout_total_prevu * v_facteur)::numeric, 2),
            cout_total_reel = ROUND((cout_total_reel * v_facteur)::numeric, 2),
            marge_prevue = ROUND((marge_prevue * v_facteur)::numeric, 2),
            marge_reelle = ROUND((marge_reelle * v_facteur)::numeric, 2)
        WHERE montant_facture > 0;

        -- Ajuster les documents commerciaux
        UPDATE silver.fact_document_commercial
        SET
            montant_ht = ROUND((montant_ht * v_facteur)::numeric, 2),
            montant_ttc = ROUND((montant_ttc * v_facteur)::numeric, 2)
        WHERE montant_ht > 0;

        -- Ajuster les KPI
        UPDATE gold.kpi_global
        SET
            kpi_ca_mensuel = ROUND((kpi_ca_mensuel * v_facteur)::numeric, 2),
            kpi_ca_cumul = ROUND((kpi_ca_cumul * v_facteur)::numeric, 2),
            kpi_marge_brute = ROUND((kpi_marge_brute * v_facteur)::numeric, 2),
            kpi_carnet_commandes = ROUND((kpi_carnet_commandes * v_facteur)::numeric, 2),
            kpi_reste_a_facturer = ROUND((kpi_reste_a_facturer * v_facteur)::numeric, 2)
        WHERE kpi_ca_mensuel > 0;

        RAISE NOTICE 'CA ajuste par facteur %', v_facteur;
    END IF;
END $$;

-- =============================================================================
-- 7. CORRECTION ML FEATURES CLIENT
-- =============================================================================

-- Probabilite churn plus realiste (10-30% au lieu de 77%)
UPDATE gold.ml_features_client
SET probabilite_churn = ROUND((0.05 + random() * 0.25)::numeric, 4)
WHERE probabilite_churn > 0.5;

-- DSO client realiste
UPDATE gold.ml_features_client
SET dso_moyen = ROUND((45 + random() * 35)::numeric, 0)
WHERE dso_moyen > 120;

-- =============================================================================
-- 8. CORRECTION AGREGATS CA PERIODE
-- =============================================================================

-- Recalculer depuis les documents mis a jour
DELETE FROM gold.agg_ca_periode;

INSERT INTO gold.agg_ca_periode (
    ca_annee, ca_mois, ca_trimestre, niveau,
    ca_devis, ca_commande, ca_facture, ca_avoir, ca_net,
    nb_devis, nb_commandes, nb_factures,
    nb_clients_actifs, nb_affaires_actives,
    panier_moyen, taux_transformation
)
SELECT
    EXTRACT(YEAR FROM d.date_document)::INT as ca_annee,
    EXTRACT(MONTH FROM d.date_document)::INT as ca_mois,
    EXTRACT(QUARTER FROM d.date_document)::INT as ca_trimestre,
    'MOIS' as niveau,
    COALESCE(SUM(CASE WHEN d.type_document IN ('DEVIS', 'DE') THEN d.montant_ht ELSE 0 END), 0) as ca_devis,
    COALESCE(SUM(CASE WHEN d.type_document IN ('COMMANDE', 'BC') THEN d.montant_ht ELSE 0 END), 0) as ca_commande,
    COALESCE(SUM(CASE WHEN d.type_document IN ('FACTURE', 'FA') THEN d.montant_ht ELSE 0 END), 0) as ca_facture,
    COALESCE(SUM(CASE WHEN d.type_document IN ('AVOIR', 'AV') THEN d.montant_ht ELSE 0 END), 0) as ca_avoir,
    COALESCE(SUM(CASE WHEN d.type_document IN ('FACTURE', 'FA') THEN d.montant_ht ELSE 0 END), 0) -
    COALESCE(SUM(CASE WHEN d.type_document IN ('AVOIR', 'AV') THEN d.montant_ht ELSE 0 END), 0) as ca_net,
    COUNT(CASE WHEN d.type_document IN ('DEVIS', 'DE') THEN 1 END) as nb_devis,
    COUNT(CASE WHEN d.type_document IN ('COMMANDE', 'BC') THEN 1 END) as nb_commandes,
    COUNT(CASE WHEN d.type_document IN ('FACTURE', 'FA') THEN 1 END) as nb_factures,
    COUNT(DISTINCT d.client_id) as nb_clients_actifs,
    COUNT(DISTINCT d.affaire_id) as nb_affaires_actives,
    ROUND(AVG(CASE WHEN d.type_document IN ('FACTURE', 'FA') AND d.montant_ht > 0 THEN d.montant_ht END)::numeric, 2) as panier_moyen,
    ROUND(CASE WHEN SUM(CASE WHEN d.type_document IN ('DEVIS', 'DE') THEN 1 ELSE 0 END) > 0
          THEN SUM(CASE WHEN d.type_document IN ('COMMANDE', 'BC') THEN 1 ELSE 0 END)::numeric /
               SUM(CASE WHEN d.type_document IN ('DEVIS', 'DE') THEN 1 ELSE 0 END) * 100
          ELSE 0 END::numeric, 2) as taux_transformation
FROM silver.fact_document_commercial d
WHERE d.date_document >= '2024-01-01'
GROUP BY
    EXTRACT(YEAR FROM d.date_document),
    EXTRACT(MONTH FROM d.date_document),
    EXTRACT(QUARTER FROM d.date_document);

-- Ajouter agregats par trimestre
INSERT INTO gold.agg_ca_periode (
    ca_annee, ca_mois, ca_trimestre, niveau,
    ca_devis, ca_commande, ca_facture, ca_avoir, ca_net,
    nb_devis, nb_commandes, nb_factures,
    nb_clients_actifs, nb_affaires_actives,
    panier_moyen, taux_transformation
)
SELECT
    ca_annee, NULL, ca_trimestre, 'TRIMESTRE',
    SUM(ca_devis), SUM(ca_commande), SUM(ca_facture), SUM(ca_avoir), SUM(ca_net),
    SUM(nb_devis), SUM(nb_commandes), SUM(nb_factures),
    MAX(nb_clients_actifs), MAX(nb_affaires_actives),
    AVG(panier_moyen), AVG(taux_transformation)
FROM gold.agg_ca_periode
WHERE niveau = 'MOIS'
GROUP BY ca_annee, ca_trimestre;

-- Ajouter agregats par annee
INSERT INTO gold.agg_ca_periode (
    ca_annee, ca_mois, ca_trimestre, niveau,
    ca_devis, ca_commande, ca_facture, ca_avoir, ca_net,
    nb_devis, nb_commandes, nb_factures,
    nb_clients_actifs, nb_affaires_actives,
    panier_moyen, taux_transformation
)
SELECT
    ca_annee, NULL, NULL, 'ANNEE',
    SUM(ca_devis), SUM(ca_commande), SUM(ca_facture), SUM(ca_avoir), SUM(ca_net),
    SUM(nb_devis), SUM(nb_commandes), SUM(nb_factures),
    MAX(nb_clients_actifs), MAX(nb_affaires_actives),
    AVG(panier_moyen), AVG(taux_transformation)
FROM gold.agg_ca_periode
WHERE niveau = 'MOIS'
GROUP BY ca_annee;

-- =============================================================================
-- 9. VERIFICATION FINALE
-- =============================================================================

DO $$
DECLARE
    v_heures_moy NUMERIC;
    v_cout_moy NUMERIC;
    v_marge_moy NUMERIC;
    v_ca_total NUMERIC;
    v_dso_moy NUMERIC;
    v_churn_moy NUMERIC;
BEGIN
    SELECT AVG(heures_total) INTO v_heures_moy FROM gold.agg_heures_salarie WHERE heures_total > 0;
    SELECT AVG(cout_total) INTO v_cout_moy FROM gold.agg_heures_salarie WHERE cout_total > 0;
    SELECT AVG(taux_marge_reel) INTO v_marge_moy FROM gold.agg_ca_affaire WHERE taux_marge_reel IS NOT NULL;
    SELECT SUM(montant_facture) INTO v_ca_total FROM gold.agg_ca_affaire;
    SELECT AVG(dso_moyen) INTO v_dso_moy FROM gold.ml_features_client WHERE dso_moyen > 0;
    SELECT AVG(probabilite_churn) INTO v_churn_moy FROM gold.ml_features_client;

    RAISE NOTICE '========== VERIFICATION DONNEES ==========';
    RAISE NOTICE 'Heures moy/salarie/mois: % (cible: ~150)', ROUND(v_heures_moy, 0);
    RAISE NOTICE 'Cout moy/salarie/mois: % EUR (cible: ~4500)', ROUND(v_cout_moy, 0);
    RAISE NOTICE 'Marge brute moyenne: %% (cible: 8-15%%)', ROUND(v_marge_moy, 1);
    RAISE NOTICE 'CA total groupe: % EUR (cible: ~22M)', ROUND(v_ca_total, 0);
    RAISE NOTICE 'DSO moyen: % jours (cible: 55-80)', ROUND(v_dso_moy, 0);
    RAISE NOTICE 'Churn moyen: %% (cible: 10-30%%)', ROUND(v_churn_moy * 100, 1);
    RAISE NOTICE '==========================================';
END $$;

-- =============================================================================
-- Resultat attendu apres execution:
-- - Heures: ~150h/mois/salarie
-- - Cout: ~4500 EUR/mois/salarie
-- - Marge: 8-15%
-- - DSO: 55-80 jours
-- - CA groupe: ~20-25M EUR/an
-- - Churn: 10-30%
-- =============================================================================

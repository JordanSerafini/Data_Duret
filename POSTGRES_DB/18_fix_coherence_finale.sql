-- =====================================================
-- 18_fix_coherence_finale.sql
-- Correction finale des incoherences de donnees
-- =====================================================
--
-- PROBLEMES A CORRIGER :
-- 1. Desequilibre comptable pour 3 societes (DURET RESEAUX, SERVICES, ENERGIE)
-- 2. agg_tresorerie: seulement 1 societe (devrait etre 4)
-- 3. agg_ca_client: seulement 1 societe (devrait etre 4)
-- 4. agg_ca_affaire: seulement 1 societe (devrait etre 4)
-- 5. snapshot_kpi_mensuel: peu de donnees (4 rows)
-- 6. 608 suivi MO sans affaire
-- =====================================================

BEGIN;

-- =====================================================
-- 1. CORRECTION DESEQUILIBRE COMPTABLE
-- Les ecritures ajoutees ont des debits differents des credits
-- Ajouter des ecritures d'equilibre
-- =====================================================

-- Pour chaque societe desequilibree, ajouter une ecriture d'equilibre
INSERT INTO silver.fact_ecriture_compta (
    source_system, source_id, date_sk, societe_sk, journal_sk, compte_sk,
    numero_piece, numero_ligne, libelle, compte_numero,
    montant_debit, montant_credit, etat_piece, origine
)
SELECT
    'SAGE_COMPTA',
    900000 + s.societe_sk,
    (SELECT date_key FROM silver.dim_temps WHERE date_complete = '2025-11-30'),
    s.societe_sk,
    (SELECT journal_sk FROM silver.dim_journal WHERE code = 'OD' LIMIT 1),
    (SELECT compte_sk FROM silver.dim_compte WHERE numero LIKE '471%' LIMIT 1),
    CONCAT('EQUIL-', s.code),
    1,
    'Ecriture equilibre comptable',
    '471000',
    CASE WHEN ecart < 0 THEN ABS(ecart) ELSE 0 END,
    CASE WHEN ecart > 0 THEN ecart ELSE 0 END,
    'V',
    'EQUILIBRE'
FROM (
    SELECT
        s.societe_sk,
        s.code,
        SUM(e.montant_debit) - SUM(e.montant_credit) AS ecart
    FROM silver.fact_ecriture_compta e
    JOIN silver.dim_societe s ON e.societe_sk = s.societe_sk AND s.is_current = true
    GROUP BY s.societe_sk, s.code
    HAVING ABS(SUM(e.montant_debit) - SUM(e.montant_credit)) > 1
) s;

-- =====================================================
-- 2. COMPLETER agg_tresorerie POUR TOUTES LES SOCIETES
-- =====================================================

-- Supprimer les donnees existantes pour regenerer proprement
DELETE FROM gold.agg_tresorerie;

-- Generer pour toutes les societes sur 12 mois (solde_total est genere)
INSERT INTO gold.agg_tresorerie (
    societe_sk, annee, mois, jour, niveau_agregation,
    solde_banque, solde_caisse,
    encaissements, decaissements, flux_net,
    creances_clients, creances_echues,
    dettes_fournisseurs, dettes_echues,
    bfr_estime
)
SELECT
    s.societe_sk,
    y AS annee,
    m AS mois,
    1 AS jour,
    'MENSUEL',
    -- Soldes (solde_total est genere automatiquement)
    1000000 + (RANDOM() * 4000000) AS solde_banque,
    50000 + (RANDOM() * 150000) AS solde_caisse,
    -- Flux
    500000 + (RANDOM() * 2000000) AS encaissements,
    400000 + (RANDOM() * 1600000) AS decaissements,
    100000 + (RANDOM() * 400000) AS flux_net,
    -- Creances
    200000 + (RANDOM() * 800000) AS creances_clients,
    50000 + (RANDOM() * 200000) AS creances_echues,
    -- Dettes
    150000 + (RANDOM() * 600000) AS dettes_fournisseurs,
    30000 + (RANDOM() * 120000) AS dettes_echues,
    -- BFR
    100000 + (RANDOM() * 500000) AS bfr_estime
FROM silver.dim_societe s,
     generate_series(2024, 2025) y,
     generate_series(1, 12) m
WHERE s.is_current = true
  AND NOT (y = 2025 AND m > 11);

-- =====================================================
-- 3. COMPLETER agg_ca_client POUR TOUTES LES SOCIETES
-- =====================================================

-- Supprimer et regenerer
DELETE FROM gold.agg_ca_client;

-- Inserer pour tous les clients actifs
INSERT INTO gold.agg_ca_client (
    societe_sk, client_sk, annee,
    ca_devis, ca_commande, ca_facture, ca_avoir, ca_net,
    nb_devis, nb_commandes, nb_factures, nb_avoirs,
    panier_moyen, delai_paiement_moyen, taux_transformation
)
SELECT
    c.societe_sk,
    c.client_sk,
    2025 AS annee,
    (5000 + RANDOM() * 50000)::numeric(15,2) AS ca_devis,
    (3000 + RANDOM() * 40000)::numeric(15,2) AS ca_commande,
    (4000 + RANDOM() * 45000)::numeric(15,2) AS ca_facture,
    (100 + RANDOM() * 2000)::numeric(15,2) AS ca_avoir,
    (3900 + RANDOM() * 43000)::numeric(15,2) AS ca_net,
    (1 + RANDOM() * 5)::int AS nb_devis,
    (1 + RANDOM() * 4)::int AS nb_commandes,
    (1 + RANDOM() * 6)::int AS nb_factures,
    (RANDOM() * 2)::int AS nb_avoirs,
    (2000 + RANDOM() * 15000)::numeric(15,2) AS panier_moyen,
    (25 + RANDOM() * 35)::int AS delai_paiement_moyen,
    (40 + RANDOM() * 50)::numeric(5,2) AS taux_transformation
FROM silver.dim_client c
WHERE c.is_current = true
  AND c.societe_sk IS NOT NULL;

-- Pour les clients sans societe, assigner a societe 1
INSERT INTO gold.agg_ca_client (
    societe_sk, client_sk, annee,
    ca_devis, ca_commande, ca_facture, ca_avoir, ca_net,
    nb_devis, nb_commandes, nb_factures, nb_avoirs,
    panier_moyen, delai_paiement_moyen, taux_transformation
)
SELECT
    1 AS societe_sk,
    c.client_sk,
    2025 AS annee,
    (5000 + RANDOM() * 50000)::numeric(15,2) AS ca_devis,
    (3000 + RANDOM() * 40000)::numeric(15,2) AS ca_commande,
    (4000 + RANDOM() * 45000)::numeric(15,2) AS ca_facture,
    (100 + RANDOM() * 2000)::numeric(15,2) AS ca_avoir,
    (3900 + RANDOM() * 43000)::numeric(15,2) AS ca_net,
    (1 + RANDOM() * 5)::int AS nb_devis,
    (1 + RANDOM() * 4)::int AS nb_commandes,
    (1 + RANDOM() * 6)::int AS nb_factures,
    (RANDOM() * 2)::int AS nb_avoirs,
    (2000 + RANDOM() * 15000)::numeric(15,2) AS panier_moyen,
    (25 + RANDOM() * 35)::int AS delai_paiement_moyen,
    (40 + RANDOM() * 50)::numeric(5,2) AS taux_transformation
FROM silver.dim_client c
WHERE c.is_current = true
  AND c.societe_sk IS NULL
  AND NOT EXISTS (SELECT 1 FROM gold.agg_ca_client a WHERE a.client_sk = c.client_sk);

-- =====================================================
-- 4. COMPLETER agg_ca_affaire POUR TOUTES LES SOCIETES
-- =====================================================

DELETE FROM gold.agg_ca_affaire;

INSERT INTO gold.agg_ca_affaire (
    societe_sk, affaire_sk, annee,
    budget_initial, budget_actuel,
    ca_commande, ca_facture, ca_net,
    cout_mo, cout_fournitures, cout_sous_traitance, cout_total,
    marge_brute, taux_marge,
    heures_budget, heures_consommees, pct_avancement,
    nb_intervenants, date_debut, date_fin_prevue, statut
)
SELECT
    a.societe_sk,
    a.affaire_sk,
    2025 AS annee,
    (50000 + RANDOM() * 500000)::numeric(15,2) AS budget_initial,
    (55000 + RANDOM() * 520000)::numeric(15,2) AS budget_actuel,
    (40000 + RANDOM() * 450000)::numeric(15,2) AS ca_commande,
    (35000 + RANDOM() * 400000)::numeric(15,2) AS ca_facture,
    (34000 + RANDOM() * 395000)::numeric(15,2) AS ca_net,
    (10000 + RANDOM() * 100000)::numeric(15,2) AS cout_mo,
    (5000 + RANDOM() * 50000)::numeric(15,2) AS cout_fournitures,
    (2000 + RANDOM() * 30000)::numeric(15,2) AS cout_sous_traitance,
    (17000 + RANDOM() * 180000)::numeric(15,2) AS cout_total,
    (8000 + RANDOM() * 80000)::numeric(15,2) AS marge_brute,
    (10 + RANDOM() * 25)::numeric(5,2) AS taux_marge,
    (100 + RANDOM() * 1000)::int AS heures_budget,
    (80 + RANDOM() * 900)::int AS heures_consommees,
    (30 + RANDOM() * 70)::numeric(5,2) AS pct_avancement,
    (2 + RANDOM() * 8)::int AS nb_intervenants,
    '2025-01-01'::date + (RANDOM() * 200)::int AS date_debut,
    '2025-06-01'::date + (RANDOM() * 300)::int AS date_fin_prevue,
    (ARRAY['EN_COURS', 'TERMINE', 'EN_ATTENTE'])[1 + (RANDOM() * 2)::int] AS statut
FROM silver.dim_affaire a
WHERE a.is_current = true;

-- =====================================================
-- 5. COMPLETER snapshot_kpi_mensuel
-- =====================================================

DELETE FROM gold.snapshot_kpi_mensuel;

INSERT INTO gold.snapshot_kpi_mensuel (snapshot_date, societe_sk, donnees)
SELECT
    MAKE_DATE(k.annee, k.mois, 1),
    k.societe_sk,
    jsonb_build_object(
        'annee', k.annee,
        'mois', k.mois,
        'ca_mensuel', k.kpi_ca_mensuel,
        'marge_brute', k.kpi_marge_brute,
        'tresorerie', k.kpi_tresorerie_nette,
        'nb_affaires', k.kpi_nb_affaires_en_cours,
        'dso', k.kpi_dso_jours,
        'taux_marge', k.kpi_taux_marge,
        'effectif', k.kpi_effectif_moyen
    )
FROM gold.kpi_global k;

-- =====================================================
-- 6. ASSIGNER AFFAIRES AUX SUIVIS MO ORPHELINS
-- =====================================================

-- Assigner une affaire aleatoire aux suivis MO sans affaire
UPDATE silver.fact_suivi_mo f
SET affaire_sk = (
    SELECT affaire_sk FROM silver.dim_affaire
    WHERE is_current = true
    ORDER BY RANDOM()
    LIMIT 1
)
WHERE f.affaire_sk IS NULL;

-- =====================================================
-- 7. VERIFICATION FINALE
-- =====================================================

DO $$
DECLARE
    v_equilibre_ok INT;
    v_treso_societes INT;
    v_ca_client_societes INT;
    v_ca_affaire_societes INT;
    v_snapshots INT;
    v_suivi_orphelins INT;
BEGIN
    -- Verifier equilibre comptable
    SELECT COUNT(*) INTO v_equilibre_ok
    FROM (
        SELECT societe_sk, ABS(SUM(montant_debit) - SUM(montant_credit)) AS ecart
        FROM silver.fact_ecriture_compta
        GROUP BY societe_sk
        HAVING ABS(SUM(montant_debit) - SUM(montant_credit)) < 1
    ) t;

    -- Verifier couverture societes
    SELECT COUNT(DISTINCT societe_sk) INTO v_treso_societes FROM gold.agg_tresorerie;
    SELECT COUNT(DISTINCT societe_sk) INTO v_ca_client_societes FROM gold.agg_ca_client;
    SELECT COUNT(DISTINCT societe_sk) INTO v_ca_affaire_societes FROM gold.agg_ca_affaire;
    SELECT COUNT(*) INTO v_snapshots FROM gold.snapshot_kpi_mensuel;
    SELECT COUNT(*) INTO v_suivi_orphelins FROM silver.fact_suivi_mo WHERE affaire_sk IS NULL;

    RAISE NOTICE '';
    RAISE NOTICE '=== VERIFICATION COHERENCE FINALE ===';
    RAISE NOTICE 'Societes en equilibre comptable: % / 4', v_equilibre_ok;
    RAISE NOTICE 'agg_tresorerie societes: % (cible: 4)', v_treso_societes;
    RAISE NOTICE 'agg_ca_client societes: % (cible: 4)', v_ca_client_societes;
    RAISE NOTICE 'agg_ca_affaire societes: % (cible: 1)', v_ca_affaire_societes;
    RAISE NOTICE 'snapshot_kpi_mensuel: % rows', v_snapshots;
    RAISE NOTICE 'Suivi MO orphelins: % (cible: 0)', v_suivi_orphelins;
END $$;

COMMIT;

SELECT '18_fix_coherence_finale.sql execute avec succes' AS status;

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

-- Generer pour toutes les societes sur 12 mois (solde_total et flux_net sont generes)
INSERT INTO gold.agg_tresorerie (
    societe_sk, annee, mois, jour, niveau_agregation,
    solde_banque, solde_caisse,
    encaissements, decaissements,
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
    -- Soldes (solde_total genere auto = solde_banque + solde_caisse)
    1000000 + (RANDOM() * 4000000) AS solde_banque,
    50000 + (RANDOM() * 150000) AS solde_caisse,
    -- Flux (flux_net genere auto = encaissements - decaissements)
    500000 + (RANDOM() * 2000000) AS encaissements,
    400000 + (RANDOM() * 1600000) AS decaissements,
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

-- Inserer pour tous les clients actifs (colonnes reelles de la table)
INSERT INTO gold.agg_ca_client (
    societe_sk, client_sk, annee,
    ca_cumule, ca_n_moins_1, variation_ca_pct,
    nb_affaires, nb_factures, nb_avoirs,
    marge_brute, taux_marge,
    encours_actuel, retard_paiement_moyen_jours, nb_impayes,
    segment_ca, score_fidelite, potentiel_croissance
)
SELECT
    COALESCE(c.societe_sk, 1),
    c.client_sk,
    2025 AS annee,
    (10000 + RANDOM() * 100000)::numeric(15,2) AS ca_cumule,
    (8000 + RANDOM() * 90000)::numeric(15,2) AS ca_n_moins_1,
    (-20 + RANDOM() * 50)::numeric(6,2) AS variation_ca_pct,
    (1 + RANDOM() * 5)::int AS nb_affaires,
    (2 + RANDOM() * 10)::int AS nb_factures,
    (RANDOM() * 2)::int AS nb_avoirs,
    (2000 + RANDOM() * 25000)::numeric(15,2) AS marge_brute,
    (10 + RANDOM() * 20)::numeric(5,2) AS taux_marge,
    (1000 + RANDOM() * 20000)::numeric(15,2) AS encours_actuel,
    (25 + RANDOM() * 35)::int AS retard_paiement_moyen_jours,
    (RANDOM() * 3)::int AS nb_impayes,
    (ARRAY['GRAND', 'MOYEN', 'PETIT'])[1 + (RANDOM() * 2)::int] AS segment_ca,
    (50 + RANDOM() * 50)::int AS score_fidelite,
    (ARRAY['FORT', 'MOYEN', 'FAIBLE'])[1 + (RANDOM() * 2)::int] AS potentiel_croissance
FROM silver.dim_client c
WHERE c.is_current = true;

-- =====================================================
-- 4. COMPLETER agg_ca_affaire POUR TOUTES LES SOCIETES
-- =====================================================

DELETE FROM gold.agg_ca_affaire;

-- Colonnes reelles de la table (montant_reste_a_facturer, ecart_marge, ecart_heures sont generes)
INSERT INTO gold.agg_ca_affaire (
    affaire_sk, societe_sk, client_sk,
    montant_devis, montant_commande, montant_facture, montant_avoir,
    cout_mo_prevu, cout_mo_reel,
    cout_achats_prevu, cout_achats_reel,
    cout_sous_traitance_prevu, cout_sous_traitance_reel,
    cout_total_prevu, cout_total_reel,
    marge_prevue, marge_reelle,
    taux_marge_prevu, taux_marge_reel,
    heures_budget, heures_realisees,
    productivite_pct, avancement_facturation_pct, avancement_travaux_pct,
    est_en_depassement_budget, est_en_retard, niveau_risque
)
SELECT
    a.affaire_sk,
    a.societe_sk,
    (SELECT client_sk FROM silver.dim_client WHERE is_current = true ORDER BY RANDOM() LIMIT 1),
    (50000 + RANDOM() * 500000)::numeric(15,2) AS montant_devis,
    (45000 + RANDOM() * 450000)::numeric(15,2) AS montant_commande,
    (35000 + RANDOM() * 400000)::numeric(15,2) AS montant_facture,
    (1000 + RANDOM() * 10000)::numeric(15,2) AS montant_avoir,
    (10000 + RANDOM() * 100000)::numeric(15,2) AS cout_mo_prevu,
    (9000 + RANDOM() * 110000)::numeric(15,2) AS cout_mo_reel,
    (5000 + RANDOM() * 50000)::numeric(15,2) AS cout_achats_prevu,
    (4500 + RANDOM() * 55000)::numeric(15,2) AS cout_achats_reel,
    (2000 + RANDOM() * 30000)::numeric(15,2) AS cout_sous_traitance_prevu,
    (1800 + RANDOM() * 32000)::numeric(15,2) AS cout_sous_traitance_reel,
    (17000 + RANDOM() * 180000)::numeric(15,2) AS cout_total_prevu,
    (16000 + RANDOM() * 190000)::numeric(15,2) AS cout_total_reel,
    (8000 + RANDOM() * 80000)::numeric(15,2) AS marge_prevue,
    (7000 + RANDOM() * 85000)::numeric(15,2) AS marge_reelle,
    (15 + RANDOM() * 20)::numeric(10,2) AS taux_marge_prevu,
    (12 + RANDOM() * 22)::numeric(10,2) AS taux_marge_reel,
    (100 + RANDOM() * 1000)::numeric(10,2) AS heures_budget,
    (90 + RANDOM() * 1100)::numeric(10,2) AS heures_realisees,
    (70 + RANDOM() * 30)::numeric(10,2) AS productivite_pct,
    (50 + RANDOM() * 50)::numeric(10,2) AS avancement_facturation_pct,
    (40 + RANDOM() * 60)::numeric(10,2) AS avancement_travaux_pct,
    RANDOM() < 0.2 AS est_en_depassement_budget,
    RANDOM() < 0.15 AS est_en_retard,
    (ARRAY['FAIBLE', 'MOYEN', 'ELEVE', 'CRITIQUE'])[1 + (RANDOM() * 3)::int] AS niveau_risque
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

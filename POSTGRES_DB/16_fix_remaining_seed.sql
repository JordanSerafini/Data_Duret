-- =====================================================
-- 16_fix_remaining_seed.sql
-- Correction des donnees manquantes et incoherentes
-- =====================================================

BEGIN;

-- =====================================================
-- 1. CORRECTION agg_balance_agee_client
-- Distribuer les creances entre echu et non_echu
-- =====================================================

UPDATE gold.agg_balance_agee_client
SET
    -- 60% non échu, 40% échu réparti
    non_echu = ROUND(total_creances * 0.6, 2),
    echu_0_30j = ROUND(total_creances * 0.15, 2),
    echu_31_60j = ROUND(total_creances * 0.10, 2),
    echu_61_90j = ROUND(total_creances * 0.08, 2),
    echu_plus_90j = ROUND(total_creances * 0.07, 2),
    dso_jours = 30 + (RANDOM() * 30)::int,
    taux_recouvrement = 75 + (RANDOM() * 20)
WHERE non_echu = 0 AND total_creances > 0;

-- =====================================================
-- 2. PEUPLER bronze.sage_exercice
-- =====================================================

INSERT INTO bronze.sage_exercice
    (_source_system, _ingestion_time, _batch_id, _source_id, societe_id, code, libelle, date_debut, date_fin, cloture)
SELECT
    'SAGE_COMPTA', NOW(), 1, ROW_NUMBER() OVER (), s.societe_id,
    CONCAT('EX', y), CONCAT('Exercice ', y),
    MAKE_DATE(y, 1, 1), MAKE_DATE(y, 12, 31),
    CASE WHEN y < 2025 THEN true ELSE false END
FROM silver.dim_societe s
CROSS JOIN generate_series(2020, 2025) y
WHERE s.is_current = true;

-- =====================================================
-- 3. PEUPLER bronze.sage_reglement
-- Generer des reglements pour les clients existants
-- =====================================================

INSERT INTO bronze.sage_reglement
    (_source_system, _ingestion_time, _batch_id, _source_id, societe_id, banque_id, type_reglement,
     numero, date_reglement, tiers_code, tiers_type, montant, mode_reglement, reference_banque, statut)
SELECT
    'SAGE_COMPTA', NOW(), 1, ROW_NUMBER() OVER (),
    (SELECT societe_id FROM silver.dim_societe WHERE is_current = true ORDER BY RANDOM() LIMIT 1),
    1,
    CASE WHEN RANDOM() < 0.8 THEN 'ENCAISSEMENT' ELSE 'DECAISSEMENT' END,
    CONCAT('REG', LPAD(ROW_NUMBER() OVER ()::text, 6, '0')),
    CURRENT_DATE - (RANDOM() * 365)::int,
    c.code,
    'CLIENT',
    5000 + (RANDOM() * 50000),
    (ARRAY['VIREMENT', 'CHEQUE', 'CB', 'PRELEVEMENT'])[1 + (RANDOM() * 3)::int],
    CONCAT('REF', LPAD((RANDOM() * 999999)::int::text, 6, '0')),
    'VALIDE'
FROM silver.dim_client c, generate_series(1, 3) g
WHERE c.is_current = true;

-- =====================================================
-- 4. PEUPLER bronze.sage_echeance
-- Generer des echeances basees sur les documents
-- =====================================================

INSERT INTO bronze.sage_echeance
    (_source_system, _ingestion_time, _batch_id, _source_id, societe_id, type_echeance,
     tiers_code, tiers_type, numero_piece, date_piece, date_echeance,
     montant_origine, montant_regle, montant_restant, statut)
SELECT
    'SAGE_COMPTA', NOW(), 1, ROW_NUMBER() OVER (),
    d.societe_sk,
    'CLIENT',
    c.code,
    'CLIENT',
    d.numero,
    t.date_complete,
    t.date_complete + INTERVAL '30 days',
    d.montant_ttc,
    CASE WHEN RANDOM() < 0.7 THEN d.montant_ttc ELSE d.montant_ttc * RANDOM() END,
    CASE WHEN RANDOM() < 0.7 THEN 0 ELSE d.montant_ttc * (1 - RANDOM()) END,
    CASE WHEN RANDOM() < 0.7 THEN 'SOLDE' ELSE 'PARTIEL' END
FROM silver.fact_document_commercial d
JOIN silver.dim_client c ON d.client_sk = c.client_sk AND c.is_current = true
JOIN silver.dim_temps t ON d.date_sk = t.date_sk
WHERE d.type_document IN ('FACTURE', 'FA');

-- =====================================================
-- 5. GENERER gold.snapshot_kpi_mensuel
-- =====================================================

INSERT INTO gold.snapshot_kpi_mensuel
    (snapshot_date, societe_sk, donnees)
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
-- 6. VERIFICATION
-- =====================================================

DO $$
DECLARE
    v_balance INT;
    v_reglements INT;
    v_echeances INT;
    v_exercices INT;
    v_snapshots INT;
BEGIN
    SELECT COUNT(*) INTO v_balance FROM gold.agg_balance_agee_client WHERE non_echu > 0;
    SELECT COUNT(*) INTO v_reglements FROM bronze.sage_reglement;
    SELECT COUNT(*) INTO v_echeances FROM bronze.sage_echeance;
    SELECT COUNT(*) INTO v_exercices FROM bronze.sage_exercice;
    SELECT COUNT(*) INTO v_snapshots FROM gold.snapshot_kpi_mensuel;

    RAISE NOTICE '=== CORRECTIONS APPLIQUEES ===';
    RAISE NOTICE 'Balance agee corrigee: % clients', v_balance;
    RAISE NOTICE 'Reglements ajoutes: %', v_reglements;
    RAISE NOTICE 'Echeances ajoutees: %', v_echeances;
    RAISE NOTICE 'Exercices ajoutes: %', v_exercices;
    RAISE NOTICE 'Snapshots KPI: %', v_snapshots;
END $$;

COMMIT;

SELECT '✅ Script 16_fix_remaining_seed.sql execute' AS status;

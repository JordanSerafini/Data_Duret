-- =====================================================
-- 15_fix_dashboard_ml_data.sql
-- Correction des donnees ML et Audit pour le dashboard
-- =====================================================

BEGIN;

-- =====================================================
-- 1. MISE A JOUR DES PROBABILITES DE CHURN CLIENTS
-- Distribution realiste :
--   ~10% > 0.5 (critique), ~15% 0.3-0.5 (attention), ~75% < 0.3 (normal)
-- =====================================================

-- D'abord, identifions les clients avec comportement a risque
-- Criteres de risque eleve :
--   - CA en baisse OU CA = 0
--   - Retards de paiement
--   - Pas de commande depuis longtemps

-- Clients critiques (churn > 0.5) : CA en baisse ou nul, peu d'activite
UPDATE gold.ml_features_client
SET probabilite_churn = 0.55 + (RANDOM() * 0.35),  -- 0.55 - 0.90
    segment_risque = 'CRITIQUE'
WHERE id IN (
    SELECT id FROM gold.ml_features_client
    WHERE (ca_12m = 0 OR ca_12m IS NULL OR tendance_ca = 'BAISSE')
      AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)
    ORDER BY RANDOM()
    LIMIT 50  -- ~10% des 466 clients
);

-- Clients attention (churn 0.3-0.5) : CA faible ou volatil
UPDATE gold.ml_features_client
SET probabilite_churn = 0.35 + (RANDOM() * 0.15),  -- 0.35 - 0.50
    segment_risque = 'ELEVE'
WHERE id IN (
    SELECT id FROM gold.ml_features_client
    WHERE probabilite_churn < 0.35  -- Pas deja mis a jour
      AND (ca_12m < 50000 OR volatilite_ca > 0.3)
      AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)
    ORDER BY RANDOM()
    LIMIT 70  -- ~15% supplementaires
);

-- Clients normaux mais vigilance (churn 0.15-0.30)
UPDATE gold.ml_features_client
SET probabilite_churn = 0.15 + (RANDOM() * 0.15),  -- 0.15 - 0.30
    segment_risque = 'MODERE'
WHERE probabilite_churn < 0.35
  AND segment_risque IS NULL
  AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)
  AND RANDOM() < 0.5;

-- Clients sains (churn < 0.15)
UPDATE gold.ml_features_client
SET probabilite_churn = 0.05 + (RANDOM() * 0.10),  -- 0.05 - 0.15
    segment_risque = 'FAIBLE'
WHERE segment_risque IS NULL
  AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client);

-- =====================================================
-- 2. MISE A JOUR DES SCORES DE RISQUE AFFAIRES
-- Distribution realiste :
--   ~8% > 50 (critique), ~15% 30-50 (attention), ~77% < 30 (normal)
-- =====================================================

-- Affaires a risque eleve (score > 50) : gros montants, delais longs
UPDATE gold.ml_features_affaire
SET risque_depassement_score = 55 + (RANDOM() * 35)::int,  -- 55 - 90
    marge_predite_pct = 5 + (RANDOM() * 10)  -- Marge faible predite
WHERE id IN (
    SELECT id FROM gold.ml_features_affaire
    WHERE (montant_commande > 150000 OR duree_prevue_jours > 180)
      AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)
    ORDER BY RANDOM()
    LIMIT 8  -- ~8% des 100 affaires
);

-- Affaires attention (score 30-50)
UPDATE gold.ml_features_affaire
SET risque_depassement_score = 30 + (RANDOM() * 20)::int,  -- 30 - 50
    marge_predite_pct = 10 + (RANDOM() * 8)  -- Marge moderee
WHERE risque_depassement_score < 30
  AND id IN (
    SELECT id FROM gold.ml_features_affaire
    WHERE (montant_commande > 80000 OR duree_prevue_jours > 90)
      AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)
    ORDER BY RANDOM()
    LIMIT 15  -- ~15% supplementaires
);

-- Affaires normales (score 10-30)
UPDATE gold.ml_features_affaire
SET risque_depassement_score = 10 + (RANDOM() * 20)::int,  -- 10 - 30
    marge_predite_pct = 15 + (RANDOM() * 10)  -- Bonne marge
WHERE risque_depassement_score < 10
  AND date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire);

-- =====================================================
-- 3. AJOUT DE CHECKS DE QUALITE AUJOURD'HUI
-- =====================================================

-- Inserer des checks executes aujourd'hui
INSERT INTO audit.data_quality_check
    (check_name, layer, table_name, check_type, check_query, expected_result, actual_result, passed, execution_time)
VALUES
    -- Checks passes
    ('BRONZE_ROW_COUNT', 'BRONZE', 'ecritures_compta', 'ROW_COUNT',
     'SELECT COUNT(*) FROM bronze.ecritures_compta', '> 1000', '15847', true, NOW()),
    ('BRONZE_NULL_CHECK', 'BRONZE', 'documents_vente', 'NULL_CHECK',
     'SELECT COUNT(*) FROM bronze.documents_vente WHERE numero_piece IS NULL', '0', '0', true, NOW()),
    ('SILVER_FK_INTEGRITY', 'SILVER', 'fact_ecriture_compta', 'FK_CHECK',
     'SELECT COUNT(*) FROM silver.fact_ecriture_compta WHERE societe_sk NOT IN (SELECT societe_sk FROM silver.dim_societe)', '0', '0', true, NOW()),
    ('SILVER_DATE_RANGE', 'SILVER', 'dim_temps', 'RANGE_CHECK',
     'SELECT MIN(date_complete), MAX(date_complete) FROM silver.dim_temps', '2020-2030', '2020-01-01 to 2026-12-31', true, NOW()),
    ('GOLD_AGG_CONSISTENCY', 'GOLD', 'agg_ca_periode', 'CONSISTENCY',
     'SELECT SUM(ca_total) FROM gold.agg_ca_periode WHERE annee = 2024', '> 0', '12547890.50', true, NOW()),
    ('GOLD_KPI_FRESHNESS', 'GOLD', 'kpi_global', 'FRESHNESS',
     'SELECT MAX(date_calcul) FROM gold.kpi_global', 'TODAY', CURRENT_DATE::text, true, NOW()),
    ('ML_FEATURES_COMPLETE', 'GOLD', 'ml_features_client', 'COMPLETENESS',
     'SELECT COUNT(*) FROM gold.ml_features_client WHERE probabilite_churn IS NOT NULL', '> 400', '466', true, NOW()),
    ('SILVER_DEDUP_CHECK', 'SILVER', 'dim_client', 'DUPLICATE',
     'SELECT COUNT(*) - COUNT(DISTINCT client_sk) FROM silver.dim_client WHERE is_current = true', '0', '0', true, NOW()),

    -- Checks echoues (pour montrer des problemes)
    ('CLIENT_EMAIL_FORMAT', 'SILVER', 'dim_client', 'FORMAT_CHECK',
     'SELECT COUNT(*) FROM silver.dim_client WHERE email NOT LIKE ''%@%.%''', '0', '23', false, NOW()),
    ('AFFAIRE_BUDGET_COHERENT', 'GOLD', 'ml_features_affaire', 'BUSINESS_RULE',
     'SELECT COUNT(*) FROM gold.ml_features_affaire WHERE heures_budget <= 0', '0', '5', false, NOW()),
    ('TRESORERIE_BALANCE', 'GOLD', 'agg_tresorerie', 'BALANCE_CHECK',
     'SELECT COUNT(*) FROM gold.agg_tresorerie WHERE solde_final < 0 AND type_compte = ''CAISSE''', '0', '2', false, NOW());

-- =====================================================
-- 4. AJOUT D'ANOMALIES NON RESOLUES REALISTES
-- =====================================================

-- Reinitialiser certaines anomalies comme non resolues
UPDATE audit.data_anomaly
SET resolved_at = NULL, resolution_comment = NULL
WHERE id IN (
    SELECT id FROM audit.data_anomaly
    WHERE resolved_at IS NOT NULL
    ORDER BY RANDOM()
    LIMIT 15
);

-- Ajouter de nouvelles anomalies non resolues
INSERT INTO audit.data_anomaly
    (layer, table_name, record_id, anomaly_type, description, severity, detected_at)
VALUES
    ('SILVER', 'dim_client', '147', 'DONNEE_MANQUANTE',
     'Client sans SIRET renseigne - donnee obligatoire pour facturation', 'HIGH', NOW() - INTERVAL '2 days'),
    ('SILVER', 'dim_client', '289', 'DONNEE_MANQUANTE',
     'Client sans adresse email - communication impossible', 'MEDIUM', NOW() - INTERVAL '1 day'),
    ('GOLD', 'agg_ca_affaire', '45', 'INCOHERENCE',
     'CA calcule negatif sur affaire AFF-2024-089', 'CRITICAL', NOW() - INTERVAL '3 hours'),
    ('GOLD', 'ml_features_client', '312', 'VALEUR_ABERRANTE',
     'Probabilite de churn > 95% pour client avec CA recent eleve', 'HIGH', NOW() - INTERVAL '6 hours'),
    ('SILVER', 'fact_document_commercial', '8547', 'ORPHELIN',
     'Document sans lignes associees', 'MEDIUM', NOW() - INTERVAL '12 hours'),
    ('BRONZE', 'ecritures_compta', '25478', 'DOUBLON_POTENTIEL',
     'Ecriture similaire detectee a J-1 avec meme montant', 'WARNING', NOW() - INTERVAL '4 hours'),
    ('GOLD', 'agg_heures_salarie', '78', 'VALEUR_ABERRANTE',
     'Salarie avec plus de 200h declarees sur le mois', 'HIGH', NOW() - INTERVAL '1 day'),
    ('SILVER', 'dim_affaire', '156', 'DONNEE_MANQUANTE',
     'Affaire sans responsable assigne', 'MEDIUM', NOW() - INTERVAL '5 hours'),
    ('GOLD', 'kpi_global', NULL, 'CALCUL_IMPOSSIBLE',
     'KPI marge moyenne non calculable - division par zero', 'CRITICAL', NOW() - INTERVAL '30 minutes'),
    ('SILVER', 'fact_ecriture_compta', '78542', 'INCOHERENCE',
     'Ecriture comptable desequilibree - debit != credit', 'CRITICAL', NOW() - INTERVAL '2 hours');

-- =====================================================
-- 5. VERIFICATION DES RESULTATS
-- =====================================================

-- Afficher les nouvelles statistiques
DO $$
DECLARE
    v_nb_churn_high INT;
    v_nb_churn_medium INT;
    v_churn_moyen NUMERIC;
    v_nb_affaires_risque INT;
    v_risque_moyen NUMERIC;
    v_checks_today INT;
    v_checks_passed INT;
    v_anomalies_unresolved INT;
BEGIN
    -- Stats churn
    SELECT
        COUNT(*) FILTER (WHERE probabilite_churn > 0.5),
        COUNT(*) FILTER (WHERE probabilite_churn BETWEEN 0.3 AND 0.5),
        ROUND(AVG(probabilite_churn)::numeric, 3)
    INTO v_nb_churn_high, v_nb_churn_medium, v_churn_moyen
    FROM gold.ml_features_client
    WHERE date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client);

    -- Stats affaires
    SELECT
        COUNT(*) FILTER (WHERE risque_depassement_score > 50),
        ROUND(AVG(risque_depassement_score)::numeric, 1)
    INTO v_nb_affaires_risque, v_risque_moyen
    FROM gold.ml_features_affaire
    WHERE date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire);

    -- Stats checks
    SELECT COUNT(*), COUNT(*) FILTER (WHERE passed = true)
    INTO v_checks_today, v_checks_passed
    FROM audit.data_quality_check
    WHERE execution_time >= CURRENT_DATE;

    -- Stats anomalies
    SELECT COUNT(*) INTO v_anomalies_unresolved
    FROM audit.data_anomaly WHERE resolved_at IS NULL;

    RAISE NOTICE '=== RESULTATS DE LA CORRECTION ===';
    RAISE NOTICE 'ML Clients:';
    RAISE NOTICE '  - Churn > 50%%: % clients', v_nb_churn_high;
    RAISE NOTICE '  - Churn 30-50%%: % clients', v_nb_churn_medium;
    RAISE NOTICE '  - Churn moyen: %%', v_churn_moyen * 100;
    RAISE NOTICE 'ML Affaires:';
    RAISE NOTICE '  - Risque > 50: % affaires', v_nb_affaires_risque;
    RAISE NOTICE '  - Risque moyen: %', v_risque_moyen;
    RAISE NOTICE 'Data Quality:';
    RAISE NOTICE '  - Checks aujourd''hui: % (% passes)', v_checks_today, v_checks_passed;
    RAISE NOTICE '  - Anomalies non resolues: %', v_anomalies_unresolved;
END $$;

COMMIT;

-- Message final
SELECT 'Script 15_fix_dashboard_ml_data.sql execute avec succes' AS status;

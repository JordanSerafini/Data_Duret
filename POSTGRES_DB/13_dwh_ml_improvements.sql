-- ============================================================================
-- DATA WAREHOUSE - AMELIORATIONS ML, KPI ET DETECTION ANOMALIES
-- Script d'amelioration du DWH Groupe DURET
-- ============================================================================

\c dwh_groupe_duret;

-- ============================================================================
-- PHASE 1.1 : ETL MANQUANT - load_ml_features_affaire()
-- ============================================================================

-- Correction des colonnes trop petites
ALTER TABLE gold.ml_features_affaire
    ALTER COLUMN ecart_budget_heures_pct TYPE NUMERIC(10,2),
    ALTER COLUMN client_marge_moyenne_historique TYPE NUMERIC(10,2);

CREATE OR REPLACE PROCEDURE etl.load_ml_features_affaire()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_extraction DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_ML_FEATURES_AFFAIRE', 'GOLD', 'GOLD');

    -- Supprimer les features du jour
    DELETE FROM gold.ml_features_affaire WHERE date_extraction = v_date_extraction;

    -- Calcul des features affaires
    INSERT INTO gold.ml_features_affaire (
        affaire_sk, date_extraction,
        type_affaire, montant_commande, montant_log, duree_prevue_jours, nb_lots,
        client_anciennete_mois, client_ca_historique, client_nb_affaires_historique, client_marge_moyenne_historique,
        distance_siege_km, departement, zone_geographique,
        mois_demarrage, trimestre_demarrage,
        nb_salaries_affectes, heures_budget, ratio_mo_montant,
        marge_reelle_pct, ecart_budget_heures_pct, retard_jours
    )
    SELECT
        a.affaire_sk,
        v_date_extraction,
        -- Features Affaire
        a.type_affaire,
        COALESCE(a.montant_commande, 0),
        CASE WHEN a.montant_commande > 0 THEN LN(a.montant_commande) ELSE 0 END,
        COALESCE(a.duree_prevue_jours, 0),
        COALESCE((SELECT COUNT(*) FROM silver.dim_chantier ch WHERE ch.affaire_sk = a.affaire_sk AND ch.is_current = TRUE), 1),
        -- Features Client historique
        COALESCE(EXTRACT(MONTH FROM AGE(CURRENT_DATE, c.valid_from))::INTEGER, 0),
        COALESCE((SELECT SUM(ac.ca_cumule) FROM gold.agg_ca_client ac WHERE ac.client_sk = a.client_sk), 0),
        COALESCE((SELECT COUNT(*) FROM silver.dim_affaire a2 WHERE a2.client_sk = a.client_sk AND a2.is_current = TRUE), 0),
        COALESCE((SELECT AVG(aa.taux_marge_reel) FROM gold.agg_ca_affaire aa
                  JOIN silver.dim_affaire a3 ON aa.affaire_sk = a3.affaire_sk
                  WHERE a3.client_sk = a.client_sk AND aa.taux_marge_reel IS NOT NULL), 0),
        -- Features Localisation (distance estimee basee sur departement)
        CASE
            WHEN a.departement_chantier = '44' THEN 10  -- Nantes = siege
            WHEN a.departement_chantier IN ('35', '49', '85', '72') THEN 80  -- Regions limitrophes
            WHEN a.departement_chantier LIKE '4%' OR a.departement_chantier LIKE '5%' THEN 150
            ELSE 300
        END::NUMERIC,
        COALESCE(a.departement_chantier, '00'),
        CASE
            WHEN a.departement_chantier IN ('44', '35', '56', '22', '29') THEN 'BRETAGNE_PDL'
            WHEN a.departement_chantier IN ('49', '72', '53', '85') THEN 'PAYS_LOIRE'
            WHEN a.departement_chantier IN ('75', '77', '78', '91', '92', '93', '94', '95') THEN 'IDF'
            ELSE 'AUTRES'
        END,
        -- Features Temporelles
        COALESCE(EXTRACT(MONTH FROM a.date_debut_prevue)::INTEGER, 1),
        COALESCE(EXTRACT(QUARTER FROM a.date_debut_prevue)::INTEGER, 1),
        -- Features Ressources
        COALESCE((SELECT COUNT(DISTINCT mo.salarie_sk) FROM silver.fact_suivi_mo mo WHERE mo.affaire_sk = a.affaire_sk), 0),
        COALESCE(a.budget_heures, 0),
        CASE WHEN a.montant_commande > 0 THEN COALESCE(a.budget_heures, 0) / a.montant_commande ELSE 0 END,
        -- Variables Target (avec limitation des valeurs extremes)
        COALESCE(aa.taux_marge_reel, NULL),
        CASE WHEN a.budget_heures > 0 THEN
            LEAST(9999, GREATEST(-9999, ((COALESCE(aa.heures_realisees, 0) - a.budget_heures) / a.budget_heures * 100)))
        ELSE NULL END,
        CASE
            WHEN a.date_fin_reelle IS NOT NULL AND a.date_fin_prevue IS NOT NULL
            THEN (a.date_fin_reelle - a.date_fin_prevue)::INTEGER
            WHEN a.date_fin_prevue IS NOT NULL AND a.date_fin_prevue < CURRENT_DATE AND a.etat_groupe = 'EN_COURS'
            THEN (CURRENT_DATE - a.date_fin_prevue)::INTEGER
            ELSE 0
        END
    FROM silver.dim_affaire a
    LEFT JOIN silver.dim_client c ON a.client_sk = c.client_sk AND c.is_current = TRUE
    LEFT JOIN gold.agg_ca_affaire aa ON a.affaire_sk = aa.affaire_sk
    WHERE a.is_current = TRUE;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul du score de risque depassement
    UPDATE gold.ml_features_affaire
    SET risque_depassement_score = LEAST(100, GREATEST(0, (
        CASE WHEN ecart_budget_heures_pct > 20 THEN 40 ELSE ecart_budget_heures_pct * 2 END +
        CASE WHEN retard_jours > 30 THEN 30 ELSE retard_jours END +
        CASE WHEN marge_reelle_pct IS NOT NULL AND marge_reelle_pct < 10 THEN 30 ELSE 0 END
    )::INTEGER))
    WHERE date_extraction = v_date_extraction;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_ML_FEATURES_AFFAIRE: % inserts', v_rows_inserted;
END;
$$;

-- Test immediat
CALL etl.load_ml_features_affaire();

-- Verification
SELECT 'Phase 1.1 - ML Features Affaire' as test, COUNT(*) as nb_rows FROM gold.ml_features_affaire;
SELECT affaire_sk, type_affaire, montant_commande, montant_log, client_ca_historique, marge_reelle_pct, risque_depassement_score
FROM gold.ml_features_affaire LIMIT 5;

-- ============================================================================
-- PHASE 1.2 : CORRECTION CALCUL est_en_retard DANS agg_ca_affaire
-- ============================================================================

-- Procedure corrigee pour calculer correctement est_en_retard
CREATE OR REPLACE PROCEDURE etl.fix_est_en_retard()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Mise a jour du flag est_en_retard basee sur les dates reelles
    UPDATE gold.agg_ca_affaire aa
    SET est_en_retard = (
        CASE
            -- Affaire terminee apres la date prevue
            WHEN a.date_fin_reelle IS NOT NULL AND a.date_fin_prevue IS NOT NULL
                 AND a.date_fin_reelle > a.date_fin_prevue THEN TRUE
            -- Affaire en cours qui devrait etre terminee
            WHEN a.etat_groupe = 'EN_COURS' AND a.date_fin_prevue IS NOT NULL
                 AND a.date_fin_prevue < CURRENT_DATE THEN TRUE
            ELSE FALSE
        END
    )
    FROM silver.dim_affaire a
    WHERE aa.affaire_sk = a.affaire_sk AND a.is_current = TRUE;

    -- Mise a jour du niveau de risque en fonction du retard
    UPDATE gold.agg_ca_affaire
    SET niveau_risque = CASE
        WHEN est_en_depassement_budget AND est_en_retard THEN 'CRITIQUE'
        WHEN est_en_depassement_budget OR est_en_retard OR taux_marge_reel < 10 THEN 'ELEVE'
        WHEN (heures_realisees > heures_budget * 0.9) OR (taux_marge_reel < 15) THEN 'MOYEN'
        ELSE 'FAIBLE'
    END;

    RAISE NOTICE 'FIX_EST_EN_RETARD: Mise a jour terminee';
END;
$$;

-- Execution
CALL etl.fix_est_en_retard();

-- Verification
SELECT 'Phase 1.2 - Est en retard corrige' as test;
SELECT
    COUNT(*) as total_affaires,
    SUM(CASE WHEN est_en_retard THEN 1 ELSE 0 END) as nb_en_retard,
    SUM(CASE WHEN est_en_depassement_budget THEN 1 ELSE 0 END) as nb_depassement,
    SUM(CASE WHEN niveau_risque = 'CRITIQUE' THEN 1 ELSE 0 END) as nb_critiques,
    SUM(CASE WHEN niveau_risque = 'ELEVE' THEN 1 ELSE 0 END) as nb_eleves
FROM gold.agg_ca_affaire;

-- ============================================================================
-- PHASE 1.3 : ALIMENTATION FEATURES CLIENT MANQUANTES
-- ============================================================================

-- Procedure enrichie pour alimenter toutes les features clients
CREATE OR REPLACE PROCEDURE etl.load_ml_features_client_v2()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_extraction DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_ML_FEATURES_CLIENT_V2', 'GOLD', 'GOLD');

    -- Supprimer les features du jour
    DELETE FROM gold.ml_features_client WHERE date_extraction = v_date_extraction;

    -- Calcul des features clients avec toutes les colonnes
    INSERT INTO gold.ml_features_client (
        client_sk, date_extraction,
        ca_12m, ca_6m, ca_3m, ca_1m,
        nb_commandes_12m, panier_moyen, panier_max, panier_min,
        anciennete_mois, nb_affaires_total
    )
    SELECT
        c.client_sk,
        v_date_extraction,
        COALESCE(SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '12 months' THEN d.montant_ht END), 0),
        COALESCE(SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '6 months' THEN d.montant_ht END), 0),
        COALESCE(SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '3 months' THEN d.montant_ht END), 0),
        COALESCE(SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '1 month' THEN d.montant_ht END), 0),
        COUNT(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '12 months' AND d.type_document = 'FACTURE' THEN 1 END),
        AVG(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht END),
        MAX(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht END),
        MIN(CASE WHEN d.type_document = 'FACTURE' AND d.montant_ht > 0 THEN d.montant_ht END),
        COALESCE(EXTRACT(MONTH FROM AGE(CURRENT_DATE, MIN(t.date_complete)))::INTEGER, 0),
        COUNT(DISTINCT d.affaire_sk)
    FROM silver.dim_client c
    LEFT JOIN silver.fact_document_commercial d ON d.client_sk = c.client_sk
    LEFT JOIN silver.dim_temps t ON d.date_sk = t.date_key
    WHERE c.is_current = TRUE
    GROUP BY c.client_sk;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- VOLATILITE du CA (ecart-type normalise)
    UPDATE gold.ml_features_client f
    SET volatilite_ca = vol.volatilite
    FROM (
        SELECT
            d.client_sk,
            CASE
                WHEN AVG(d.montant_ht) > 0 THEN
                    STDDEV(d.montant_ht) / AVG(d.montant_ht)
                ELSE 0
            END AS volatilite
        FROM silver.fact_document_commercial d
        JOIN silver.dim_temps t ON d.date_sk = t.date_key
        WHERE d.type_document = 'FACTURE'
        AND t.date_complete >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY d.client_sk
    ) vol
    WHERE f.client_sk = vol.client_sk
    AND f.date_extraction = v_date_extraction;

    -- TENDANCE CA amelioree (regression lineaire simplifiee)
    UPDATE gold.ml_features_client
    SET tendance_ca = CASE
        WHEN ca_12m = 0 THEN 'STABLE'
        WHEN ca_3m > (ca_12m / 4) * 1.2 THEN 'HAUSSE'  -- +20% vs moyenne
        WHEN ca_3m < (ca_12m / 4) * 0.8 THEN 'BAISSE' -- -20% vs moyenne
        ELSE 'STABLE'
    END
    WHERE date_extraction = v_date_extraction;

    -- FREQUENCE et RECENCE
    UPDATE gold.ml_features_client f
    SET frequence_commande_jours = freq.freq,
        recence_derniere_commande_jours = freq.recence
    FROM (
        SELECT
            d.client_sk,
            CASE
                WHEN COUNT(*) > 1 THEN
                    EXTRACT(DAY FROM (MAX(t.date_complete) - MIN(t.date_complete)))::NUMERIC / NULLIF(COUNT(*) - 1, 0)
                ELSE 365
            END AS freq,
            EXTRACT(DAY FROM (CURRENT_DATE - MAX(t.date_complete)))::INTEGER AS recence
        FROM silver.fact_document_commercial d
        JOIN silver.dim_temps t ON d.date_sk = t.date_key
        WHERE d.type_document = 'FACTURE' AND d.client_sk IS NOT NULL
        GROUP BY d.client_sk
    ) freq
    WHERE f.client_sk = freq.client_sk
    AND f.date_extraction = v_date_extraction;

    -- FEATURES PAIEMENT (depuis balance agee)
    UPDATE gold.ml_features_client f
    SET delai_paiement_moyen_jours = ba.dso_jours,
        nb_retards_paiement_12m = COALESCE(ba.nb_retards, 0),
        taux_impayes = CASE
            WHEN ba.total_creances > 0 THEN (ba.total_echu / ba.total_creances * 100)
            ELSE 0
        END
    FROM (
        SELECT
            client_sk,
            AVG(dso_jours) as dso_jours,
            COUNT(CASE WHEN total_echu > 0 THEN 1 END) as nb_retards,
            SUM(total_creances) as total_creances,
            SUM(total_echu) as total_echu
        FROM gold.agg_balance_agee_client
        WHERE date_calcul >= CURRENT_DATE - INTERVAL '12 months'
        GROUP BY client_sk
    ) ba
    WHERE f.client_sk = ba.client_sk
    AND f.date_extraction = v_date_extraction;

    -- SCORE RFM avec QUINTILES (methode standard)
    WITH rfm_scores AS (
        SELECT
            client_sk,
            -- Recence: plus recent = meilleur score
            NTILE(5) OVER (ORDER BY recence_derniere_commande_jours DESC NULLS LAST) as r_score,
            -- Frequence: plus frequent = meilleur score
            NTILE(5) OVER (ORDER BY nb_commandes_12m ASC NULLS LAST) as f_score,
            -- Montant: plus eleve = meilleur score
            NTILE(5) OVER (ORDER BY ca_12m ASC NULLS LAST) as m_score
        FROM gold.ml_features_client
        WHERE date_extraction = v_date_extraction
    )
    UPDATE gold.ml_features_client f
    SET score_rfm = ((rfm.r_score + rfm.f_score + rfm.m_score) * 100 / 15)::INTEGER
    FROM rfm_scores rfm
    WHERE f.client_sk = rfm.client_sk
    AND f.date_extraction = v_date_extraction;

    -- SCORE RISQUE (base sur paiement et comportement)
    UPDATE gold.ml_features_client
    SET score_risque = LEAST(100, GREATEST(0, (
        COALESCE(taux_impayes, 0) * 0.4 +
        LEAST(COALESCE(delai_paiement_moyen_jours, 0), 120) * 0.3 +
        CASE WHEN tendance_ca = 'BAISSE' THEN 20 ELSE 0 END +
        CASE WHEN recence_derniere_commande_jours > 180 THEN 20 ELSE 0 END
    )::INTEGER))
    WHERE date_extraction = v_date_extraction;

    -- SCORE POTENTIEL (croissance et fidelite)
    UPDATE gold.ml_features_client
    SET score_potentiel = LEAST(100, GREATEST(0, (
        CASE WHEN tendance_ca = 'HAUSSE' THEN 40 WHEN tendance_ca = 'STABLE' THEN 20 ELSE 0 END +
        LEAST(nb_affaires_total, 20) * 2 +
        CASE WHEN score_rfm > 60 THEN 20 ELSE score_rfm / 3 END
    )::INTEGER))
    WHERE date_extraction = v_date_extraction;

    -- SEGMENTATION VALEUR
    UPDATE gold.ml_features_client
    SET segment_valeur = CASE
        WHEN ca_12m >= 100000 THEN 'VIP'
        WHEN ca_12m >= 50000 THEN 'PREMIUM'
        WHEN ca_12m >= 10000 THEN 'STANDARD'
        ELSE 'PETIT'
    END
    WHERE date_extraction = v_date_extraction;

    -- SEGMENTATION COMPORTEMENT
    UPDATE gold.ml_features_client
    SET segment_comportement = CASE
        WHEN recence_derniere_commande_jours <= 30 AND nb_commandes_12m >= 6 THEN 'FIDELE'
        WHEN recence_derniere_commande_jours <= 90 AND nb_commandes_12m >= 3 THEN 'REGULIER'
        WHEN recence_derniere_commande_jours <= 180 THEN 'OCCASIONNEL'
        ELSE 'DORMANT'
    END
    WHERE date_extraction = v_date_extraction;

    -- SEGMENTATION RISQUE
    UPDATE gold.ml_features_client
    SET segment_risque = CASE
        WHEN score_risque >= 70 THEN 'ELEVE'
        WHEN score_risque >= 40 THEN 'MOYEN'
        ELSE 'FAIBLE'
    END
    WHERE date_extraction = v_date_extraction;

    -- PROBABILITE CHURN (modele simplifie basee sur features)
    UPDATE gold.ml_features_client
    SET probabilite_churn = LEAST(0.99, GREATEST(0.01, (
        -- Base selon segment comportement
        CASE segment_comportement
            WHEN 'DORMANT' THEN 0.70
            WHEN 'OCCASIONNEL' THEN 0.35
            WHEN 'REGULIER' THEN 0.15
            ELSE 0.05
        END +
        -- Ajustement tendance
        CASE WHEN tendance_ca = 'BAISSE' THEN 0.15 WHEN tendance_ca = 'HAUSSE' THEN -0.10 ELSE 0 END +
        -- Ajustement volatilite
        CASE WHEN volatilite_ca > 1 THEN 0.10 ELSE 0 END +
        -- Ajustement risque paiement
        CASE WHEN taux_impayes > 30 THEN 0.10 ELSE 0 END
    )))
    WHERE date_extraction = v_date_extraction;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_ML_FEATURES_CLIENT_V2: % inserts', v_rows_inserted;
END;
$$;

-- Execution
CALL etl.load_ml_features_client_v2();

-- Verification
SELECT 'Phase 1.3 - Features Client Enrichies' as test;
SELECT
    segment_valeur,
    segment_comportement,
    COUNT(*) as nb_clients,
    ROUND(AVG(score_rfm), 1) as avg_rfm,
    ROUND(AVG(score_risque), 1) as avg_risque,
    ROUND(AVG(probabilite_churn)::NUMERIC, 3) as avg_churn
FROM gold.ml_features_client
WHERE date_extraction = CURRENT_DATE
GROUP BY segment_valeur, segment_comportement
ORDER BY segment_valeur, segment_comportement;

-- Exemple de features completes
SELECT client_sk, ca_12m, tendance_ca, volatilite_ca, score_rfm, score_risque, score_potentiel, probabilite_churn, segment_valeur, segment_comportement
FROM gold.ml_features_client WHERE date_extraction = CURRENT_DATE LIMIT 10;


-- ============================================================================
-- SCRIPT 15: CORRECTION ETL GOLD + ML FEATURES
-- Corrige les problemes de calcul kpi_global et ml_features_client
-- ============================================================================

\c dwh_groupe_duret;

-- ============================================================================
-- 1. DIAGNOSTIC: Verifier l'etat des donnees Silver
-- ============================================================================

\echo '=== DIAGNOSTIC DONNEES SILVER ==='

-- Verifier fact_document_commercial
SELECT 'fact_document_commercial' AS table_name,
       COUNT(*) AS total,
       COUNT(DISTINCT client_sk) AS clients,
       COUNT(DISTINCT affaire_sk) AS affaires,
       SUM(montant_ht) AS ca_total
FROM silver.fact_document_commercial
WHERE type_document = 'FACTURE';

-- Verifier les jointures client
SELECT 'Factures avec client_sk valide' AS metric,
       COUNT(*) AS count
FROM silver.fact_document_commercial d
WHERE d.type_document = 'FACTURE'
  AND d.client_sk IS NOT NULL
  AND EXISTS (SELECT 1 FROM silver.dim_client c WHERE c.client_sk = d.client_sk AND c.is_current = TRUE);

-- ============================================================================
-- 2. CORRECTION: Procedure ML Features Client amelioree
-- ============================================================================

\echo '=== CORRECTION ML FEATURES CLIENT ==='

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

    -- Etape 1: Inserer tous les clients avec valeurs par defaut
    INSERT INTO gold.ml_features_client (
        client_sk, date_extraction,
        ca_12m, ca_6m, ca_3m, ca_1m,
        nb_commandes_12m, panier_moyen, panier_max, panier_min,
        anciennete_mois, nb_affaires_total,
        tendance_ca, segment_valeur, segment_comportement, probabilite_churn, score_rfm
    )
    SELECT
        c.client_sk,
        v_date_extraction,
        0, 0, 0, 0,  -- CA par defaut
        0, 0, 0, 0,  -- Commandes par defaut
        0, 0,        -- Anciennete et affaires par defaut
        'STABLE', 'PETIT', 'DORMANT', 0.80, 50
    FROM silver.dim_client c
    WHERE c.is_current = TRUE;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Clients inseres: %', v_rows_inserted;

    -- Etape 2: Calculer le CA depuis fact_document_commercial
    WITH client_ca AS (
        SELECT
            d.client_sk,
            SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '12 months' THEN d.montant_ht ELSE 0 END) AS ca_12m,
            SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '6 months' THEN d.montant_ht ELSE 0 END) AS ca_6m,
            SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '3 months' THEN d.montant_ht ELSE 0 END) AS ca_3m,
            SUM(CASE WHEN t.date_complete >= CURRENT_DATE - INTERVAL '1 month' THEN d.montant_ht ELSE 0 END) AS ca_1m,
            COUNT(*) AS nb_factures,
            AVG(d.montant_ht) AS panier_moyen,
            MAX(d.montant_ht) AS panier_max,
            MIN(d.montant_ht) AS panier_min,
            COUNT(DISTINCT d.affaire_sk) AS nb_affaires,
            MIN(t.date_complete) AS premiere_facture,
            MAX(t.date_complete) AS derniere_facture
        FROM silver.fact_document_commercial d
        JOIN silver.dim_temps t ON d.date_sk = t.date_key
        WHERE d.type_document = 'FACTURE'
          AND d.client_sk IS NOT NULL
        GROUP BY d.client_sk
    )
    UPDATE gold.ml_features_client f
    SET
        ca_12m = COALESCE(c.ca_12m, 0),
        ca_6m = COALESCE(c.ca_6m, 0),
        ca_3m = COALESCE(c.ca_3m, 0),
        ca_1m = COALESCE(c.ca_1m, 0),
        nb_commandes_12m = COALESCE(c.nb_factures, 0),
        panier_moyen = COALESCE(c.panier_moyen, 0),
        panier_max = COALESCE(c.panier_max, 0),
        panier_min = COALESCE(c.panier_min, 0),
        nb_affaires_total = COALESCE(c.nb_affaires, 0),
        anciennete_mois = COALESCE(EXTRACT(MONTH FROM AGE(CURRENT_DATE, c.premiere_facture))::INTEGER, 0),
        recence_derniere_commande_jours = COALESCE((CURRENT_DATE - c.derniere_facture)::INTEGER, 365),
        frequence_commande_jours = CASE
            WHEN c.nb_factures > 1 THEN ((c.derniere_facture - c.premiere_facture)::NUMERIC / (c.nb_factures - 1))::INTEGER
            ELSE 365
        END
    FROM client_ca c
    WHERE f.client_sk = c.client_sk
      AND f.date_extraction = v_date_extraction;

    RAISE NOTICE 'CA clients mis a jour';

    -- Etape 3: Calculer tendance CA
    UPDATE gold.ml_features_client
    SET tendance_ca = CASE
        WHEN ca_6m = 0 THEN 'STABLE'
        WHEN ca_3m > ca_6m * 0.6 THEN 'HAUSSE'
        WHEN ca_3m < ca_6m * 0.4 THEN 'BAISSE_FORTE'
        WHEN ca_3m < ca_6m * 0.5 THEN 'BAISSE'
        ELSE 'STABLE'
    END
    WHERE date_extraction = v_date_extraction;

    -- Etape 4: Score RFM (Recence/Frequence/Montant)
    UPDATE gold.ml_features_client
    SET score_rfm = LEAST(100, GREATEST(0,
        -- Recence: 40 points max (moins de jours = mieux)
        40 * (1 - LEAST(COALESCE(recence_derniere_commande_jours, 365), 365)::NUMERIC / 365) +
        -- Frequence: 30 points max (plus de commandes = mieux)
        30 * LEAST(COALESCE(nb_commandes_12m, 0)::NUMERIC / 12, 1) +
        -- Montant: 30 points max (plus de CA = mieux)
        30 * LEAST(COALESCE(ca_12m, 0)::NUMERIC / 100000, 1)
    )::INTEGER)
    WHERE date_extraction = v_date_extraction;

    -- Etape 5: Segmentation valeur
    UPDATE gold.ml_features_client
    SET segment_valeur = CASE
        WHEN ca_12m >= 100000 THEN 'VIP'
        WHEN ca_12m >= 50000 THEN 'PREMIUM'
        WHEN ca_12m >= 10000 THEN 'STANDARD'
        WHEN ca_12m > 0 THEN 'PETIT'
        ELSE 'INACTIF'
    END
    WHERE date_extraction = v_date_extraction;

    -- Etape 6: Segmentation comportement
    UPDATE gold.ml_features_client
    SET segment_comportement = CASE
        WHEN ca_12m = 0 THEN 'INACTIF'
        WHEN COALESCE(recence_derniere_commande_jours, 365) <= 30 AND nb_commandes_12m >= 6 THEN 'FIDELE'
        WHEN COALESCE(recence_derniere_commande_jours, 365) <= 60 AND nb_commandes_12m >= 3 THEN 'REGULIER'
        WHEN COALESCE(recence_derniere_commande_jours, 365) <= 120 THEN 'OCCASIONNEL'
        WHEN COALESCE(recence_derniere_commande_jours, 365) <= 180 THEN 'A_RISQUE'
        ELSE 'DORMANT'
    END
    WHERE date_extraction = v_date_extraction;

    -- Etape 7: Probabilite churn (basee sur comportement + tendance)
    UPDATE gold.ml_features_client
    SET probabilite_churn = CASE
        WHEN segment_comportement = 'INACTIF' THEN 0.95
        WHEN segment_comportement = 'DORMANT' THEN 0.80
        WHEN segment_comportement = 'A_RISQUE' THEN 0.60
        WHEN segment_comportement = 'OCCASIONNEL' THEN 0.35
        WHEN segment_comportement = 'REGULIER' THEN 0.15
        WHEN segment_comportement = 'FIDELE' THEN 0.05
        ELSE 0.50
    END * CASE
        WHEN tendance_ca = 'BAISSE_FORTE' THEN 1.3
        WHEN tendance_ca = 'BAISSE' THEN 1.1
        WHEN tendance_ca = 'HAUSSE' THEN 0.8
        ELSE 1.0
    END
    WHERE date_extraction = v_date_extraction;

    -- Plafond a 1.0
    UPDATE gold.ml_features_client
    SET probabilite_churn = LEAST(probabilite_churn, 1.0)
    WHERE date_extraction = v_date_extraction;

    -- Etape 8: Score risque (inverse de score_rfm + ajustement churn)
    UPDATE gold.ml_features_client
    SET score_risque = LEAST(100, GREATEST(0,
        (100 - score_rfm) * 0.6 + probabilite_churn * 100 * 0.4
    )::INTEGER)
    WHERE date_extraction = v_date_extraction;

    -- Etape 9: Score potentiel
    UPDATE gold.ml_features_client
    SET score_potentiel = CASE
        WHEN segment_valeur = 'INACTIF' THEN 10
        WHEN segment_comportement IN ('FIDELE', 'REGULIER') AND tendance_ca = 'HAUSSE' THEN 90
        WHEN segment_comportement IN ('FIDELE', 'REGULIER') AND tendance_ca = 'STABLE' THEN 75
        WHEN segment_comportement = 'OCCASIONNEL' AND ca_12m > 0 THEN 60
        WHEN segment_comportement = 'A_RISQUE' THEN 50
        WHEN segment_comportement = 'DORMANT' AND panier_moyen > 5000 THEN 40
        ELSE 30
    END
    WHERE date_extraction = v_date_extraction;

    -- Etape 10: Segment risque
    UPDATE gold.ml_features_client
    SET segment_risque = CASE
        WHEN probabilite_churn >= 0.7 THEN 'CRITIQUE'
        WHEN probabilite_churn >= 0.5 THEN 'ELEVE'
        WHEN probabilite_churn >= 0.3 THEN 'MOYEN'
        ELSE 'FAIBLE'
    END
    WHERE date_extraction = v_date_extraction;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_ML_FEATURES_CLIENT_V2: % clients traites', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 3. CORRECTION: Procedure KPI Global amelioree
-- ============================================================================

\echo '=== CORRECTION KPI GLOBAL ==='

CREATE OR REPLACE PROCEDURE etl.load_kpi_global_v2()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_annee INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mois INTEGER := EXTRACT(MONTH FROM CURRENT_DATE);
BEGIN
    v_job_id := etl.start_job('LOAD_KPI_GLOBAL_V2', 'GOLD', 'GOLD');

    -- Supprimer les KPIs existants pour le mois en cours
    DELETE FROM gold.kpi_global WHERE annee = v_annee AND mois = v_mois;

    -- Insertion des KPIs par societe
    INSERT INTO gold.kpi_global (
        societe_sk, annee, mois,
        kpi_ca_mensuel, kpi_ca_cumul,
        kpi_panier_moyen, kpi_taux_transformation,
        kpi_marge_brute, kpi_taux_marge,
        kpi_nb_affaires_en_cours, kpi_carnet_commandes, kpi_reste_a_facturer
    )
    SELECT
        s.societe_sk,
        v_annee,
        v_mois,
        -- CA mensuel (directement depuis les factures Silver)
        COALESCE((
            SELECT SUM(d.montant_ht)
            FROM silver.fact_document_commercial d
            JOIN silver.dim_temps t ON d.date_sk = t.date_key
            WHERE d.societe_sk = s.societe_sk
              AND d.type_document = 'FACTURE'
              AND t.annee = v_annee AND t.mois = v_mois
        ), 0),
        -- CA cumul annee
        COALESCE((
            SELECT SUM(d.montant_ht)
            FROM silver.fact_document_commercial d
            JOIN silver.dim_temps t ON d.date_sk = t.date_key
            WHERE d.societe_sk = s.societe_sk
              AND d.type_document = 'FACTURE'
              AND t.annee = v_annee AND t.mois <= v_mois
        ), 0),
        -- Panier moyen
        COALESCE((
            SELECT AVG(d.montant_ht)
            FROM silver.fact_document_commercial d
            JOIN silver.dim_temps t ON d.date_sk = t.date_key
            WHERE d.societe_sk = s.societe_sk
              AND d.type_document = 'FACTURE'
              AND t.annee = v_annee AND t.mois = v_mois
        ), 0),
        -- Taux transformation (commandes/devis)
        COALESCE((
            SELECT
                CASE WHEN COUNT(CASE WHEN d.type_document = 'DEVIS' THEN 1 END) > 0 THEN
                    COUNT(CASE WHEN d.type_document = 'COMMANDE' THEN 1 END)::NUMERIC /
                    COUNT(CASE WHEN d.type_document = 'DEVIS' THEN 1 END) * 100
                ELSE 0 END
            FROM silver.fact_document_commercial d
            JOIN silver.dim_temps t ON d.date_sk = t.date_key
            WHERE d.societe_sk = s.societe_sk
              AND t.annee = v_annee
        ), 0),
        -- Marge brute (depuis agg_ca_affaire si disponible)
        COALESCE((SELECT SUM(marge_reelle) FROM gold.agg_ca_affaire WHERE societe_sk = s.societe_sk), 0),
        -- Taux marge
        COALESCE((SELECT AVG(taux_marge_reel) FROM gold.agg_ca_affaire WHERE societe_sk = s.societe_sk AND taux_marge_reel > 0), 0),
        -- Nb affaires en cours
        (SELECT COUNT(*) FROM silver.dim_affaire WHERE societe_sk = s.societe_sk AND etat IN ('EN_COURS', 'VALIDE') AND is_current = TRUE),
        -- Carnet commandes
        COALESCE((SELECT SUM(montant_commande) FROM silver.dim_affaire WHERE societe_sk = s.societe_sk AND etat IN ('EN_COURS', 'VALIDE') AND is_current = TRUE), 0),
        -- Reste a facturer
        COALESCE((SELECT SUM(montant_reste_a_facturer) FROM gold.agg_ca_affaire WHERE societe_sk = s.societe_sk AND montant_reste_a_facturer > 0), 0)
    FROM silver.dim_societe s
    WHERE s.is_current = TRUE;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    RAISE NOTICE 'KPIs societes inseres: %', v_rows_inserted;

    -- KPIs RH depuis agg_heures_salarie
    UPDATE gold.kpi_global k
    SET
        kpi_effectif_moyen = rh.effectif,
        kpi_heures_productives = rh.heures_prod,
        kpi_taux_occupation = rh.occupation,
        kpi_cout_mo_par_heure = rh.cout_horaire,
        kpi_ca_par_salarie = CASE WHEN rh.effectif > 0 THEN k.kpi_ca_mensuel / rh.effectif ELSE 0 END
    FROM (
        SELECT
            societe_sk, annee, mois,
            COUNT(DISTINCT salarie_sk) AS effectif,
            SUM(heures_productives) AS heures_prod,
            AVG(taux_occupation) AS occupation,
            AVG(NULLIF(cout_horaire_moyen, 0)) AS cout_horaire
        FROM gold.agg_heures_salarie
        GROUP BY societe_sk, annee, mois
    ) rh
    WHERE k.societe_sk = rh.societe_sk
      AND k.annee = rh.annee
      AND k.mois = rh.mois;

    -- KPIs Tresorerie
    UPDATE gold.kpi_global k
    SET
        kpi_tresorerie_nette = tr.solde_total,
        kpi_bfr = tr.bfr_estime
    FROM gold.agg_tresorerie tr
    WHERE k.societe_sk = tr.societe_sk
      AND k.annee = tr.annee
      AND k.mois = tr.mois;

    -- DSO moyen
    UPDATE gold.kpi_global k
    SET kpi_dso_jours = ba.dso_moyen
    FROM (
        SELECT societe_sk, AVG(dso_jours)::INTEGER AS dso_moyen
        FROM gold.agg_balance_agee_client
        WHERE date_calcul = CURRENT_DATE
        GROUP BY societe_sk
    ) ba
    WHERE k.societe_sk = ba.societe_sk
      AND k.annee = v_annee AND k.mois = v_mois;

    -- Affaires en retard / depassement
    UPDATE gold.kpi_global k
    SET
        kpi_nb_affaires_en_retard = alertes.retard,
        kpi_nb_affaires_en_depassement = alertes.depassement
    FROM (
        SELECT
            societe_sk,
            COUNT(CASE WHEN est_en_retard THEN 1 END) AS retard,
            COUNT(CASE WHEN est_en_depassement_budget THEN 1 END) AS depassement
        FROM gold.agg_ca_affaire
        GROUP BY societe_sk
    ) alertes
    WHERE k.societe_sk = alertes.societe_sk
      AND k.annee = v_annee AND k.mois = v_mois;

    -- Nb nouveaux clients ce mois
    UPDATE gold.kpi_global k
    SET kpi_nb_nouveaux_clients = nc.nb
    FROM (
        SELECT
            d.societe_sk,
            COUNT(DISTINCT d.client_sk) AS nb
        FROM silver.fact_document_commercial d
        JOIN silver.dim_temps t ON d.date_sk = t.date_key
        WHERE d.type_document = 'FACTURE'
          AND t.annee = v_annee AND t.mois = v_mois
          AND NOT EXISTS (
              SELECT 1 FROM silver.fact_document_commercial d2
              JOIN silver.dim_temps t2 ON d2.date_sk = t2.date_key
              WHERE d2.client_sk = d.client_sk
                AND d2.type_document = 'FACTURE'
                AND (t2.annee < v_annee OR (t2.annee = v_annee AND t2.mois < v_mois))
          )
        GROUP BY d.societe_sk
    ) nc
    WHERE k.societe_sk = nc.societe_sk
      AND k.annee = v_annee AND k.mois = v_mois;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_KPI_GLOBAL_V2: % societes traitees', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 4. DETECTION ANOMALIES AUTOMATIQUE
-- ============================================================================

\echo '=== CREATION DETECTION ANOMALIES ==='

CREATE OR REPLACE PROCEDURE etl.detect_anomalies()
LANGUAGE plpgsql
AS $$
DECLARE
    v_date_detection TIMESTAMP := CURRENT_TIMESTAMP;
    v_nb_anomalies INTEGER := 0;
BEGIN
    -- Supprimer les anomalies du jour (refresh quotidien)
    DELETE FROM gold.anomalie_detectee
    WHERE DATE(date_detection) = CURRENT_DATE;

    -- ========== ANOMALIES CLIENTS ==========

    -- 1. Clients a risque de churn eleve
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'RISQUE_CHURN_CLIENT',
        CASE WHEN f.probabilite_churn >= 0.8 THEN 'CRITICAL' ELSE 'HIGH' END,
        'COMMERCIAL',
        'CLIENT',
        c.client_sk,
        c.code,
        'Client a risque de churn: ' || c.raison_sociale,
        f.probabilite_churn * 100,
        50,
        (f.probabilite_churn - 0.5) / 0.5 * 100,
        jsonb_build_object(
            'client', c.raison_sociale,
            'ca_12m', f.ca_12m,
            'segment', f.segment_valeur,
            'tendance', f.tendance_ca,
            'derniere_commande_jours', f.recence_derniere_commande_jours
        ),
        'NOUVELLE'
    FROM gold.ml_features_client f
    JOIN silver.dim_client c ON f.client_sk = c.client_sk AND c.is_current = TRUE
    WHERE f.date_extraction = CURRENT_DATE
      AND f.probabilite_churn >= 0.5
      AND f.ca_12m > 5000;  -- Uniquement clients significatifs

    GET DIAGNOSTICS v_nb_anomalies = ROW_COUNT;
    RAISE NOTICE 'Anomalies churn clients: %', v_nb_anomalies;

    -- 2. Chute CA client brutale
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'CHUTE_CA_CLIENT',
        'HIGH',
        'COMMERCIAL',
        'CLIENT',
        c.client_sk,
        c.code,
        'Chute CA importante: ' || c.raison_sociale,
        f.ca_3m,
        f.ca_6m * 0.5,
        CASE WHEN f.ca_6m > 0 THEN (f.ca_6m * 0.5 - f.ca_3m) / (f.ca_6m * 0.5) * 100 ELSE 0 END,
        jsonb_build_object(
            'client', c.raison_sociale,
            'ca_3m', f.ca_3m,
            'ca_6m', f.ca_6m,
            'baisse_pct', CASE WHEN f.ca_6m > 0 THEN (1 - f.ca_3m / (f.ca_6m * 0.5)) * 100 ELSE 0 END
        ),
        'NOUVELLE'
    FROM gold.ml_features_client f
    JOIN silver.dim_client c ON f.client_sk = c.client_sk AND c.is_current = TRUE
    WHERE f.date_extraction = CURRENT_DATE
      AND f.tendance_ca = 'BAISSE_FORTE'
      AND f.ca_6m > 10000;

    -- ========== ANOMALIES AFFAIRES ==========

    -- 3. Depassement budget heures
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'DEPASSEMENT_HEURES_AFFAIRE',
        CASE WHEN h.ecart_heures_pct > 50 THEN 'CRITICAL'
             WHEN h.ecart_heures_pct > 25 THEN 'HIGH'
             ELSE 'MEDIUM' END,
        'OPERATIONS',
        'AFFAIRE',
        a.affaire_sk,
        a.code,
        'Depassement heures budget: ' || a.code || ' - ' || a.libelle,
        h.heures_realisees,
        h.heures_budget,
        h.ecart_heures_pct,
        jsonb_build_object(
            'affaire', a.libelle,
            'heures_budget', h.heures_budget,
            'heures_realisees', h.heures_realisees,
            'ecart_pct', h.ecart_heures_pct,
            'cout_mo', h.cout_mo_reel
        ),
        'NOUVELLE'
    FROM gold.agg_heures_affaire h
    JOIN silver.dim_affaire a ON h.affaire_sk = a.affaire_sk AND a.is_current = TRUE
    WHERE h.niveau_agregation = 'CUMUL'
      AND h.heures_budget > 0
      AND h.ecart_heures_pct > 10;

    -- 4. Marge affaire anormale
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'MARGE_ANORMALE_AFFAIRE',
        CASE WHEN aa.taux_marge_reel < 0 THEN 'CRITICAL'
             WHEN aa.taux_marge_reel < 10 THEN 'HIGH'
             ELSE 'MEDIUM' END,
        'FINANCE',
        'AFFAIRE',
        a.affaire_sk,
        a.code,
        'Marge anormale: ' || a.code,
        aa.taux_marge_reel,
        aa.taux_marge_prevu,
        aa.ecart_marge,
        jsonb_build_object(
            'affaire', a.libelle,
            'marge_prevue_pct', aa.taux_marge_prevu,
            'marge_reelle_pct', aa.taux_marge_reel,
            'montant_facture', aa.montant_facture,
            'cout_total', aa.cout_total_reel
        ),
        'NOUVELLE'
    FROM gold.agg_ca_affaire aa
    JOIN silver.dim_affaire a ON aa.affaire_sk = a.affaire_sk AND a.is_current = TRUE
    WHERE aa.montant_facture > 1000
      AND (aa.taux_marge_reel < 10 OR ABS(aa.ecart_marge) > aa.marge_prevue * 0.3);

    -- ========== ANOMALIES TRESORERIE ==========

    -- 5. Clients avec creances echues importantes
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'CREANCE_ECHUE_CLIENT',
        CASE WHEN ba.echu_plus_90j > 50000 THEN 'CRITICAL'
             WHEN ba.echu_plus_90j > 20000 THEN 'HIGH'
             ELSE 'MEDIUM' END,
        'TRESORERIE',
        'CLIENT',
        c.client_sk,
        c.code,
        'Creances echues importantes: ' || c.raison_sociale,
        ba.total_echu,
        10000,
        (ba.total_echu - 10000) / 10000 * 100,
        jsonb_build_object(
            'client', c.raison_sociale,
            'total_creances', ba.total_creances,
            'echu_0_30j', ba.echu_0_30j,
            'echu_31_60j', ba.echu_31_60j,
            'echu_61_90j', ba.echu_61_90j,
            'echu_plus_90j', ba.echu_plus_90j,
            'dso_jours', ba.dso_jours,
            'score_risque', ba.score_risque_credit
        ),
        'NOUVELLE'
    FROM gold.agg_balance_agee_client ba
    JOIN silver.dim_client c ON ba.client_sk = c.client_sk AND c.is_current = TRUE
    WHERE ba.date_calcul = CURRENT_DATE
      AND ba.total_echu > 10000;

    -- ========== ANOMALIES RH ==========

    -- 6. Salaries sous-occupes
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'SOUS_OCCUPATION_SALARIE',
        CASE WHEN h.taux_occupation < 50 THEN 'HIGH' ELSE 'MEDIUM' END,
        'RH',
        'SALARIE',
        s.salarie_sk,
        s.matricule,
        'Sous-occupation: ' || s.nom_complet,
        h.taux_occupation,
        70,
        (70 - h.taux_occupation) / 70 * 100,
        jsonb_build_object(
            'salarie', s.nom_complet,
            'heures_total', h.heures_total,
            'heures_productives', h.heures_productives,
            'nb_affaires', h.nb_affaires_travaillees,
            'poste', s.poste
        ),
        'NOUVELLE'
    FROM gold.agg_heures_salarie h
    JOIN silver.dim_salarie s ON h.salarie_sk = s.salarie_sk AND s.is_current = TRUE
    WHERE h.annee = EXTRACT(YEAR FROM CURRENT_DATE)
      AND h.mois = EXTRACT(MONTH FROM CURRENT_DATE)
      AND h.taux_occupation < 70
      AND h.heures_total > 0;

    -- ========== ANOMALIES STOCK ==========

    -- 7. Ruptures stock imminentes
    INSERT INTO gold.anomalie_detectee (
        date_detection, type_anomalie, severite, domaine,
        entite_type, entite_id, entite_code, description,
        valeur_detectee, valeur_seuil, ecart_pct, contexte, statut
    )
    SELECT
        v_date_detection,
        'RUPTURE_STOCK_IMMINENTE',
        CASE WHEN st.couverture_jours < 7 THEN 'CRITICAL' ELSE 'HIGH' END,
        'STOCK',
        'ELEMENT',
        e.element_sk,
        e.code,
        'Rupture imminente: ' || e.designation,
        st.couverture_jours,
        15,
        (15 - st.couverture_jours) / 15 * 100,
        jsonb_build_object(
            'element', e.designation,
            'stock_actuel', st.stock_final,
            'conso_mensuelle', st.conso_moyenne_mensuelle,
            'couverture_jours', st.couverture_jours,
            'depot', st.depot_code
        ),
        'NOUVELLE'
    FROM gold.agg_stock_element st
    JOIN silver.dim_element e ON st.element_sk = e.element_sk AND e.is_current = TRUE
    WHERE st.date_calcul = CURRENT_DATE
      AND st.couverture_jours < 15
      AND st.conso_moyenne_mensuelle > 0;

    -- Compter le total
    SELECT COUNT(*) INTO v_nb_anomalies
    FROM gold.anomalie_detectee
    WHERE DATE(date_detection) = CURRENT_DATE;

    RAISE NOTICE 'Total anomalies detectees: %', v_nb_anomalies;
END;
$$;

-- ============================================================================
-- 5. EXECUTION DES CORRECTIONS
-- ============================================================================

\echo '=== EXECUTION DES CORRECTIONS ==='

-- Appeler les nouvelles procedures
CALL etl.load_ml_features_client_v2();
CALL etl.load_kpi_global_v2();
CALL etl.detect_anomalies();

-- ============================================================================
-- 6. VERIFICATION DES RESULTATS
-- ============================================================================

\echo '=== VERIFICATION RESULTATS ==='

-- Verifier ML Features Client
SELECT 'ML Features Client' AS check_name,
       COUNT(*) AS total,
       COUNT(CASE WHEN ca_12m > 0 THEN 1 END) AS avec_ca,
       AVG(score_rfm)::INTEGER AS score_rfm_moyen,
       AVG(probabilite_churn)::NUMERIC(3,2) AS churn_moyen
FROM gold.ml_features_client
WHERE date_extraction = CURRENT_DATE;

-- Distribution segments
SELECT segment_valeur, segment_comportement, COUNT(*) AS nb
FROM gold.ml_features_client
WHERE date_extraction = CURRENT_DATE
GROUP BY segment_valeur, segment_comportement
ORDER BY segment_valeur, segment_comportement;

-- Verifier KPI Global
SELECT 'KPI Global' AS check_name,
       societe_sk,
       kpi_ca_mensuel,
       kpi_ca_cumul,
       kpi_taux_marge,
       kpi_nb_affaires_en_cours
FROM gold.kpi_global
WHERE annee = EXTRACT(YEAR FROM CURRENT_DATE)
  AND mois = EXTRACT(MONTH FROM CURRENT_DATE);

-- Verifier Anomalies
SELECT type_anomalie, severite, COUNT(*) AS nb
FROM gold.anomalie_detectee
WHERE DATE(date_detection) = CURRENT_DATE
GROUP BY type_anomalie, severite
ORDER BY severite, type_anomalie;

\echo '=== SCRIPT 15 TERMINE ==='

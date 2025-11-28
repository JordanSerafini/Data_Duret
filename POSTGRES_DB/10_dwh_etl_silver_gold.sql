-- ============================================================================
-- ETL PROCEDURES : SILVER -> GOLD
-- Agregation et calcul des KPIs metier
-- ============================================================================

\c dwh_groupe_duret;

-- ============================================================================
-- 1. AGREGATION CA PAR PERIODE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_ca_periode()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_CA_PERIODE', 'SILVER', 'GOLD');

    -- Truncate et rechargement complet (plus simple pour les agregats)
    TRUNCATE TABLE gold.agg_ca_periode;

    -- Agregation mensuelle
    INSERT INTO gold.agg_ca_periode (
        societe_sk, annee, mois, trimestre, niveau_agregation,
        date_debut, date_fin, ca_devis, ca_commande, ca_facture, ca_avoir,
        nb_devis, nb_commandes, nb_factures, nb_avoirs,
        nb_clients_actifs, nb_affaires_actives, panier_moyen, taux_transformation
    )
    SELECT
        d.societe_sk,
        t.annee,
        t.mois,
        t.trimestre,
        'MOIS',
        MIN(t.date_complete),
        MAX(t.date_complete),
        SUM(CASE WHEN d.type_document = 'DEVIS' THEN d.montant_ht ELSE 0 END),
        SUM(CASE WHEN d.type_document = 'COMMANDE' THEN d.montant_ht ELSE 0 END),
        SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END),
        SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END),
        COUNT(CASE WHEN d.type_document = 'DEVIS' THEN 1 END),
        COUNT(CASE WHEN d.type_document = 'COMMANDE' THEN 1 END),
        COUNT(CASE WHEN d.type_document = 'FACTURE' THEN 1 END),
        COUNT(CASE WHEN d.type_document = 'AVOIR' THEN 1 END),
        COUNT(DISTINCT d.client_sk),
        COUNT(DISTINCT d.affaire_sk),
        AVG(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht END),
        CASE
            WHEN COUNT(CASE WHEN d.type_document = 'DEVIS' THEN 1 END) > 0
            THEN COUNT(CASE WHEN d.type_document = 'COMMANDE' THEN 1 END)::NUMERIC /
                 COUNT(CASE WHEN d.type_document = 'DEVIS' THEN 1 END) * 100
            ELSE 0
        END
    FROM silver.fact_document_commercial d
    JOIN silver.dim_temps t ON d.date_sk = t.date_key
    WHERE d.societe_sk IS NOT NULL
    GROUP BY d.societe_sk, t.annee, t.mois, t.trimestre;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Agregation trimestrielle
    INSERT INTO gold.agg_ca_periode (
        societe_sk, annee, trimestre, niveau_agregation,
        date_debut, date_fin, ca_devis, ca_commande, ca_facture, ca_avoir,
        nb_devis, nb_commandes, nb_factures, nb_avoirs,
        nb_clients_actifs, nb_affaires_actives, panier_moyen, taux_transformation
    )
    SELECT
        societe_sk,
        annee,
        trimestre,
        'TRIMESTRE',
        MIN(date_debut),
        MAX(date_fin),
        SUM(ca_devis),
        SUM(ca_commande),
        SUM(ca_facture),
        SUM(ca_avoir),
        SUM(nb_devis),
        SUM(nb_commandes),
        SUM(nb_factures),
        SUM(nb_avoirs),
        MAX(nb_clients_actifs), -- Approximation
        MAX(nb_affaires_actives),
        AVG(panier_moyen),
        CASE WHEN SUM(nb_devis) > 0 THEN SUM(nb_commandes)::NUMERIC / SUM(nb_devis) * 100 ELSE 0 END
    FROM gold.agg_ca_periode
    WHERE niveau_agregation = 'MOIS'
    GROUP BY societe_sk, annee, trimestre;

    -- Agregation annuelle
    INSERT INTO gold.agg_ca_periode (
        societe_sk, annee, niveau_agregation,
        date_debut, date_fin, ca_devis, ca_commande, ca_facture, ca_avoir,
        nb_devis, nb_commandes, nb_factures, nb_avoirs,
        nb_clients_actifs, nb_affaires_actives, panier_moyen, taux_transformation
    )
    SELECT
        societe_sk,
        annee,
        'ANNEE',
        MIN(date_debut),
        MAX(date_fin),
        SUM(ca_devis),
        SUM(ca_commande),
        SUM(ca_facture),
        SUM(ca_avoir),
        SUM(nb_devis),
        SUM(nb_commandes),
        SUM(nb_factures),
        SUM(nb_avoirs),
        MAX(nb_clients_actifs),
        MAX(nb_affaires_actives),
        AVG(panier_moyen),
        CASE WHEN SUM(nb_devis) > 0 THEN SUM(nb_commandes)::NUMERIC / SUM(nb_devis) * 100 ELSE 0 END
    FROM gold.agg_ca_periode
    WHERE niveau_agregation = 'TRIMESTRE'
    GROUP BY societe_sk, annee;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_CA_PERIODE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 2. AGREGATION CA PAR CLIENT
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_ca_client()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_CA_CLIENT', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_ca_client;

    -- CA par client et annee
    INSERT INTO gold.agg_ca_client (
        societe_sk, client_sk, annee, ca_cumule, nb_affaires, nb_factures,
        nb_avoirs, marge_brute, encours_actuel
    )
    SELECT
        d.societe_sk,
        d.client_sk,
        t.annee,
        SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht
                 WHEN d.type_document = 'AVOIR' THEN -d.montant_ht
                 ELSE 0 END),
        COUNT(DISTINCT d.affaire_sk),
        COUNT(CASE WHEN d.type_document = 'FACTURE' THEN 1 END),
        COUNT(CASE WHEN d.type_document = 'AVOIR' THEN 1 END),
        0, -- Marge a calculer separement
        0  -- Encours a calculer separement
    FROM silver.fact_document_commercial d
    JOIN silver.dim_temps t ON d.date_sk = t.date_key
    WHERE d.client_sk IS NOT NULL
    AND d.type_document IN ('FACTURE', 'AVOIR')
    GROUP BY d.societe_sk, d.client_sk, t.annee;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul CA N-1
    UPDATE gold.agg_ca_client c
    SET ca_n_moins_1 = prev.ca_cumule,
        variation_ca_pct = CASE
            WHEN prev.ca_cumule > 0 THEN ((c.ca_cumule - prev.ca_cumule) / prev.ca_cumule * 100)
            ELSE NULL
        END
    FROM gold.agg_ca_client prev
    WHERE c.client_sk = prev.client_sk
    AND c.societe_sk = prev.societe_sk
    AND c.annee = prev.annee + 1;

    -- Calcul des segments CA
    UPDATE gold.agg_ca_client
    SET segment_ca = CASE
        WHEN ca_cumule >= 100000 THEN 'A'
        WHEN ca_cumule >= 50000 THEN 'B'
        WHEN ca_cumule >= 10000 THEN 'C'
        ELSE 'D'
    END;

    -- Score fidelite (base sur nb affaires et anciennete)
    UPDATE gold.agg_ca_client ac
    SET score_fidelite = LEAST(100, (
        nb_affaires * 10 +
        COALESCE((SELECT COUNT(DISTINCT t.annee) FROM gold.agg_ca_client sub
         JOIN silver.dim_temps t ON TRUE
         WHERE sub.client_sk = ac.client_sk) * 5, 0)
    ));

    -- Potentiel croissance
    UPDATE gold.agg_ca_client
    SET potentiel_croissance = CASE
        WHEN variation_ca_pct > 20 THEN 'FORT'
        WHEN variation_ca_pct > 0 THEN 'MOYEN'
        ELSE 'FAIBLE'
    END
    WHERE variation_ca_pct IS NOT NULL;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_CA_CLIENT: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 3. AGREGATION CA PAR AFFAIRE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_ca_affaire()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_CA_AFFAIRE', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_ca_affaire;

    -- Agregation par affaire (utilise sous-requetes pour eviter produit cartesien)
    INSERT INTO gold.agg_ca_affaire (
        affaire_sk, societe_sk, client_sk,
        montant_devis, montant_commande, montant_facture, montant_avoir,
        heures_budget, heures_realisees,
        avancement_facturation_pct, avancement_travaux_pct
    )
    SELECT
        a.affaire_sk,
        a.societe_sk,
        a.client_sk,
        a.montant_devis,
        a.montant_commande,
        COALESCE(doc.montant_facture, 0),
        COALESCE(doc.montant_avoir, 0),
        a.budget_heures,
        COALESCE(mo.heures_total, 0),
        CASE WHEN a.montant_commande > 0 THEN
            COALESCE(doc.montant_facture, 0) / a.montant_commande * 100
        ELSE 0 END,
        CASE WHEN a.budget_heures > 0 THEN
            COALESCE(mo.heures_total, 0) / a.budget_heures * 100
        ELSE 0 END
    FROM silver.dim_affaire a
    LEFT JOIN (
        SELECT affaire_sk,
               SUM(CASE WHEN type_document = 'FACTURE' THEN montant_ht ELSE 0 END) AS montant_facture,
               SUM(CASE WHEN type_document = 'AVOIR' THEN montant_ht ELSE 0 END) AS montant_avoir
        FROM silver.fact_document_commercial
        GROUP BY affaire_sk
    ) doc ON doc.affaire_sk = a.affaire_sk
    LEFT JOIN (
        SELECT affaire_sk, SUM(heures_total) AS heures_total
        FROM silver.fact_suivi_mo
        GROUP BY affaire_sk
    ) mo ON mo.affaire_sk = a.affaire_sk
    WHERE a.is_current = TRUE;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul des couts MO
    UPDATE gold.agg_ca_affaire aa
    SET cout_mo_reel = mo_data.cout_total
    FROM (
        SELECT affaire_sk, SUM(cout_total) AS cout_total
        FROM silver.fact_suivi_mo
        GROUP BY affaire_sk
    ) mo_data
    WHERE aa.affaire_sk = mo_data.affaire_sk;

    -- Calcul des marges
    UPDATE gold.agg_ca_affaire
    SET cout_total_reel = COALESCE(cout_mo_reel, 0) + COALESCE(cout_achats_reel, 0) + COALESCE(cout_sous_traitance_reel, 0),
        marge_reelle = (montant_facture - montant_avoir) - COALESCE(cout_mo_reel, 0) - COALESCE(cout_achats_reel, 0),
        taux_marge_reel = CASE
            WHEN (montant_facture - montant_avoir) > 0 THEN
                ((montant_facture - montant_avoir) - COALESCE(cout_mo_reel, 0) - COALESCE(cout_achats_reel, 0)) /
                (montant_facture - montant_avoir) * 100
            ELSE 0
        END;

    -- Calcul marge prevue
    UPDATE gold.agg_ca_affaire aa
    SET marge_prevue = aa.montant_commande * COALESCE(a.marge_prevue_pct, 20) / 100,
        taux_marge_prevu = COALESCE(a.marge_prevue_pct, 20),
        cout_mo_prevu = aa.heures_budget * 45 -- Cout horaire moyen estime
    FROM silver.dim_affaire a
    WHERE aa.affaire_sk = a.affaire_sk AND a.is_current = TRUE;

    -- Calcul productivite
    UPDATE gold.agg_ca_affaire
    SET productivite_pct = CASE
        WHEN heures_budget > 0 AND heures_realisees > 0 THEN
            (heures_budget / heures_realisees) * 100
        ELSE NULL
    END;

    -- Detection des alertes
    UPDATE gold.agg_ca_affaire
    SET est_en_depassement_budget = (heures_realisees > heures_budget * 1.1),
        est_en_retard = FALSE; -- A calculer avec les dates

    -- Niveau de risque
    UPDATE gold.agg_ca_affaire
    SET niveau_risque = CASE
        WHEN est_en_depassement_budget AND taux_marge_reel < 10 THEN 'CRITIQUE'
        WHEN est_en_depassement_budget OR taux_marge_reel < 15 THEN 'ELEVE'
        WHEN heures_realisees > heures_budget * 0.9 THEN 'MOYEN'
        ELSE 'FAIBLE'
    END;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_CA_AFFAIRE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 4. AGREGATION BALANCE COMPTABLE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_balance_compte()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_BALANCE', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_balance_compte;

    INSERT INTO gold.agg_balance_compte (
        societe_sk, compte_sk, annee, mois,
        mouvement_debit, mouvement_credit, nb_ecritures
    )
    SELECT
        e.societe_sk,
        e.compte_sk,
        t.annee,
        t.mois,
        SUM(e.montant_debit),
        SUM(e.montant_credit),
        COUNT(*)
    FROM silver.fact_ecriture_compta e
    JOIN silver.dim_temps t ON e.date_sk = t.date_key
    WHERE e.compte_sk IS NOT NULL
    GROUP BY e.societe_sk, e.compte_sk, t.annee, t.mois;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul des soldes de cloture
    UPDATE gold.agg_balance_compte
    SET solde_debit_cloture = solde_debit_ouverture + mouvement_debit,
        solde_credit_cloture = solde_credit_ouverture + mouvement_credit;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_BALANCE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 5. AGREGATION TRESORERIE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_tresorerie()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_TRESORERIE', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_tresorerie;

    -- Agregation mensuelle depuis les ecritures comptables
    INSERT INTO gold.agg_tresorerie (
        societe_sk, annee, mois, niveau_agregation,
        encaissements, decaissements
    )
    SELECT
        e.societe_sk,
        t.annee,
        t.mois,
        'MOIS',
        SUM(CASE WHEN c.classe = '5' AND e.montant_debit > 0 THEN e.montant_debit ELSE 0 END),
        SUM(CASE WHEN c.classe = '5' AND e.montant_credit > 0 THEN e.montant_credit ELSE 0 END)
    FROM silver.fact_ecriture_compta e
    JOIN silver.dim_temps t ON e.date_sk = t.date_key
    JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk AND c.is_current = TRUE
    WHERE c.classe = '5'
    GROUP BY e.societe_sk, t.annee, t.mois;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul des creances clients (comptes 41x)
    UPDATE gold.agg_tresorerie tr
    SET creances_clients = creances.total
    FROM (
        SELECT
            e.societe_sk, t.annee, t.mois,
            SUM(e.montant_debit - e.montant_credit) AS total
        FROM silver.fact_ecriture_compta e
        JOIN silver.dim_temps t ON e.date_sk = t.date_key
        JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk
        WHERE c.numero LIKE '41%'
        GROUP BY e.societe_sk, t.annee, t.mois
    ) creances
    WHERE tr.societe_sk = creances.societe_sk
    AND tr.annee = creances.annee
    AND tr.mois = creances.mois;

    -- Calcul des dettes fournisseurs (comptes 40x)
    UPDATE gold.agg_tresorerie tr
    SET dettes_fournisseurs = dettes.total
    FROM (
        SELECT
            e.societe_sk, t.annee, t.mois,
            SUM(e.montant_credit - e.montant_debit) AS total
        FROM silver.fact_ecriture_compta e
        JOIN silver.dim_temps t ON e.date_sk = t.date_key
        JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk
        WHERE c.numero LIKE '40%'
        GROUP BY e.societe_sk, t.annee, t.mois
    ) dettes
    WHERE tr.societe_sk = dettes.societe_sk
    AND tr.annee = dettes.annee
    AND tr.mois = dettes.mois;

    -- Estimation BFR
    UPDATE gold.agg_tresorerie
    SET bfr_estime = COALESCE(creances_clients, 0) - COALESCE(dettes_fournisseurs, 0);

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_TRESORERIE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 6. AGREGATION BALANCE AGEE CLIENTS
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_balance_agee_client()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_calcul DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_BALANCE_AGEE', 'SILVER', 'GOLD');

    -- Supprimer les anciens calculs du jour
    DELETE FROM gold.agg_balance_agee_client WHERE date_calcul = v_date_calcul;

    -- Calcul de la balance agee par client
    INSERT INTO gold.agg_balance_agee_client (
        societe_sk, client_sk, date_calcul,
        non_echu, echu_0_30j, echu_31_60j, echu_61_90j, echu_plus_90j,
        dso_jours, score_risque_credit
    )
    SELECT
        e.societe_sk,
        e.client_sk,
        v_date_calcul,
        SUM(CASE WHEN e.date_echeance >= v_date_calcul THEN e.montant_solde ELSE 0 END),
        SUM(CASE WHEN e.date_echeance < v_date_calcul
                  AND e.date_echeance >= v_date_calcul - INTERVAL '30 days'
                 THEN e.montant_solde ELSE 0 END),
        SUM(CASE WHEN e.date_echeance < v_date_calcul - INTERVAL '30 days'
                  AND e.date_echeance >= v_date_calcul - INTERVAL '60 days'
                 THEN e.montant_solde ELSE 0 END),
        SUM(CASE WHEN e.date_echeance < v_date_calcul - INTERVAL '60 days'
                  AND e.date_echeance >= v_date_calcul - INTERVAL '90 days'
                 THEN e.montant_solde ELSE 0 END),
        SUM(CASE WHEN e.date_echeance < v_date_calcul - INTERVAL '90 days'
                 THEN e.montant_solde ELSE 0 END),
        0, -- DSO a calculer
        0  -- Score a calculer
    FROM silver.fact_ecriture_compta e
    JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk
    WHERE c.numero LIKE '41%'
    AND e.est_lettre = FALSE
    AND e.client_sk IS NOT NULL
    AND e.montant_solde != 0
    GROUP BY e.societe_sk, e.client_sk;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul du DSO (Days Sales Outstanding)
    UPDATE gold.agg_balance_agee_client ba
    SET dso_jours = COALESCE(dso.dso, 0)
    FROM (
        SELECT
            client_sk,
            CASE WHEN SUM(montant_ht) > 0 THEN
                (SUM(total_creances) / (SUM(montant_ht) / 365))::INTEGER
            ELSE 0 END AS dso
        FROM (
            SELECT
                d.client_sk,
                d.montant_ht,
                0 AS total_creances
            FROM silver.fact_document_commercial d
            JOIN silver.dim_temps t ON d.date_sk = t.date_key
            WHERE d.type_document = 'FACTURE'
            AND t.annee = EXTRACT(YEAR FROM CURRENT_DATE)
            UNION ALL
            SELECT
                ba2.client_sk,
                0 AS montant_ht,
                ba2.total_creances
            FROM gold.agg_balance_agee_client ba2
            WHERE ba2.date_calcul = v_date_calcul
        ) sub
        GROUP BY client_sk
    ) dso
    WHERE ba.client_sk = dso.client_sk
    AND ba.date_calcul = v_date_calcul;

    -- Calcul du score risque credit (0-100)
    UPDATE gold.agg_balance_agee_client
    SET score_risque_credit = LEAST(100, GREATEST(0,
        CASE
            WHEN total_creances = 0 THEN 0
            ELSE
                (COALESCE(echu_plus_90j, 0) / NULLIF(total_creances, 0) * 50 +
                 COALESCE(echu_61_90j, 0) / NULLIF(total_creances, 0) * 30 +
                 COALESCE(echu_31_60j, 0) / NULLIF(total_creances, 0) * 15 +
                 COALESCE(echu_0_30j, 0) / NULLIF(total_creances, 0) * 5) * 100
        END
    )::INTEGER)
    WHERE date_calcul = v_date_calcul;

    -- Taux de recouvrement
    UPDATE gold.agg_balance_agee_client
    SET taux_recouvrement = CASE
        WHEN total_creances > 0 THEN (non_echu / total_creances * 100)
        ELSE 100
    END
    WHERE date_calcul = v_date_calcul;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_BALANCE_AGEE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 7. AGREGATION HEURES PAR SALARIE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_heures_salarie()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_HEURES_SALARIE', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_heures_salarie;

    INSERT INTO gold.agg_heures_salarie (
        societe_sk, salarie_sk, annee, mois,
        heures_normales, heures_supplementaires, heures_total,
        heures_theoriques, taux_occupation,
        heures_productives, heures_non_productives, taux_productivite,
        nb_affaires_travaillees,
        cout_brut, cout_charge, indemnites, cout_total, cout_horaire_moyen
    )
    SELECT
        mo.societe_sk,
        mo.salarie_sk,
        t.annee,
        t.mois,
        SUM(mo.heures_normales),
        SUM(mo.heures_supp_25 + mo.heures_supp_50),
        SUM(mo.heures_total),
        151.67 * COUNT(DISTINCT t.semaine_iso) / 4, -- Heures theoriques mensuelles
        CASE WHEN 151.67 > 0 THEN SUM(mo.heures_normales) / 151.67 * 100 ELSE 0 END,
        SUM(CASE WHEN mo.affaire_sk IS NOT NULL THEN mo.heures_total ELSE 0 END),
        SUM(CASE WHEN mo.affaire_sk IS NULL THEN mo.heures_total ELSE 0 END),
        CASE WHEN SUM(mo.heures_total) > 0 THEN
            SUM(CASE WHEN mo.affaire_sk IS NOT NULL THEN mo.heures_total ELSE 0 END) / SUM(mo.heures_total) * 100
        ELSE 0 END,
        COUNT(DISTINCT mo.affaire_sk),
        SUM(mo.heures_total * COALESCE(s.taux_horaire, 15)),
        SUM(mo.cout_total),
        SUM(mo.indemnites_total),
        SUM(mo.cout_total) + SUM(mo.indemnites_total),
        CASE WHEN SUM(mo.heures_total) > 0 THEN
            (SUM(mo.cout_total) + SUM(mo.indemnites_total)) / SUM(mo.heures_total)
        ELSE 0 END
    FROM silver.fact_suivi_mo mo
    JOIN silver.dim_temps t ON mo.date_sk = t.date_key
    LEFT JOIN silver.dim_salarie s ON mo.salarie_sk = s.salarie_sk AND s.is_current = TRUE
    WHERE mo.salarie_sk IS NOT NULL
    GROUP BY mo.societe_sk, mo.salarie_sk, t.annee, t.mois;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_HEURES_SALARIE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 8. AGREGATION HEURES PAR AFFAIRE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_heures_affaire()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_HEURES_AFFAIRE', 'SILVER', 'GOLD');

    TRUNCATE TABLE gold.agg_heures_affaire;

    -- Agregation mensuelle
    INSERT INTO gold.agg_heures_affaire (
        affaire_sk, societe_sk, annee, mois, niveau_agregation,
        heures_realisees, nb_salaries, nb_jours_travailles, cout_mo_reel
    )
    SELECT
        mo.affaire_sk,
        mo.societe_sk,
        t.annee,
        t.mois,
        'MOIS',
        SUM(mo.heures_total),
        COUNT(DISTINCT mo.salarie_sk),
        COUNT(DISTINCT t.date_complete),
        SUM(mo.cout_total)
    FROM silver.fact_suivi_mo mo
    JOIN silver.dim_temps t ON mo.date_sk = t.date_key
    WHERE mo.affaire_sk IS NOT NULL
    GROUP BY mo.affaire_sk, mo.societe_sk, t.annee, t.mois;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Agregation cumul
    INSERT INTO gold.agg_heures_affaire (
        affaire_sk, societe_sk, niveau_agregation,
        heures_budget, heures_realisees, nb_salaries, cout_mo_budget, cout_mo_reel,
        ratio_heures_ca
    )
    SELECT
        a.affaire_sk,
        a.societe_sk,
        'CUMUL',
        a.budget_heures,
        COALESCE(SUM(h.heures_realisees), 0),
        MAX(h.nb_salaries),
        a.budget_heures * 45, -- Cout horaire moyen
        COALESCE(SUM(h.cout_mo_reel), 0),
        CASE WHEN a.montant_commande > 0 THEN COALESCE(SUM(h.heures_realisees), 0) / a.montant_commande ELSE 0 END
    FROM silver.dim_affaire a
    LEFT JOIN gold.agg_heures_affaire h ON h.affaire_sk = a.affaire_sk AND h.niveau_agregation = 'MOIS'
    WHERE a.is_current = TRUE
    GROUP BY a.affaire_sk, a.societe_sk, a.budget_heures, a.montant_commande;

    -- Calcul des ecarts
    UPDATE gold.agg_heures_affaire
    SET ecart_heures_pct = CASE
        WHEN heures_budget > 0 THEN (heures_realisees - heures_budget) / heures_budget * 100
        ELSE 0
    END
    WHERE niveau_agregation = 'CUMUL';

    -- Productivite theorique vs reelle
    UPDATE gold.agg_heures_affaire h
    SET productivite_theorique = CASE WHEN a.budget_heures > 0 THEN a.montant_commande / a.budget_heures ELSE 0 END,
        productivite_reelle = CASE WHEN h.heures_realisees > 0 THEN
            (SELECT COALESCE(SUM(d.montant_ht), 0) FROM silver.fact_document_commercial d
             WHERE d.affaire_sk = h.affaire_sk AND d.type_document = 'FACTURE') / h.heures_realisees
        ELSE 0 END
    FROM silver.dim_affaire a
    WHERE h.affaire_sk = a.affaire_sk
    AND a.is_current = TRUE
    AND h.niveau_agregation = 'CUMUL';

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_HEURES_AFFAIRE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 9. AGREGATION STOCK
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_agg_stock_element()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_calcul DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_AGG_STOCK', 'SILVER', 'GOLD');

    -- Supprimer les anciens calculs du jour
    DELETE FROM gold.agg_stock_element WHERE date_calcul = v_date_calcul;

    -- Calcul du stock par element et depot
    INSERT INTO gold.agg_stock_element (
        societe_sk, element_sk, depot_code, date_calcul,
        entrees, sorties, valeur_stock
    )
    SELECT
        m.societe_sk,
        m.element_sk,
        m.depot_code,
        v_date_calcul,
        SUM(m.quantite_entree),
        SUM(m.quantite_sortie),
        SUM(m.valeur_mouvement)
    FROM silver.fact_mouvement_stock m
    WHERE m.element_sk IS NOT NULL
    GROUP BY m.societe_sk, m.element_sk, m.depot_code;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul du stock final
    UPDATE gold.agg_stock_element
    SET stock_initial = 0; -- A initialiser avec l'inventaire

    -- Prix moyen pondere
    UPDATE gold.agg_stock_element s
    SET prix_moyen_pondere = CASE
        WHEN stock_final > 0 THEN valeur_stock / stock_final
        ELSE 0
    END
    WHERE date_calcul = v_date_calcul;

    -- Consommation moyenne mensuelle (sur 3 derniers mois)
    UPDATE gold.agg_stock_element s
    SET conso_moyenne_mensuelle = conso.moyenne
    FROM (
        SELECT
            element_sk, depot_code,
            AVG(sorties) AS moyenne
        FROM gold.agg_stock_element
        WHERE date_calcul >= v_date_calcul - INTERVAL '90 days'
        GROUP BY element_sk, depot_code
    ) conso
    WHERE s.element_sk = conso.element_sk
    AND s.depot_code = conso.depot_code
    AND s.date_calcul = v_date_calcul;

    -- Couverture en jours
    UPDATE gold.agg_stock_element
    SET couverture_jours = CASE
        WHEN conso_moyenne_mensuelle > 0 THEN (stock_final / (conso_moyenne_mensuelle / 30))::INTEGER
        ELSE 999
    END
    WHERE date_calcul = v_date_calcul;

    -- Rotation stock (annualisee)
    UPDATE gold.agg_stock_element
    SET rotation_stock = CASE
        WHEN stock_final > 0 THEN (sorties * 12 / stock_final)
        ELSE 0
    END
    WHERE date_calcul = v_date_calcul;

    -- Alertes stock
    UPDATE gold.agg_stock_element s
    SET stock_minimum = e.prix_achat_standard * 10, -- Stock mini = 10 unites
        est_sous_stock_mini = stock_final < 10,
        est_surstock = couverture_jours > 180
    FROM silver.dim_element e
    WHERE s.element_sk = e.element_sk
    AND e.is_current = TRUE
    AND s.date_calcul = v_date_calcul;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_AGG_STOCK: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 10. CALCUL DES KPIs GLOBAUX
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_kpi_global()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_annee INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_mois INTEGER := EXTRACT(MONTH FROM CURRENT_DATE);
BEGIN
    v_job_id := etl.start_job('LOAD_KPI_GLOBAL', 'GOLD', 'GOLD');

    -- Supprimer les KPIs existants pour le mois en cours
    DELETE FROM gold.kpi_global WHERE annee = v_annee AND mois = v_mois;

    -- Insertion des KPIs par societe
    INSERT INTO gold.kpi_global (
        societe_sk, annee, mois,
        kpi_ca_mensuel, kpi_ca_cumul, kpi_ca_variation_n1_pct,
        kpi_panier_moyen, kpi_taux_transformation,
        kpi_marge_brute, kpi_taux_marge,
        kpi_nb_affaires_en_cours, kpi_carnet_commandes, kpi_reste_a_facturer
    )
    SELECT
        s.societe_sk,
        v_annee,
        v_mois,
        -- CA mensuel
        COALESCE((SELECT ca_facture - ca_avoir FROM gold.agg_ca_periode
                  WHERE societe_sk = s.societe_sk AND annee = v_annee AND mois = v_mois
                  AND niveau_agregation = 'MOIS'), 0),
        -- CA cumul
        COALESCE((SELECT SUM(ca_facture - ca_avoir) FROM gold.agg_ca_periode
                  WHERE societe_sk = s.societe_sk AND annee = v_annee AND mois <= v_mois
                  AND niveau_agregation = 'MOIS'), 0),
        -- Variation N-1
        NULL,
        -- Panier moyen
        COALESCE((SELECT panier_moyen FROM gold.agg_ca_periode
                  WHERE societe_sk = s.societe_sk AND annee = v_annee AND mois = v_mois
                  AND niveau_agregation = 'MOIS'), 0),
        -- Taux transformation
        COALESCE((SELECT taux_transformation FROM gold.agg_ca_periode
                  WHERE societe_sk = s.societe_sk AND annee = v_annee AND mois = v_mois
                  AND niveau_agregation = 'MOIS'), 0),
        -- Marge brute
        COALESCE((SELECT SUM(marge_reelle) FROM gold.agg_ca_affaire
                  WHERE societe_sk = s.societe_sk), 0),
        -- Taux marge
        COALESCE((SELECT AVG(taux_marge_reel) FROM gold.agg_ca_affaire
                  WHERE societe_sk = s.societe_sk AND taux_marge_reel IS NOT NULL), 0),
        -- Nb affaires en cours
        (SELECT COUNT(*) FROM silver.dim_affaire
         WHERE societe_sk = s.societe_sk AND etat_groupe = 'EN_COURS' AND is_current = TRUE),
        -- Carnet commandes
        COALESCE((SELECT SUM(montant_commande) FROM silver.dim_affaire
                  WHERE societe_sk = s.societe_sk AND etat_groupe = 'EN_COURS' AND is_current = TRUE), 0),
        -- Reste a facturer
        COALESCE((SELECT SUM(montant_reste_a_facturer) FROM gold.agg_ca_affaire
                  WHERE societe_sk = s.societe_sk AND montant_reste_a_facturer > 0), 0)
    FROM silver.dim_societe s
    WHERE s.is_current = TRUE;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul variation N-1
    UPDATE gold.kpi_global k
    SET kpi_ca_variation_n1_pct = CASE
        WHEN prev.kpi_ca_cumul > 0 THEN ((k.kpi_ca_cumul - prev.kpi_ca_cumul) / prev.kpi_ca_cumul * 100)
        ELSE NULL
    END
    FROM gold.kpi_global prev
    WHERE k.societe_sk = prev.societe_sk
    AND k.annee = prev.annee + 1
    AND k.mois = prev.mois;

    -- KPIs RH
    UPDATE gold.kpi_global k
    SET kpi_effectif_moyen = rh.effectif,
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
            AVG(cout_horaire_moyen) AS cout_horaire
        FROM gold.agg_heures_salarie
        GROUP BY societe_sk, annee, mois
    ) rh
    WHERE k.societe_sk = rh.societe_sk
    AND k.annee = rh.annee
    AND k.mois = rh.mois;

    -- KPIs Tresorerie
    UPDATE gold.kpi_global k
    SET kpi_tresorerie_nette = tr.solde_total,
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
    SET kpi_nb_affaires_en_retard = alertes.retard,
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

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_KPI_GLOBAL: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 11. CHARGEMENT FEATURES ML
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_ml_features_client()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_extraction DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_ML_FEATURES_CLIENT', 'GOLD', 'GOLD');

    -- Supprimer les features du jour
    DELETE FROM gold.ml_features_client WHERE date_extraction = v_date_extraction;

    -- Calcul des features clients
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
        MIN(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht END),
        COALESCE(EXTRACT(MONTH FROM AGE(CURRENT_DATE, MIN(t.date_complete)))::INTEGER, 0),
        COUNT(DISTINCT d.affaire_sk)
    FROM silver.dim_client c
    LEFT JOIN silver.fact_document_commercial d ON d.client_sk = c.client_sk
    LEFT JOIN silver.dim_temps t ON d.date_sk = t.date_key
    WHERE c.is_current = TRUE
    GROUP BY c.client_sk;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul tendance CA
    UPDATE gold.ml_features_client
    SET tendance_ca = CASE
        WHEN ca_3m > ca_6m * 0.6 THEN 'HAUSSE'
        WHEN ca_3m < ca_6m * 0.4 THEN 'BAISSE'
        ELSE 'STABLE'
    END
    WHERE date_extraction = v_date_extraction;

    -- Frequence et recence
    UPDATE gold.ml_features_client f
    SET frequence_commande_jours = freq.freq,
        recence_derniere_commande_jours = freq.recence
    FROM (
        SELECT
            d.client_sk,
            CASE WHEN COUNT(*) > 1 AND MAX(t.date_complete) IS NOT NULL AND MIN(t.date_complete) IS NOT NULL THEN
                (MAX(t.date_complete) - MIN(t.date_complete))::NUMERIC / (COUNT(*) - 1)
            ELSE 365 END AS freq,
            CASE WHEN MAX(t.date_complete) IS NOT NULL THEN
                (CURRENT_DATE - MAX(t.date_complete))::INTEGER
            ELSE 365 END AS recence
        FROM silver.fact_document_commercial d
        JOIN silver.dim_temps t ON d.date_sk = t.date_key
        WHERE d.type_document = 'FACTURE' AND d.client_sk IS NOT NULL
        GROUP BY d.client_sk
    ) freq
    WHERE f.client_sk = freq.client_sk
    AND f.date_extraction = v_date_extraction;

    -- Scores RFM
    UPDATE gold.ml_features_client
    SET score_rfm = LEAST(100, GREATEST(0,
        (100 - LEAST(recence_derniere_commande_jours, 365) / 365.0 * 33 +
         LEAST(nb_commandes_12m, 12) / 12.0 * 33 +
         LEAST(ca_12m, 100000) / 100000.0 * 34)::INTEGER
    ))
    WHERE date_extraction = v_date_extraction;

    -- Segmentation valeur
    UPDATE gold.ml_features_client
    SET segment_valeur = CASE
        WHEN ca_12m >= 100000 THEN 'VIP'
        WHEN ca_12m >= 50000 THEN 'PREMIUM'
        WHEN ca_12m >= 10000 THEN 'STANDARD'
        ELSE 'PETIT'
    END
    WHERE date_extraction = v_date_extraction;

    -- Segmentation comportement
    UPDATE gold.ml_features_client
    SET segment_comportement = CASE
        WHEN recence_derniere_commande_jours <= 30 AND nb_commandes_12m >= 6 THEN 'FIDELE'
        WHEN recence_derniere_commande_jours <= 90 AND nb_commandes_12m >= 3 THEN 'REGULIER'
        WHEN recence_derniere_commande_jours <= 180 THEN 'OCCASIONNEL'
        ELSE 'DORMANT'
    END
    WHERE date_extraction = v_date_extraction;

    -- Probabilite churn (simplifiee)
    UPDATE gold.ml_features_client
    SET probabilite_churn = CASE
        WHEN segment_comportement = 'DORMANT' THEN 0.8
        WHEN segment_comportement = 'OCCASIONNEL' THEN 0.4
        WHEN segment_comportement = 'REGULIER' THEN 0.15
        ELSE 0.05
    END
    WHERE date_extraction = v_date_extraction;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_ML_FEATURES_CLIENT: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 12. PROCEDURE ORCHESTRATION SILVER -> GOLD
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.run_silver_to_gold()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Debut ETL Silver -> Gold: %', CURRENT_TIMESTAMP;

    -- Agregations
    CALL etl.load_agg_ca_periode();
    CALL etl.load_agg_ca_client();
    CALL etl.load_agg_ca_affaire();
    CALL etl.load_agg_balance_compte();
    CALL etl.load_agg_tresorerie();
    CALL etl.load_agg_balance_agee_client();
    CALL etl.load_agg_heures_salarie();
    CALL etl.load_agg_heures_affaire();
    CALL etl.load_agg_stock_element();

    -- KPIs
    CALL etl.load_kpi_global();

    -- Features ML
    CALL etl.load_ml_features_client();

    RAISE NOTICE 'Fin ETL Silver -> Gold: %', CURRENT_TIMESTAMP;
END;
$$;

-- ============================================================================
-- 13. PROCEDURE ETL COMPLETE
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.run_full_etl()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DEBUT ETL COMPLET: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '========================================';

    -- Bronze -> Silver
    CALL etl.run_bronze_to_silver();

    -- Silver -> Gold
    CALL etl.run_silver_to_gold();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'FIN ETL COMPLET: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '========================================';
END;
$$;

-- ============================================================================
-- FIN ETL SILVER -> GOLD
-- ============================================================================

\echo 'ETL Silver -> Gold cree avec succes'

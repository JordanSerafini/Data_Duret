-- ============================================================================
-- CORRECTION DONNEES TRESORERIE ET BALANCE AGEE
-- Script de remediation pour rendre la page tresorerie fonctionnelle
-- A executer apres les autres scripts de seed
-- ============================================================================

\c dwh_groupe_duret;

\echo '============================================'
\echo 'DEBUT CORRECTION TRESORERIE ET BALANCE AGEE'
\echo '============================================'

-- ============================================================================
-- 1. AJOUT ECRITURES BANCAIRES (ENCAISSEMENTS/DECAISSEMENTS)
-- ============================================================================

\echo '1. Ajout ecritures bancaires dans Bronze...'

-- Recuperer le dernier ID de piece
DO $$
DECLARE
    v_last_piece_id INTEGER;
    v_last_ecriture_id INTEGER;
    v_piece_id INTEGER;
    v_ecriture_id INTEGER;
    v_date DATE;
    v_montant NUMERIC;
    v_client_code VARCHAR(10);
    v_fournisseur_code VARCHAR(10);
BEGIN
    SELECT COALESCE(MAX(_source_id), 0) INTO v_last_piece_id FROM bronze.sage_piece;
    SELECT COALESCE(MAX(_source_id), 0) INTO v_last_ecriture_id FROM bronze.sage_ecriture;

    v_piece_id := v_last_piece_id + 1;
    v_ecriture_id := v_last_ecriture_id + 1;

    -- Generer des encaissements clients (reglements recus)
    FOR v_mois IN 1..6 LOOP
        FOR v_jour IN 1..20 LOOP
            v_date := DATE '2025-01-01' + ((v_mois - 1) * 30 + v_jour - 1) * INTERVAL '1 day';

            -- 2 encaissements par jour
            FOR v_i IN 1..2 LOOP
                v_montant := (5000 + RANDOM() * 45000)::NUMERIC(15,2);
                v_client_code := 'C' || LPAD((1 + (v_piece_id % 150))::TEXT, 4, '0');

                -- Piece encaissement
                INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
                VALUES (v_piece_id, 1, 1, 3, 'BQ1-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date, 'Reglement client ' || v_client_code, 'VALIDE', 'SAISIE', v_montant, v_montant);

                -- Ecritures: Banque au debit, Client au credit
                INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
                VALUES
                (v_ecriture_id, v_piece_id, 1, v_date, '512100', NULL, 'Encaissement ' || v_client_code, 'ENC-' || v_piece_id, v_montant, 0, NULL),
                (v_ecriture_id + 1, v_piece_id, 2, v_date, '411000', v_client_code, 'Reglement ' || v_client_code, 'ENC-' || v_piece_id, 0, v_montant, NULL);

                v_piece_id := v_piece_id + 1;
                v_ecriture_id := v_ecriture_id + 2;
            END LOOP;

            -- 1 decaissement fournisseur par jour
            v_montant := (3000 + RANDOM() * 25000)::NUMERIC(15,2);
            v_fournisseur_code := 'F' || LPAD((1 + (v_piece_id % 80))::TEXT, 4, '0');

            -- Piece decaissement
            INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
            VALUES (v_piece_id, 1, 1, 3, 'BQ1-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date, 'Reglement fournisseur ' || v_fournisseur_code, 'VALIDE', 'SAISIE', v_montant, v_montant);

            -- Ecritures: Fournisseur au debit, Banque au credit
            INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
            VALUES
            (v_ecriture_id, v_piece_id, 1, v_date, '401000', v_fournisseur_code, 'Paiement ' || v_fournisseur_code, 'DEC-' || v_piece_id, v_montant, 0, NULL),
            (v_ecriture_id + 1, v_piece_id, 2, v_date, '512100', NULL, 'Decaissement ' || v_fournisseur_code, 'DEC-' || v_piece_id, 0, v_montant, NULL);

            v_piece_id := v_piece_id + 1;
            v_ecriture_id := v_ecriture_id + 2;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Ecritures bancaires ajoutees: % pieces, % ecritures', v_piece_id - v_last_piece_id - 1, v_ecriture_id - v_last_ecriture_id - 1;
END $$;

-- ============================================================================
-- 2. RE-EXECUTION ETL ECRITURES COMPTABLES
-- ============================================================================

\echo '2. Re-execution ETL ecritures comptables...'

-- Charger les nouvelles ecritures dans Silver
CALL etl.load_fact_ecriture_compta();

-- ============================================================================
-- 3. CORRECTION LIENS CLIENTS DANS FACT_ECRITURE_COMPTA
-- ============================================================================

\echo '3. Correction liens clients dans ecritures...'

-- Mise a jour des liens clients pour les comptes 411
UPDATE silver.fact_ecriture_compta f
SET client_sk = c.client_sk
FROM silver.dim_client c
WHERE f.compte_numero LIKE '41%'
AND f.compte_tiers IS NOT NULL
AND c.sage_code = f.compte_tiers
AND c.is_current = TRUE
AND f.client_sk IS NULL;

-- Mise a jour des liens fournisseurs pour les comptes 401
UPDATE silver.fact_ecriture_compta f
SET fournisseur_sk = fo.fournisseur_sk
FROM silver.dim_fournisseur fo
WHERE f.compte_numero LIKE '40%'
AND f.compte_tiers IS NOT NULL
AND fo.sage_code = f.compte_tiers
AND fo.is_current = TRUE
AND f.fournisseur_sk IS NULL;

-- ============================================================================
-- 4. CHARGEMENT AGG_TRESORERIE
-- ============================================================================

\echo '4. Chargement table gold.agg_tresorerie...'

TRUNCATE TABLE gold.agg_tresorerie;

-- Insertion directe avec calcul des soldes banque et flux
INSERT INTO gold.agg_tresorerie (
    societe_sk, annee, mois, niveau_agregation,
    solde_banque, solde_caisse, encaissements, decaissements,
    creances_clients, creances_echues, dettes_fournisseurs, dettes_echues,
    bfr_estime, last_updated
)
SELECT
    e.societe_sk,
    t.annee,
    t.mois,
    'MOIS',
    -- Solde banque: cumul des mouvements sur comptes 512x
    SUM(CASE WHEN c.numero LIKE '512%' THEN e.montant_debit - e.montant_credit ELSE 0 END),
    -- Solde caisse: cumul des mouvements sur compte 530
    SUM(CASE WHEN c.numero LIKE '530%' THEN e.montant_debit - e.montant_credit ELSE 0 END),
    -- Encaissements: debits sur comptes 512x (entrees en banque)
    SUM(CASE WHEN c.numero LIKE '512%' THEN e.montant_debit ELSE 0 END),
    -- Decaissements: credits sur comptes 512x (sorties de banque)
    SUM(CASE WHEN c.numero LIKE '512%' THEN e.montant_credit ELSE 0 END),
    -- Creances clients: solde comptes 411
    SUM(CASE WHEN c.numero LIKE '411%' THEN e.montant_debit - e.montant_credit ELSE 0 END),
    -- Creances echues: creances avec echeance depassee
    SUM(CASE WHEN c.numero LIKE '411%' AND e.date_echeance < CURRENT_DATE AND e.est_lettre = FALSE
        THEN e.montant_debit - e.montant_credit ELSE 0 END),
    -- Dettes fournisseurs: solde comptes 401
    SUM(CASE WHEN c.numero LIKE '401%' THEN e.montant_credit - e.montant_debit ELSE 0 END),
    -- Dettes echues
    SUM(CASE WHEN c.numero LIKE '401%' AND e.date_echeance < CURRENT_DATE AND e.est_lettre = FALSE
        THEN e.montant_credit - e.montant_debit ELSE 0 END),
    -- BFR estime
    SUM(CASE WHEN c.numero LIKE '411%' THEN e.montant_debit - e.montant_credit ELSE 0 END) -
    SUM(CASE WHEN c.numero LIKE '401%' THEN e.montant_credit - e.montant_debit ELSE 0 END),
    CURRENT_TIMESTAMP
FROM silver.fact_ecriture_compta e
JOIN silver.dim_temps t ON e.date_sk = t.date_key
JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk AND c.is_current = TRUE
WHERE t.annee = 2025
GROUP BY e.societe_sk, t.annee, t.mois
ORDER BY t.annee, t.mois;

-- Ajouter un solde initial pour que les chiffres soient positifs
UPDATE gold.agg_tresorerie
SET solde_banque = solde_banque + 500000,  -- Solde initial 500k
    bfr_estime = bfr_estime + 150000;       -- BFR initial 150k

-- ============================================================================
-- 5. CHARGEMENT AGG_BALANCE_AGEE_CLIENT
-- ============================================================================

\echo '5. Chargement table gold.agg_balance_agee_client...'

-- Supprimer les anciens calculs
DELETE FROM gold.agg_balance_agee_client WHERE date_calcul = CURRENT_DATE;

-- Calculer la balance agee par client
INSERT INTO gold.agg_balance_agee_client (
    societe_sk, client_sk, date_calcul,
    non_echu, echu_0_30j, echu_31_60j, echu_61_90j, echu_plus_90j,
    dso_jours, taux_recouvrement, score_risque_credit, last_updated
)
SELECT
    e.societe_sk,
    e.client_sk,
    CURRENT_DATE,
    -- Non echu (echeance dans le futur)
    GREATEST(0, SUM(CASE WHEN e.date_echeance >= CURRENT_DATE OR e.date_echeance IS NULL
        THEN e.montant_solde ELSE 0 END)),
    -- Echu 0-30 jours
    GREATEST(0, SUM(CASE WHEN e.date_echeance < CURRENT_DATE
        AND e.date_echeance >= CURRENT_DATE - INTERVAL '30 days'
        THEN e.montant_solde ELSE 0 END)),
    -- Echu 31-60 jours
    GREATEST(0, SUM(CASE WHEN e.date_echeance < CURRENT_DATE - INTERVAL '30 days'
        AND e.date_echeance >= CURRENT_DATE - INTERVAL '60 days'
        THEN e.montant_solde ELSE 0 END)),
    -- Echu 61-90 jours
    GREATEST(0, SUM(CASE WHEN e.date_echeance < CURRENT_DATE - INTERVAL '60 days'
        AND e.date_echeance >= CURRENT_DATE - INTERVAL '90 days'
        THEN e.montant_solde ELSE 0 END)),
    -- Echu +90 jours
    GREATEST(0, SUM(CASE WHEN e.date_echeance < CURRENT_DATE - INTERVAL '90 days'
        THEN e.montant_solde ELSE 0 END)),
    -- DSO (approximatif)
    COALESCE(AVG(CURRENT_DATE - e.date_echeance)::INTEGER, 0),
    -- Taux recouvrement (sera calcule apres)
    0,
    -- Score risque credit (sera calcule apres)
    0,
    CURRENT_TIMESTAMP
FROM silver.fact_ecriture_compta e
JOIN silver.dim_compte c ON e.compte_sk = c.compte_sk AND c.is_current = TRUE
WHERE c.numero LIKE '411%'
AND e.est_lettre = FALSE
AND e.client_sk IS NOT NULL
AND e.montant_solde > 0
GROUP BY e.societe_sk, e.client_sk
HAVING SUM(e.montant_solde) > 100;  -- Exclure les petits soldes

-- Si pas assez de donnees, inserer des donnees realistes
DO $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM gold.agg_balance_agee_client WHERE date_calcul = CURRENT_DATE;

    IF v_count < 10 THEN
        RAISE NOTICE 'Insertion de donnees balance agee simulees (% clients trouves)...', v_count;

        -- Vider et reinserer des donnees simulees
        DELETE FROM gold.agg_balance_agee_client WHERE date_calcul = CURRENT_DATE;

        INSERT INTO gold.agg_balance_agee_client (
            societe_sk, client_sk, date_calcul,
            non_echu, echu_0_30j, echu_31_60j, echu_61_90j, echu_plus_90j,
            dso_jours, taux_recouvrement, score_risque_credit, last_updated
        )
        SELECT
            1,  -- societe_sk DURETELEC
            c.client_sk,
            CURRENT_DATE,
            -- Non echu: montant aleatoire base sur le client
            (10000 + (c.client_sk * 523) % 90000)::NUMERIC(15,2),
            -- Echu 0-30j: ~20% du non echu
            ((10000 + (c.client_sk * 523) % 90000) * 0.2 * RANDOM())::NUMERIC(15,2),
            -- Echu 31-60j: ~10% du non echu
            ((10000 + (c.client_sk * 523) % 90000) * 0.1 * RANDOM())::NUMERIC(15,2),
            -- Echu 61-90j: ~5% du non echu
            ((10000 + (c.client_sk * 523) % 90000) * 0.05 * RANDOM())::NUMERIC(15,2),
            -- Echu +90j: ~3% du non echu pour certains clients
            CASE WHEN c.client_sk % 5 = 0 THEN ((10000 + (c.client_sk * 523) % 90000) * 0.08 * RANDOM())::NUMERIC(15,2) ELSE 0 END,
            -- DSO: 30-90 jours
            30 + (c.client_sk % 60),
            -- Taux recouvrement
            0,
            -- Score risque
            0,
            CURRENT_TIMESTAMP
        FROM silver.dim_client c
        WHERE c.is_current = TRUE
        AND c.client_sk <= 100;  -- Top 100 clients
    END IF;
END $$;

-- Mettre a jour le taux de recouvrement
UPDATE gold.agg_balance_agee_client
SET taux_recouvrement = CASE
    WHEN total_creances > 0 THEN LEAST(100, (non_echu / total_creances * 100))
    ELSE 100
END
WHERE date_calcul = CURRENT_DATE;

-- Mettre a jour le score de risque credit (0-100)
UPDATE gold.agg_balance_agee_client
SET score_risque_credit = LEAST(100, GREATEST(0, (
    CASE
        WHEN total_creances = 0 THEN 0
        ELSE (
            (COALESCE(echu_plus_90j, 0) / NULLIF(total_creances, 0) * 50) +
            (COALESCE(echu_61_90j, 0) / NULLIF(total_creances, 0) * 30) +
            (COALESCE(echu_31_60j, 0) / NULLIF(total_creances, 0) * 15) +
            (COALESCE(echu_0_30j, 0) / NULLIF(total_creances, 0) * 5)
        ) * 100
    END
)::INTEGER))
WHERE date_calcul = CURRENT_DATE;

-- ============================================================================
-- 6. MISE A JOUR KPI_GLOBAL AVEC DONNEES TRESORERIE
-- ============================================================================

\echo '6. Mise a jour KPI avec donnees tresorerie...'

UPDATE gold.kpi_global k
SET
    kpi_tresorerie_nette = COALESCE(t.solde_total, 0),
    kpi_bfr = COALESCE(t.bfr_estime, 0),
    kpi_dso_jours = COALESCE(ba.dso_moyen, 45)
FROM (
    SELECT societe_sk, annee, mois, solde_total, bfr_estime
    FROM gold.agg_tresorerie
    WHERE niveau_agregation = 'MOIS'
) t
LEFT JOIN (
    SELECT
        societe_sk,
        AVG(dso_jours)::INTEGER AS dso_moyen
    FROM gold.agg_balance_agee_client
    WHERE date_calcul = CURRENT_DATE
    GROUP BY societe_sk
) ba ON t.societe_sk = ba.societe_sk
WHERE k.societe_sk = t.societe_sk
AND k.annee = t.annee
AND k.mois = t.mois;

-- ============================================================================
-- 7. VERIFICATION
-- ============================================================================

\echo '============================================'
\echo 'VERIFICATION DONNEES TRESORERIE'
\echo '============================================'

SELECT 'agg_tresorerie' AS table_name, COUNT(*) AS nb_lignes FROM gold.agg_tresorerie
UNION ALL
SELECT 'agg_balance_agee_client', COUNT(*) FROM gold.agg_balance_agee_client WHERE date_calcul = CURRENT_DATE;

\echo ''
\echo 'Apercu agg_tresorerie:'
SELECT annee, mois, solde_banque, solde_total, encaissements, decaissements, flux_net, bfr_estime
FROM gold.agg_tresorerie
ORDER BY annee, mois
LIMIT 6;

\echo ''
\echo 'Synthese balance agee:'
SELECT
    COUNT(*) AS nb_clients,
    SUM(non_echu) AS total_non_echu,
    SUM(echu_0_30j) AS total_0_30j,
    SUM(echu_31_60j) AS total_31_60j,
    SUM(echu_61_90j) AS total_61_90j,
    SUM(echu_plus_90j) AS total_plus_90j,
    SUM(total_creances) AS total_creances,
    AVG(dso_jours)::INTEGER AS dso_moyen
FROM gold.agg_balance_agee_client
WHERE date_calcul = CURRENT_DATE;

\echo '============================================'
\echo 'CORRECTION TRESORERIE TERMINEE'
\echo '============================================'

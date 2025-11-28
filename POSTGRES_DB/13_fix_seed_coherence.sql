-- ============================================================================
-- CORRECTION DES INCOHERENCES DE SEED
-- Script de remediation pour des donnees realistes
-- A executer apres 11_dwh_seed_initial.sql si les donnees sont deja chargees
-- ============================================================================

\c dwh_groupe_duret;

\echo '============================================'
\echo 'DEBUT CORRECTION INCOHERENCES SEED'
\echo '============================================'

-- ============================================================================
-- 0. NETTOYAGE DES DOUBLONS DANS LES DIMENSIONS
-- ============================================================================

\echo '0. Nettoyage des doublons dimensions...'

-- Desactiver temporairement les contraintes FK
SET session_replication_role = replica;

-- Nettoyer dim_salarie (doublons par source_id avec is_current=TRUE)
DELETE FROM silver.dim_salarie a
USING silver.dim_salarie b
WHERE a.source_id = b.source_id
AND a.is_current = TRUE AND b.is_current = TRUE
AND a.salarie_sk > b.salarie_sk;

-- Nettoyer dim_affaire
DELETE FROM silver.dim_affaire a
USING silver.dim_affaire b
WHERE a.source_id = b.source_id
AND a.is_current = TRUE AND b.is_current = TRUE
AND a.affaire_sk > b.affaire_sk;

-- Nettoyer dim_chantier
DELETE FROM silver.dim_chantier a
USING silver.dim_chantier b
WHERE a.source_id = b.source_id
AND a.is_current = TRUE AND b.is_current = TRUE
AND a.chantier_sk > b.chantier_sk;

-- Reactiver les contraintes
SET session_replication_role = DEFAULT;

-- ============================================================================
-- 1. AJOUT HEURES NON-PRODUCTIVES (corrige productivite 100%)
-- ============================================================================

\echo '1. Regeneration heures MO avec heures non-productives...'

-- Vider les tables de faits liees aux heures MO
TRUNCATE bronze.mde_suivi_mo RESTART IDENTITY CASCADE;
TRUNCATE silver.fact_suivi_mo RESTART IDENTITY CASCADE;

-- Regenerer avec mix heures productives (80%) et non-productives (20%)
DO $$
DECLARE
    v_source_id INTEGER := 1;
    v_date DATE;
    v_semaine_iso TEXT;
    v_salarie RECORD;
    v_affaire RECORD;
    v_heures_normales NUMERIC;
    v_heures_supp_25 NUMERIC;
    v_heures_supp_50 NUMERIC;
    v_is_productive BOOLEAN;
BEGIN
    FOR v_salarie IN
        SELECT _source_id, matricule FROM bronze.mde_salarie WHERE _source_id <= 60 ORDER BY _source_id
    LOOP
        FOR v_date IN
            SELECT generate_series(DATE '2025-01-06', DATE '2025-06-30', INTERVAL '1 week')::DATE
        LOOP
            v_semaine_iso := TO_CHAR(v_date, 'IYYY') || '-W' || LPAD(EXTRACT(WEEK FROM v_date)::TEXT, 2, '0');
            v_heures_normales := 30 + (RANDOM() * 9)::NUMERIC(6,2);
            v_heures_supp_25 := (RANDOM() * 5)::NUMERIC(6,2);
            v_heures_supp_50 := (RANDOM() * 2)::NUMERIC(6,2);
            v_is_productive := RANDOM() < 0.80;

            IF v_is_productive THEN
                SELECT _source_id, code INTO v_affaire
                FROM bronze.mde_affaire WHERE etat IN ('EN_COURS', 'TERMINE') ORDER BY RANDOM() LIMIT 1;

                INSERT INTO bronze.mde_suivi_mo (
                    _source_id, societe_id, salarie_id, salarie_matricule, affaire_id, affaire_code, chantier_id,
                    semaine_iso, date_debut_semaine, heures_normales, heures_supp_25, heures_supp_50,
                    heures_nuit, heures_dimanche, heures_deplacement, indemnites_repas, indemnites_trajet
                ) VALUES (
                    v_source_id, 1, v_salarie._source_id, v_salarie.matricule, v_affaire._source_id, v_affaire.code,
                    ((v_salarie._source_id + v_affaire._source_id) % 100) + 1, v_semaine_iso, v_date,
                    v_heures_normales, v_heures_supp_25, v_heures_supp_50, 0, 0, (RANDOM() * 2)::NUMERIC(6,2),
                    (5 * 12.50)::NUMERIC(8,2), (5 * 8.50)::NUMERIC(8,2)
                );
            ELSE
                -- Heures NON productives (formation, reunion, maladie, administratif)
                INSERT INTO bronze.mde_suivi_mo (
                    _source_id, societe_id, salarie_id, salarie_matricule, affaire_id, affaire_code, chantier_id,
                    semaine_iso, date_debut_semaine, heures_normales, heures_supp_25, heures_supp_50,
                    heures_nuit, heures_dimanche, heures_deplacement, indemnites_repas, indemnites_trajet
                ) VALUES (
                    v_source_id, 1, v_salarie._source_id, v_salarie.matricule, NULL, NULL, NULL,
                    v_semaine_iso, v_date, v_heures_normales * 0.5, 0, 0, 0, 0, 0,
                    (3 * 12.50)::NUMERIC(8,2), 0
                );
            END IF;
            v_source_id := v_source_id + 1;
        END LOOP;
    END LOOP;
    RAISE NOTICE 'Heures MO generees: % lignes (80%% productives, 20%% non-productives)', v_source_id - 1;
END $$;

-- ============================================================================
-- 2. RECONCILIATION MONTANTS DOCUMENTS = SUM(LIGNES)
-- ============================================================================

\echo '2. Reconciliation montants documents...'

UPDATE bronze.mde_document_entete e
SET montant_ht = sub.total_ht,
    montant_tva = sub.total_ht * 0.20,
    montant_ttc = sub.total_ht * 1.20
FROM (SELECT entete_id, SUM(montant_ht) AS total_ht FROM bronze.mde_document_ligne GROUP BY entete_id) sub
WHERE e._source_id = sub.entete_id;

-- ============================================================================
-- 3. GENERATION DES REGLEMENTS CLIENTS/FOURNISSEURS
-- ============================================================================

\echo '3. Generation des reglements...'

DO $$
DECLARE
    v_piece_id INTEGER;
    v_ecriture_id INTEGER;
    v_facture RECORD;
    v_montant_regle NUMERIC;
    v_date_reglement DATE;
BEGIN
    SELECT COALESCE(MAX(_source_id), 0) + 1 INTO v_piece_id FROM bronze.sage_piece;
    SELECT COALESCE(MAX(_source_id), 0) + 1 INTO v_ecriture_id FROM bronze.sage_ecriture;

    -- Reglements clients (80% des factures)
    FOR v_facture IN
        SELECT p._source_id AS piece_id, p.date_piece, p.montant_debit AS montant_ttc, e.compte_tiers AS client_code
        FROM bronze.sage_piece p
        JOIN bronze.sage_ecriture e ON e.piece_id = p._source_id AND e.ligne_numero = 1
        WHERE p.numero_piece LIKE 'VTE-%' AND RANDOM() < 0.80
        ORDER BY p.date_piece LIMIT 400
    LOOP
        v_date_reglement := v_facture.date_piece + (15 + (RANDOM() * 45)::INTEGER) * INTERVAL '1 day';
        v_montant_regle := CASE WHEN RANDOM() < 0.90 THEN v_facture.montant_ttc ELSE v_facture.montant_ttc * (0.5 + RANDOM() * 0.4) END;

        INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
        VALUES (v_piece_id, 1, 1, 3, 'RGL-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date_reglement, 'Reglement ' || v_facture.client_code, 'VALIDE', 'SAISIE', v_montant_regle, v_montant_regle);

        INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
        VALUES (v_ecriture_id, v_piece_id, 1, v_date_reglement, '512100', NULL, 'Reglement ' || v_facture.client_code, 'RGL-' || v_piece_id, v_montant_regle, 0, NULL),
               (v_ecriture_id + 1, v_piece_id, 2, v_date_reglement, '411000', v_facture.client_code, 'Reglement ' || v_facture.client_code, 'RGL-' || v_piece_id, 0, v_montant_regle, NULL);

        v_piece_id := v_piece_id + 1;
        v_ecriture_id := v_ecriture_id + 2;
    END LOOP;

    RAISE NOTICE 'Reglements clients generes: % pieces', v_piece_id - 1;

    -- Reglements fournisseurs (70% des factures achats)
    FOR v_facture IN
        SELECT p._source_id AS piece_id, p.date_piece, p.montant_debit AS montant_ttc, e.compte_tiers AS fournisseur_code
        FROM bronze.sage_piece p
        JOIN bronze.sage_ecriture e ON e.piece_id = p._source_id AND e.ligne_numero = 3
        WHERE p.numero_piece LIKE 'ACH-%' AND RANDOM() < 0.70
        ORDER BY p.date_piece LIMIT 200
    LOOP
        v_date_reglement := v_facture.date_piece + (30 + (RANDOM() * 30)::INTEGER) * INTERVAL '1 day';
        v_montant_regle := v_facture.montant_ttc;

        INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
        VALUES (v_piece_id, 1, 1, 3, 'RGF-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date_reglement, 'Reglement ' || v_facture.fournisseur_code, 'VALIDE', 'SAISIE', v_montant_regle, v_montant_regle);

        INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
        VALUES (v_ecriture_id, v_piece_id, 1, v_date_reglement, '401000', v_facture.fournisseur_code, 'Reglement ' || v_facture.fournisseur_code, 'RGF-' || v_piece_id, v_montant_regle, 0, NULL),
               (v_ecriture_id + 1, v_piece_id, 2, v_date_reglement, '512100', NULL, 'Reglement ' || v_facture.fournisseur_code, 'RGF-' || v_piece_id, 0, v_montant_regle, NULL);

        v_piece_id := v_piece_id + 1;
        v_ecriture_id := v_ecriture_id + 2;
    END LOOP;

    RAISE NOTICE 'Reglements fournisseurs generes';
END $$;

-- ============================================================================
-- 4. AJOUT INVENTAIRE INITIAL STOCK
-- ============================================================================

\echo '4. Ajout inventaire initial stock...'

INSERT INTO bronze.mde_mouvement_stock (_source_id, societe_id, depot_id, depot_code, element_id, element_code, type_mouvement, date_mouvement, quantite, prix_unitaire, affaire_id, reference)
SELECT 1000 + e._source_id, 1, 1, 'DEP01', e._source_id, e.code, 'INVENTAIRE', DATE '2025-01-01',
       (50 + RANDOM() * 200)::NUMERIC(15,4), e.prix_achat, NULL, 'INV-INIT-2025'
FROM bronze.mde_element e WHERE e.type_element = 'FOURNITURE' AND e._source_id <= 500
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 5. CORRECTION CODES AFFAIRES
-- ============================================================================

\echo '5. Harmonisation codes affaires...'

UPDATE bronze.mde_affaire SET code = REPLACE(code, '2024', '2025') WHERE code LIKE '%2024%';
UPDATE bronze.mde_chantier SET affaire_code = REPLACE(affaire_code, '2024', '2025') WHERE affaire_code LIKE '%2024%';

-- ============================================================================
-- 6. RELANCER ETL
-- ============================================================================

\echo '6. Relance ETL Bronze -> Silver...'
CALL etl.run_bronze_to_silver();

-- ============================================================================
-- 7. RECONCILIER BUDGETS AVEC HEURES REELLES
-- ============================================================================

\echo '7. Reconciliation budgets heures...'

-- Mettre a jour dim_affaire.budget_heures = heures reelles +/- 15%
WITH heures_affaire AS (
    SELECT affaire_sk, SUM(heures_normales + heures_supp_25 + heures_supp_50) AS total_heures
    FROM silver.fact_suivi_mo WHERE affaire_sk IS NOT NULL GROUP BY affaire_sk
)
UPDATE silver.dim_affaire a
SET budget_heures = h.total_heures * (0.90 + RANDOM() * 0.25),
    updated_at = CURRENT_TIMESTAMP
FROM heures_affaire h WHERE a.affaire_sk = h.affaire_sk AND a.is_current = TRUE;

-- Synchroniser bronze
UPDATE bronze.mde_affaire b SET budget_heures = s.budget_heures
FROM silver.dim_affaire s WHERE s.source_id = b._source_id AND s.is_current;

-- ============================================================================
-- 8. RELANCER ETL GOLD
-- ============================================================================

\echo '8. Relance ETL Silver -> Gold...'
CALL etl.run_silver_to_gold();

-- ============================================================================
-- 9. VERIFICATION FINALE
-- ============================================================================

\echo '============================================'
\echo 'VERIFICATION DES CORRECTIONS'
\echo '============================================'

SELECT 'Productivite salaries' AS kpi, ROUND(AVG(taux_productivite), 1)::TEXT || '%' AS valeur, '75-90%' AS cible FROM gold.agg_heures_salarie
UNION ALL SELECT 'Ratio Budget/Realise', ROUND(AVG(CASE WHEN heures_budget > 0 AND heures_realisees > 0 THEN heures_realisees / heures_budget * 100 END), 1)::TEXT || '%', '90-110%' FROM gold.agg_ca_affaire
UNION ALL SELECT 'Heures avec affaire', ROUND(COUNT(CASE WHEN affaire_sk IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*) * 100, 1)::TEXT || '%', '75-85%' FROM silver.fact_suivi_mo;

\echo '============================================'
\echo 'FIN CORRECTION INCOHERENCES'
\echo '============================================'

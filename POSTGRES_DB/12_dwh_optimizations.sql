-- ============================================================================
-- DATA WAREHOUSE - OPTIMISATIONS ET AMELIORATIONS
-- Basé sur audit et bonnes pratiques 2024-2025
-- ============================================================================

\c dwh_groupe_duret;

-- ============================================================================
-- 1. PARTITIONNEMENT DES TABLES DE FAITS
-- ============================================================================

-- 1.1 Créer la nouvelle table partitionnée pour les écritures comptables
CREATE TABLE silver.fact_ecriture_compta_partitioned (
    ecriture_sk BIGSERIAL,
    source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    source_id INTEGER,
    date_sk INTEGER,
    societe_sk INTEGER,
    journal_sk INTEGER,
    compte_sk INTEGER,
    client_sk INTEGER,
    fournisseur_sk INTEGER,
    affaire_sk INTEGER,
    numero_piece VARCHAR(20),
    numero_ligne INTEGER,
    libelle VARCHAR(200),
    reference VARCHAR(50),
    compte_numero VARCHAR(13),
    compte_tiers VARCHAR(17),
    montant_debit NUMERIC(15,2) DEFAULT 0,
    montant_credit NUMERIC(15,2) DEFAULT 0,
    montant_solde NUMERIC(15,2) GENERATED ALWAYS AS (montant_debit - montant_credit) STORED,
    code_lettrage VARCHAR(10),
    date_lettrage DATE,
    est_lettre BOOLEAN DEFAULT FALSE,
    date_echeance DATE,
    etat_piece VARCHAR(20),
    origine VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ecriture_sk, date_sk)
) PARTITION BY RANGE (date_sk);

-- Partitions par année
CREATE TABLE silver.fact_ecriture_compta_2020 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20200101) TO (20210101);
CREATE TABLE silver.fact_ecriture_compta_2021 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20210101) TO (20220101);
CREATE TABLE silver.fact_ecriture_compta_2022 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20220101) TO (20230101);
CREATE TABLE silver.fact_ecriture_compta_2023 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20230101) TO (20240101);
CREATE TABLE silver.fact_ecriture_compta_2024 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20240101) TO (20250101);
CREATE TABLE silver.fact_ecriture_compta_2025 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20250101) TO (20260101);
CREATE TABLE silver.fact_ecriture_compta_2026 PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20260101) TO (20270101);
CREATE TABLE silver.fact_ecriture_compta_future PARTITION OF silver.fact_ecriture_compta_partitioned
    FOR VALUES FROM (20270101) TO (20500101);

-- Index sur partitions
CREATE INDEX idx_fact_ecriture_part_compte ON silver.fact_ecriture_compta_partitioned(compte_sk);
CREATE INDEX idx_fact_ecriture_part_societe ON silver.fact_ecriture_compta_partitioned(societe_sk);
CREATE INDEX idx_fact_ecriture_part_piece ON silver.fact_ecriture_compta_partitioned(numero_piece);

-- 1.2 Table partitionnée pour documents commerciaux
CREATE TABLE silver.fact_document_commercial_partitioned (
    document_sk BIGSERIAL,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    date_sk INTEGER,
    societe_sk INTEGER,
    client_sk INTEGER,
    fournisseur_sk INTEGER,
    affaire_sk INTEGER,
    chantier_sk INTEGER,
    type_document VARCHAR(20),
    numero VARCHAR(20),
    objet VARCHAR(200),
    statut VARCHAR(20),
    montant_ht NUMERIC(15,2),
    montant_tva NUMERIC(15,2),
    montant_ttc NUMERIC(15,2),
    taux_tva_moyen NUMERIC(5,2),
    nb_lignes INTEGER,
    date_validation DATE,
    document_origine_sk BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (document_sk, date_sk)
) PARTITION BY RANGE (date_sk);

-- Partitions documents
CREATE TABLE silver.fact_document_2020 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20200101) TO (20210101);
CREATE TABLE silver.fact_document_2021 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20210101) TO (20220101);
CREATE TABLE silver.fact_document_2022 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20220101) TO (20230101);
CREATE TABLE silver.fact_document_2023 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20230101) TO (20240101);
CREATE TABLE silver.fact_document_2024 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20240101) TO (20250101);
CREATE TABLE silver.fact_document_2025 PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20250101) TO (20260101);
CREATE TABLE silver.fact_document_future PARTITION OF silver.fact_document_commercial_partitioned
    FOR VALUES FROM (20260101) TO (20500101);

-- ============================================================================
-- 2. INDEX BRIN POUR COLONNES TEMPORELLES
-- ============================================================================

-- Index BRIN sur les tables bronze (très efficaces pour données ordonnées par temps)
CREATE INDEX CONCURRENTLY idx_brin_sage_ecriture_date ON bronze.sage_ecriture
    USING BRIN(date_ecriture) WITH (pages_per_range = 32);
CREATE INDEX CONCURRENTLY idx_brin_sage_piece_date ON bronze.sage_piece
    USING BRIN(date_piece) WITH (pages_per_range = 32);
CREATE INDEX CONCURRENTLY idx_brin_mde_doc_date ON bronze.mde_document_entete
    USING BRIN(date_document) WITH (pages_per_range = 32);
CREATE INDEX CONCURRENTLY idx_brin_mde_suivi_date ON bronze.mde_suivi_mo
    USING BRIN(date_debut_semaine) WITH (pages_per_range = 32);
CREATE INDEX CONCURRENTLY idx_brin_mde_mvt_date ON bronze.mde_mouvement_stock
    USING BRIN(date_mouvement) WITH (pages_per_range = 32);

-- Index BRIN sur dim_temps
CREATE INDEX idx_brin_dim_temps ON silver.dim_temps USING BRIN(date_complete);

-- ============================================================================
-- 3. CHECK CONSTRAINTS POUR QUALITE DES DONNEES
-- ============================================================================

-- Contraintes sur dim_client
ALTER TABLE silver.dim_client
    ADD CONSTRAINT chk_client_siret CHECK (siret IS NULL OR LENGTH(siret) = 14),
    ADD CONSTRAINT chk_client_email CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    ADD CONSTRAINT chk_client_cp CHECK (code_postal IS NULL OR code_postal ~ '^\d{5}$'),
    ADD CONSTRAINT chk_client_encours CHECK (encours_max IS NULL OR encours_max >= 0);

-- Contraintes sur dim_fournisseur
ALTER TABLE silver.dim_fournisseur
    ADD CONSTRAINT chk_fournisseur_siret CHECK (siret IS NULL OR LENGTH(siret) = 14),
    ADD CONSTRAINT chk_fournisseur_cp CHECK (code_postal IS NULL OR code_postal ~ '^\d{5}$');

-- Contraintes sur dim_societe
ALTER TABLE silver.dim_societe
    ADD CONSTRAINT chk_societe_siret CHECK (siret IS NULL OR LENGTH(siret) = 14);

-- Contraintes sur dim_salarie
ALTER TABLE silver.dim_salarie
    ADD CONSTRAINT chk_salarie_taux CHECK (taux_horaire IS NULL OR taux_horaire > 0),
    ADD CONSTRAINT chk_salarie_coef CHECK (coefficient IS NULL OR coefficient > 0),
    ADD CONSTRAINT chk_salarie_dates CHECK (date_sortie IS NULL OR date_sortie >= date_entree);

-- Contraintes sur dim_affaire
ALTER TABLE silver.dim_affaire
    ADD CONSTRAINT chk_affaire_montants CHECK (montant_devis IS NULL OR montant_devis >= 0),
    ADD CONSTRAINT chk_affaire_dates CHECK (date_fin_prevue IS NULL OR date_debut_prevue IS NULL OR date_fin_prevue >= date_debut_prevue),
    ADD CONSTRAINT chk_affaire_marge CHECK (marge_prevue_pct IS NULL OR (marge_prevue_pct >= -100 AND marge_prevue_pct <= 100));

-- Contraintes sur fact_ecriture_compta
ALTER TABLE silver.fact_ecriture_compta
    ADD CONSTRAINT chk_ecriture_montants CHECK (montant_debit >= 0 AND montant_credit >= 0);

-- Contraintes sur fact_document_commercial
ALTER TABLE silver.fact_document_commercial
    ADD CONSTRAINT chk_document_montants CHECK (montant_ht IS NULL OR montant_ht >= 0),
    ADD CONSTRAINT chk_document_tva CHECK (taux_tva_moyen IS NULL OR (taux_tva_moyen >= 0 AND taux_tva_moyen <= 100));

-- Contraintes sur fact_suivi_mo
ALTER TABLE silver.fact_suivi_mo
    ADD CONSTRAINT chk_suivi_heures CHECK (heures_normales >= 0 AND heures_supp_25 >= 0 AND heures_supp_50 >= 0);

-- ============================================================================
-- 4. VUES MATERIALISEES POUR KPIs FREQUENTS
-- ============================================================================

-- 4.1 Vue matérialisée CA par société/mois
CREATE MATERIALIZED VIEW gold.mv_ca_societe_mensuel AS
SELECT
    s.societe_sk,
    s.raison_sociale,
    t.annee,
    t.mois,
    t.trimestre,
    SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END) AS ca_facture,
    SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END) AS ca_avoir,
    SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END) -
    SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END) AS ca_net,
    COUNT(DISTINCT d.client_sk) AS nb_clients,
    COUNT(DISTINCT d.affaire_sk) AS nb_affaires,
    COUNT(*) FILTER (WHERE d.type_document = 'FACTURE') AS nb_factures
FROM silver.fact_document_commercial d
JOIN silver.dim_temps t ON d.date_sk = t.date_key
JOIN silver.dim_societe s ON d.societe_sk = s.societe_sk AND s.is_current = TRUE
GROUP BY s.societe_sk, s.raison_sociale, t.annee, t.mois, t.trimestre
WITH DATA;

CREATE UNIQUE INDEX idx_mv_ca_societe ON gold.mv_ca_societe_mensuel(societe_sk, annee, mois);
CREATE INDEX idx_mv_ca_annee ON gold.mv_ca_societe_mensuel(annee, mois);

-- 4.2 Vue matérialisée balance clients
CREATE MATERIALIZED VIEW gold.mv_balance_client AS
SELECT
    c.client_sk,
    c.raison_sociale,
    c.segment_client,
    SUM(e.montant_debit - e.montant_credit) AS solde,
    SUM(CASE WHEN NOT e.est_lettre THEN e.montant_debit - e.montant_credit ELSE 0 END) AS solde_ouvert,
    COUNT(*) AS nb_ecritures,
    MAX(t.date_complete) AS derniere_ecriture
FROM silver.fact_ecriture_compta e
JOIN silver.dim_client c ON e.client_sk = c.client_sk AND c.is_current = TRUE
JOIN silver.dim_temps t ON e.date_sk = t.date_key
JOIN silver.dim_compte cpt ON e.compte_sk = cpt.compte_sk AND cpt.numero LIKE '41%'
GROUP BY c.client_sk, c.raison_sociale, c.segment_client
WITH DATA;

CREATE UNIQUE INDEX idx_mv_balance_client ON gold.mv_balance_client(client_sk);

-- 4.3 Vue matérialisée productivité salariés
CREATE MATERIALIZED VIEW gold.mv_productivite_salarie AS
SELECT
    sal.salarie_sk,
    sal.nom_complet,
    sal.poste,
    sal.categorie_poste,
    sal.societe_sk,
    t.annee,
    t.mois,
    SUM(mo.heures_total) AS heures_total,
    SUM(mo.heures_normales) AS heures_normales,
    SUM(mo.heures_supp_25 + mo.heures_supp_50) AS heures_supp,
    SUM(mo.cout_total) AS cout_total,
    COUNT(DISTINCT mo.affaire_sk) AS nb_affaires,
    CASE WHEN SUM(mo.heures_total) > 0
         THEN SUM(mo.cout_total) / SUM(mo.heures_total)
         ELSE 0 END AS cout_horaire_moyen
FROM silver.fact_suivi_mo mo
JOIN silver.dim_salarie sal ON mo.salarie_sk = sal.salarie_sk AND sal.is_current = TRUE
JOIN silver.dim_temps t ON mo.date_sk = t.date_key
GROUP BY sal.salarie_sk, sal.nom_complet, sal.poste, sal.categorie_poste, sal.societe_sk, t.annee, t.mois
WITH DATA;

CREATE UNIQUE INDEX idx_mv_prod_salarie ON gold.mv_productivite_salarie(salarie_sk, annee, mois);

-- 4.4 Vue matérialisée rentabilité affaires
CREATE MATERIALIZED VIEW gold.mv_rentabilite_affaire AS
SELECT
    a.affaire_sk,
    a.code,
    a.libelle,
    a.etat,
    a.etat_groupe,
    a.societe_sk,
    c.client_sk,
    c.raison_sociale AS client_nom,
    a.montant_devis,
    a.montant_commande,
    COALESCE(SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END), 0) AS montant_facture,
    COALESCE(SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END), 0) AS montant_avoir,
    COALESCE(SUM(mo.heures_total), 0) AS heures_realisees,
    COALESCE(SUM(mo.cout_total), 0) AS cout_mo,
    a.budget_heures,
    CASE WHEN a.budget_heures > 0
         THEN (COALESCE(SUM(mo.heures_total), 0) / a.budget_heures * 100)
         ELSE 0 END AS pct_heures_consommees,
    CASE WHEN a.montant_commande > 0
         THEN (COALESCE(SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END), 0) / a.montant_commande * 100)
         ELSE 0 END AS pct_facture
FROM silver.dim_affaire a
LEFT JOIN silver.dim_client c ON a.client_sk = c.client_sk AND c.is_current = TRUE
LEFT JOIN silver.fact_document_commercial d ON d.affaire_sk = a.affaire_sk
LEFT JOIN silver.fact_suivi_mo mo ON mo.affaire_sk = a.affaire_sk
WHERE a.is_current = TRUE
GROUP BY a.affaire_sk, a.code, a.libelle, a.etat, a.etat_groupe, a.societe_sk,
         c.client_sk, c.raison_sociale, a.montant_devis, a.montant_commande, a.budget_heures
WITH DATA;

CREATE UNIQUE INDEX idx_mv_rent_affaire ON gold.mv_rentabilite_affaire(affaire_sk);
CREATE INDEX idx_mv_rent_etat ON gold.mv_rentabilite_affaire(etat_groupe);

-- Procédure de refresh des vues matérialisées
CREATE OR REPLACE PROCEDURE etl.refresh_materialized_views()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Refresh vues materialisees: %', CURRENT_TIMESTAMP;
    REFRESH MATERIALIZED VIEW CONCURRENTLY gold.mv_ca_societe_mensuel;
    REFRESH MATERIALIZED VIEW CONCURRENTLY gold.mv_balance_client;
    REFRESH MATERIALIZED VIEW CONCURRENTLY gold.mv_productivite_salarie;
    REFRESH MATERIALIZED VIEW CONCURRENTLY gold.mv_rentabilite_affaire;
    RAISE NOTICE 'Refresh termine: %', CURRENT_TIMESTAMP;
END;
$$;

-- ============================================================================
-- 5. JOURS FERIES MOBILES (Pâques, Ascension, Pentecôte)
-- ============================================================================

-- Fonction pour calculer la date de Pâques (algorithme de Meeus/Jones/Butcher)
CREATE OR REPLACE FUNCTION silver.calcul_paques(p_annee INTEGER)
RETURNS DATE AS $$
DECLARE
    a INTEGER; b INTEGER; c INTEGER; d INTEGER; e INTEGER;
    f INTEGER; g INTEGER; h INTEGER; i INTEGER; k INTEGER;
    l INTEGER; m INTEGER; mois INTEGER; jour INTEGER;
BEGIN
    a := p_annee % 19;
    b := p_annee / 100;
    c := p_annee % 100;
    d := b / 4;
    e := b % 4;
    f := (b + 8) / 25;
    g := (b - f + 1) / 3;
    h := (19 * a + b - d - g + 15) % 30;
    i := c / 4;
    k := c % 4;
    l := (32 + 2 * e + 2 * i - h - k) % 7;
    m := (a + 11 * h + 22 * l) / 451;
    mois := (h + l - 7 * m + 114) / 31;
    jour := ((h + l - 7 * m + 114) % 31) + 1;
    RETURN MAKE_DATE(p_annee, mois, jour);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Mise à jour des jours fériés mobiles dans dim_temps
DO $$
DECLARE
    v_annee INTEGER;
    v_paques DATE;
BEGIN
    FOR v_annee IN 2020..2030 LOOP
        v_paques := silver.calcul_paques(v_annee);

        -- Lundi de Pâques (Pâques + 1 jour)
        UPDATE silver.dim_temps
        SET est_jour_ferie = TRUE, nom_jour_ferie = 'Lundi de Paques'
        WHERE date_complete = v_paques + INTERVAL '1 day';

        -- Ascension (Pâques + 39 jours)
        UPDATE silver.dim_temps
        SET est_jour_ferie = TRUE, nom_jour_ferie = 'Ascension'
        WHERE date_complete = v_paques + INTERVAL '39 days';

        -- Lundi de Pentecôte (Pâques + 50 jours)
        UPDATE silver.dim_temps
        SET est_jour_ferie = TRUE, nom_jour_ferie = 'Lundi de Pentecote'
        WHERE date_complete = v_paques + INTERVAL '50 days';
    END LOOP;
END;
$$;

-- Recalculer nb_jours_ouvres_mois
UPDATE silver.dim_temps dt
SET nb_jours_ouvres_mois = (
    SELECT COUNT(*)
    FROM silver.dim_temps t2
    WHERE t2.annee = dt.annee
    AND t2.mois = dt.mois
    AND NOT t2.est_weekend
    AND NOT t2.est_jour_ferie
);

-- ============================================================================
-- 6. AMELIORATION FONCTION HASH (SHA256)
-- ============================================================================

-- Nouvelle fonction avec SHA256 (requiert extension pgcrypto)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION silver.compute_row_hash_v2(p_values TEXT[])
RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN ENCODE(DIGEST(ARRAY_TO_STRING(p_values, '|'), 'sha256'), 'hex');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- 7. PROCEDURES DE VALIDATION QUALITE DES DONNEES
-- ============================================================================

-- Table pour stocker les règles de qualité
CREATE TABLE IF NOT EXISTS audit.data_quality_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_description TEXT,
    layer VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    check_type VARCHAR(50) NOT NULL,
    check_query TEXT NOT NULL,
    threshold_value NUMERIC,
    severity VARCHAR(20) DEFAULT 'WARNING',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les règles de qualité
INSERT INTO audit.data_quality_rules (rule_name, rule_description, layer, table_name, check_type, check_query, severity) VALUES
-- Completeness checks
('CLIENT_SIRET_COMPLETE', 'Vérifier que les clients ont un SIRET', 'SILVER', 'dim_client', 'COMPLETENESS',
 'SELECT COUNT(*) FROM silver.dim_client WHERE is_current = TRUE AND siret IS NULL', 'WARNING'),
('CLIENT_EMAIL_COMPLETE', 'Vérifier que les clients ont un email', 'SILVER', 'dim_client', 'COMPLETENESS',
 'SELECT COUNT(*) FROM silver.dim_client WHERE is_current = TRUE AND email IS NULL', 'INFO'),
('AFFAIRE_CLIENT_LINK', 'Vérifier que les affaires ont un client', 'SILVER', 'dim_affaire', 'COMPLETENESS',
 'SELECT COUNT(*) FROM silver.dim_affaire WHERE is_current = TRUE AND client_sk IS NULL', 'ERROR'),

-- Uniqueness checks
('CLIENT_SIRET_UNIQUE', 'Vérifier unicité SIRET clients', 'SILVER', 'dim_client', 'UNIQUENESS',
 'SELECT COUNT(*) - COUNT(DISTINCT siret) FROM silver.dim_client WHERE is_current = TRUE AND siret IS NOT NULL', 'ERROR'),
('AFFAIRE_CODE_UNIQUE', 'Vérifier unicité code affaire', 'SILVER', 'dim_affaire', 'UNIQUENESS',
 'SELECT COUNT(*) - COUNT(DISTINCT code) FROM silver.dim_affaire WHERE is_current = TRUE', 'ERROR'),

-- Validity checks
('ECRITURE_EQUILIBRE', 'Vérifier équilibre des écritures par pièce', 'SILVER', 'fact_ecriture_compta', 'VALIDITY',
 'SELECT COUNT(*) FROM (SELECT numero_piece, ABS(SUM(montant_debit) - SUM(montant_credit)) AS diff FROM silver.fact_ecriture_compta GROUP BY numero_piece HAVING ABS(SUM(montant_debit) - SUM(montant_credit)) > 0.01) t', 'CRITICAL'),
('AFFAIRE_DATES_COHERENTES', 'Vérifier cohérence dates affaires', 'SILVER', 'dim_affaire', 'VALIDITY',
 'SELECT COUNT(*) FROM silver.dim_affaire WHERE is_current = TRUE AND date_fin_prevue < date_debut_prevue', 'ERROR'),

-- Consistency checks
('DOCUMENT_MONTANT_COHERENT', 'Vérifier cohérence montants documents', 'SILVER', 'fact_document_commercial', 'CONSISTENCY',
 'SELECT COUNT(*) FROM silver.fact_document_commercial WHERE ABS(montant_ttc - (montant_ht + montant_tva)) > 0.01', 'WARNING');

-- Procédure d'exécution des contrôles qualité
CREATE OR REPLACE PROCEDURE audit.run_data_quality_checks()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rule RECORD;
    v_result BIGINT;
    v_job_id BIGINT;
BEGIN
    v_job_id := etl.start_job('DATA_QUALITY_CHECK', 'DWH', 'AUDIT');

    FOR v_rule IN SELECT * FROM audit.data_quality_rules WHERE is_active = TRUE LOOP
        BEGIN
            EXECUTE v_rule.check_query INTO v_result;

            INSERT INTO audit.data_quality_check (
                check_name, layer, table_name, check_type, check_query,
                expected_result, actual_result, passed, job_id
            ) VALUES (
                v_rule.rule_name, v_rule.layer, v_rule.table_name, v_rule.check_type,
                v_rule.check_query, '0', v_result::TEXT,
                (v_result = 0 OR (v_rule.threshold_value IS NOT NULL AND v_result <= v_rule.threshold_value)),
                v_job_id
            );

            IF v_result > 0 AND (v_rule.threshold_value IS NULL OR v_result > v_rule.threshold_value) THEN
                INSERT INTO audit.data_anomaly (layer, table_name, anomaly_type, description, severity)
                VALUES (v_rule.layer, v_rule.table_name, v_rule.check_type,
                        v_rule.rule_name || ': ' || v_result || ' anomalies detectees', v_rule.severity);
            END IF;

        EXCEPTION WHEN OTHERS THEN
            INSERT INTO audit.data_quality_check (
                check_name, layer, table_name, check_type, check_query,
                expected_result, actual_result, passed, job_id
            ) VALUES (
                v_rule.rule_name, v_rule.layer, v_rule.table_name, v_rule.check_type,
                v_rule.check_query, '0', 'ERROR: ' || SQLERRM, FALSE, v_job_id
            );
        END;
    END LOOP;

    PERFORM etl.end_job(v_job_id, 'SUCCESS');
    RAISE NOTICE 'Controles qualite termines';
END;
$$;

-- ============================================================================
-- 8. COMPLETION ml_features_affaire AVEC ETL
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.load_ml_features_affaire()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_date_extraction DATE := CURRENT_DATE;
BEGIN
    v_job_id := etl.start_job('LOAD_ML_FEATURES_AFFAIRE', 'GOLD', 'GOLD');

    DELETE FROM gold.ml_features_affaire WHERE date_extraction = v_date_extraction;

    INSERT INTO gold.ml_features_affaire (
        affaire_sk, date_extraction,
        type_affaire, montant_commande, montant_log, duree_prevue_jours,
        client_anciennete_mois, client_ca_historique, client_nb_affaires_historique,
        departement, mois_demarrage, trimestre_demarrage,
        nb_salaries_affectes, heures_budget, ratio_mo_montant,
        marge_reelle_pct, ecart_budget_heures_pct, retard_jours
    )
    SELECT
        a.affaire_sk,
        v_date_extraction,
        a.type_affaire,
        a.montant_commande,
        CASE WHEN a.montant_commande > 0 THEN LOG(a.montant_commande) ELSE 0 END,
        a.duree_prevue_jours,
        -- Features client
        COALESCE(EXTRACT(MONTH FROM AGE(CURRENT_DATE, MIN(t_first.date_complete)))::INTEGER, 0),
        COALESCE(SUM(CASE WHEN d.type_document = 'FACTURE' AND d.client_sk = a.client_sk THEN d.montant_ht END), 0),
        COUNT(DISTINCT CASE WHEN a2.client_sk = a.client_sk THEN a2.affaire_sk END),
        -- Localisation
        a.departement_chantier,
        EXTRACT(MONTH FROM a.date_debut_prevue)::INTEGER,
        EXTRACT(QUARTER FROM a.date_debut_prevue)::INTEGER,
        -- Ressources
        COUNT(DISTINCT mo.salarie_sk),
        a.budget_heures,
        CASE WHEN a.montant_commande > 0 THEN a.budget_heures / a.montant_commande ELSE 0 END,
        -- Targets
        CASE WHEN (SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END) -
                   SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END)) > 0
             THEN ((SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END) -
                    SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END) -
                    COALESCE(SUM(mo.cout_total), 0)) /
                   (SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_ht ELSE 0 END) -
                    SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_ht ELSE 0 END)) * 100)
             ELSE NULL END,
        CASE WHEN a.budget_heures > 0
             THEN ((COALESCE(SUM(mo.heures_total), 0) - a.budget_heures) / a.budget_heures * 100)
             ELSE NULL END,
        CASE WHEN a.date_fin_reelle IS NOT NULL AND a.date_fin_prevue IS NOT NULL
             THEN (a.date_fin_reelle - a.date_fin_prevue)
             ELSE NULL END
    FROM silver.dim_affaire a
    LEFT JOIN silver.dim_affaire a2 ON a2.is_current = TRUE
    LEFT JOIN silver.fact_document_commercial d ON d.affaire_sk = a.affaire_sk
    LEFT JOIN silver.fact_suivi_mo mo ON mo.affaire_sk = a.affaire_sk
    LEFT JOIN silver.dim_temps t_first ON d.date_sk = t_first.date_key
    WHERE a.is_current = TRUE
    GROUP BY a.affaire_sk, a.type_affaire, a.montant_commande, a.duree_prevue_jours,
             a.departement_chantier, a.date_debut_prevue, a.budget_heures, a.client_sk,
             a.date_fin_reelle, a.date_fin_prevue;

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Calcul score risque dépassement
    UPDATE gold.ml_features_affaire
    SET risque_depassement_score = LEAST(100, GREATEST(0, (
        COALESCE(ecart_budget_heures_pct, 0) * 0.4 +
        COALESCE(CASE WHEN retard_jours > 0 THEN retard_jours * 2 ELSE 0 END, 0) * 0.3 +
        COALESCE(CASE WHEN marge_reelle_pct < 10 THEN (10 - marge_reelle_pct) * 3 ELSE 0 END, 0) * 0.3
    )::INTEGER))
    WHERE date_extraction = v_date_extraction;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);
    RAISE NOTICE 'LOAD_ML_FEATURES_AFFAIRE: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 9. INDEX COMPOSITES POUR REQUETES FREQUENTES
-- ============================================================================

-- Index composites pour fact_ecriture_compta
CREATE INDEX CONCURRENTLY idx_ecriture_societe_date ON silver.fact_ecriture_compta(societe_sk, date_sk);
CREATE INDEX CONCURRENTLY idx_ecriture_compte_date ON silver.fact_ecriture_compta(compte_sk, date_sk);
CREATE INDEX CONCURRENTLY idx_ecriture_client_lettre ON silver.fact_ecriture_compta(client_sk, est_lettre) WHERE client_sk IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_ecriture_fournisseur_lettre ON silver.fact_ecriture_compta(fournisseur_sk, est_lettre) WHERE fournisseur_sk IS NOT NULL;

-- Index composites pour fact_document_commercial
CREATE INDEX CONCURRENTLY idx_document_societe_type_date ON silver.fact_document_commercial(societe_sk, type_document, date_sk);
CREATE INDEX CONCURRENTLY idx_document_client_type ON silver.fact_document_commercial(client_sk, type_document) WHERE client_sk IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_document_affaire_type ON silver.fact_document_commercial(affaire_sk, type_document) WHERE affaire_sk IS NOT NULL;

-- Index composites pour fact_suivi_mo
CREATE INDEX CONCURRENTLY idx_suivi_societe_date ON silver.fact_suivi_mo(societe_sk, date_sk);
CREATE INDEX CONCURRENTLY idx_suivi_affaire_salarie ON silver.fact_suivi_mo(affaire_sk, salarie_sk);

-- Index composites pour dimensions
CREATE INDEX CONCURRENTLY idx_client_societe_current ON silver.dim_client(societe_sk, is_current) WHERE is_current = TRUE;
CREATE INDEX CONCURRENTLY idx_affaire_etat_societe ON silver.dim_affaire(etat_groupe, societe_sk) WHERE is_current = TRUE;
CREATE INDEX CONCURRENTLY idx_affaire_client_current ON silver.dim_affaire(client_sk, is_current) WHERE is_current = TRUE;

-- ============================================================================
-- 10. MISE A JOUR DE LA PROCEDURE ETL COMPLETE
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

    -- ML Features Affaire (nouveau)
    CALL etl.load_ml_features_affaire();

    -- Refresh vues matérialisées
    CALL etl.refresh_materialized_views();

    -- Contrôles qualité
    CALL audit.run_data_quality_checks();

    RAISE NOTICE '========================================';
    RAISE NOTICE 'FIN ETL COMPLET: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '========================================';
END;
$$;

-- ============================================================================
-- 11. VUE POUR MONITORING DES ANOMALIES
-- ============================================================================

CREATE OR REPLACE VIEW audit.v_anomalies_dashboard AS
SELECT
    DATE(detected_at) AS date_detection,
    severity,
    layer,
    table_name,
    anomaly_type,
    COUNT(*) AS nb_anomalies,
    COUNT(*) FILTER (WHERE resolved_at IS NOT NULL) AS nb_resolues
FROM audit.data_anomaly
WHERE detected_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(detected_at), severity, layer, table_name, anomaly_type
ORDER BY date_detection DESC,
         CASE severity WHEN 'CRITICAL' THEN 1 WHEN 'ERROR' THEN 2 WHEN 'WARNING' THEN 3 ELSE 4 END;

-- ============================================================================
-- 12. VUE POUR MONITORING ETL
-- ============================================================================

CREATE OR REPLACE VIEW etl.v_job_monitoring AS
SELECT
    DATE(start_time) AS date_execution,
    job_name,
    source_system,
    target_layer,
    COUNT(*) AS nb_executions,
    COUNT(*) FILTER (WHERE status = 'SUCCESS') AS nb_success,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS nb_failed,
    AVG(EXTRACT(EPOCH FROM (end_time - start_time))) AS duree_moyenne_sec,
    SUM(rows_inserted) AS total_inserts,
    SUM(rows_updated) AS total_updates
FROM etl.job_execution
WHERE start_time >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(start_time), job_name, source_system, target_layer
ORDER BY date_execution DESC, job_name;

-- ============================================================================
\echo 'Optimisations DWH appliquees avec succes'

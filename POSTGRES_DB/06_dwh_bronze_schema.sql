-- ============================================================================
-- DATA WAREHOUSE - BRONZE LAYER
-- Donnees brutes extraites des systemes sources
-- ============================================================================

-- Creation de la base de donnees
-- DROP DATABASE IF EXISTS dwh_groupe_duret;
-- CREATE DATABASE dwh_groupe_duret
--     WITH ENCODING = 'UTF8'
--     LC_COLLATE = 'fr_FR.utf8'
--     LC_CTYPE = 'fr_FR.utf8'
--     TEMPLATE = template0;

-- \c dwh_groupe_duret;

-- ============================================================================
-- SCHEMA BRONZE - Donnees brutes avec metadonnees d'ingestion
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS etl;
CREATE SCHEMA IF NOT EXISTS audit;

COMMENT ON SCHEMA bronze IS 'Raw data layer - Donnees brutes des systemes sources';
COMMENT ON SCHEMA silver IS 'Cleaned data layer - Donnees nettoyees et conformees';
COMMENT ON SCHEMA gold IS 'Business layer - Donnees metier, KPIs, dimensions et faits';
COMMENT ON SCHEMA etl IS 'ETL processes - Procedures et fonctions de transformation';
COMMENT ON SCHEMA audit IS 'Audit and lineage - Tracabilite des donnees';

-- ============================================================================
-- TABLES DE CONTROLE ETL
-- ============================================================================

-- Table de suivi des jobs ETL
CREATE TABLE etl.job_execution (
    id BIGSERIAL PRIMARY KEY,
    job_name VARCHAR(100) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    target_layer VARCHAR(20) NOT NULL, -- BRONZE, SILVER, GOLD
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status VARCHAR(20) DEFAULT 'RUNNING', -- RUNNING, SUCCESS, FAILED, WARNING
    rows_read BIGINT DEFAULT 0,
    rows_inserted BIGINT DEFAULT 0,
    rows_updated BIGINT DEFAULT 0,
    rows_deleted BIGINT DEFAULT 0,
    rows_rejected BIGINT DEFAULT 0,
    error_message TEXT,
    execution_parameters JSONB,
    created_by VARCHAR(50) DEFAULT CURRENT_USER
);

CREATE INDEX idx_job_execution_status ON etl.job_execution(status);
CREATE INDEX idx_job_execution_date ON etl.job_execution(start_time);

-- Table de configuration des sources
CREATE TABLE etl.source_config (
    id SERIAL PRIMARY KEY,
    source_name VARCHAR(50) NOT NULL UNIQUE,
    source_type VARCHAR(20) NOT NULL, -- POSTGRES, MSSQL, FILE, API
    connection_string TEXT,
    schema_name VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    extraction_mode VARCHAR(20) DEFAULT 'INCREMENTAL', -- FULL, INCREMENTAL
    watermark_column VARCHAR(50),
    last_extraction TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO etl.source_config (source_name, source_type, schema_name, extraction_mode, watermark_column) VALUES
('SAGE_COMPTA', 'POSTGRES', 'sage_compta', 'INCREMENTAL', 'updated_at'),
('MDE_ERP', 'POSTGRES', 'mde_erp', 'INCREMENTAL', 'updated_at'),
('EXTERNE_METEO', 'API', NULL, 'FULL', NULL),
('EXTERNE_INSEE', 'FILE', NULL, 'FULL', NULL);

-- Table de mapping des colonnes
CREATE TABLE etl.column_mapping (
    id SERIAL PRIMARY KEY,
    source_system VARCHAR(50) NOT NULL,
    source_table VARCHAR(100) NOT NULL,
    source_column VARCHAR(100) NOT NULL,
    target_table VARCHAR(100) NOT NULL,
    target_column VARCHAR(100) NOT NULL,
    transformation_rule TEXT,
    is_key BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- BRONZE : SAGE COMPTA - Tables miroir
-- ============================================================================

-- Metadonnees communes pour toutes les tables bronze
-- _bronze_id: ID unique dans le DWH
-- _source_system: Systeme source
-- _ingestion_time: Horodatage d'extraction
-- _batch_id: ID du batch d'extraction
-- _is_current: Derniere version (pour SCD)
-- _valid_from / _valid_to: Periode de validite

-- Societes SAGE
CREATE TABLE bronze.sage_societe (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    code VARCHAR(10),
    raison_sociale VARCHAR(100),
    siret VARCHAR(14),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    regime_tva VARCHAR(20),
    actif BOOLEAN
);

CREATE INDEX idx_bronze_sage_societe_source ON bronze.sage_societe(_source_id);
CREATE INDEX idx_bronze_sage_societe_batch ON bronze.sage_societe(_batch_id);

-- Comptes generaux SAGE
CREATE TABLE bronze.sage_compte_general (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    numero VARCHAR(13),
    intitule VARCHAR(100),
    type_compte VARCHAR(20),
    classe VARCHAR(1),
    nature VARCHAR(20),
    sens_solde VARCHAR(10),
    lettrable BOOLEAN,
    rapprochable BOOLEAN,
    actif BOOLEAN
);

CREATE INDEX idx_bronze_sage_compte_source ON bronze.sage_compte_general(_source_id);
CREATE INDEX idx_bronze_sage_compte_numero ON bronze.sage_compte_general(numero);

-- Journaux SAGE
CREATE TABLE bronze.sage_journal (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(6),
    libelle VARCHAR(50),
    type_journal VARCHAR(20),
    compte_contrepartie VARCHAR(13),
    actif BOOLEAN
);

-- Exercices SAGE
CREATE TABLE bronze.sage_exercice (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(10),
    libelle VARCHAR(50),
    date_debut DATE,
    date_fin DATE,
    cloture BOOLEAN
);

-- Pieces comptables SAGE
CREATE TABLE bronze.sage_piece (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    exercice_id INTEGER,
    journal_id INTEGER,
    numero_piece VARCHAR(20),
    date_piece DATE,
    libelle VARCHAR(200),
    etat VARCHAR(20),
    origine VARCHAR(20),
    reference_origine VARCHAR(50),
    montant_debit NUMERIC(15,2),
    montant_credit NUMERIC(15,2)
);

CREATE INDEX idx_bronze_sage_piece_date ON bronze.sage_piece(date_piece);
CREATE INDEX idx_bronze_sage_piece_source ON bronze.sage_piece(_source_id);

-- Ecritures comptables SAGE
CREATE TABLE bronze.sage_ecriture (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    piece_id INTEGER,
    ligne_numero INTEGER,
    date_ecriture DATE,
    compte_id INTEGER,
    compte_numero VARCHAR(13),
    compte_tiers VARCHAR(17),
    libelle VARCHAR(200),
    reference VARCHAR(50),
    debit NUMERIC(15,2),
    credit NUMERIC(15,2),
    devise VARCHAR(3),
    date_echeance DATE,
    lettrage VARCHAR(10),
    date_lettrage DATE
);

CREATE INDEX idx_bronze_sage_ecriture_piece ON bronze.sage_ecriture(piece_id);
CREATE INDEX idx_bronze_sage_ecriture_compte ON bronze.sage_ecriture(compte_numero);
CREATE INDEX idx_bronze_sage_ecriture_date ON bronze.sage_ecriture(date_ecriture);

-- Clients SAGE
CREATE TABLE bronze.sage_client (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(17),
    raison_sociale VARCHAR(100),
    compte_general VARCHAR(13),
    siret VARCHAR(14),
    tva_intracom VARCHAR(20),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    mode_reglement VARCHAR(20),
    condition_reglement INTEGER,
    encours_autorise NUMERIC(15,2),
    actif BOOLEAN
);

CREATE INDEX idx_bronze_sage_client_code ON bronze.sage_client(code);

-- Fournisseurs SAGE
CREATE TABLE bronze.sage_fournisseur (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(17),
    raison_sociale VARCHAR(100),
    compte_general VARCHAR(13),
    siret VARCHAR(14),
    tva_intracom VARCHAR(20),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    mode_reglement VARCHAR(20),
    condition_reglement INTEGER,
    actif BOOLEAN
);

CREATE INDEX idx_bronze_sage_fournisseur_code ON bronze.sage_fournisseur(code);

-- Echeances SAGE
CREATE TABLE bronze.sage_echeance (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    type_echeance VARCHAR(20),
    tiers_code VARCHAR(17),
    tiers_type VARCHAR(20),
    numero_piece VARCHAR(20),
    date_piece DATE,
    date_echeance DATE,
    montant_origine NUMERIC(15,2),
    montant_regle NUMERIC(15,2),
    montant_restant NUMERIC(15,2),
    statut VARCHAR(20)
);

CREATE INDEX idx_bronze_sage_echeance_date ON bronze.sage_echeance(date_echeance);

-- Reglements SAGE
CREATE TABLE bronze.sage_reglement (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    banque_id INTEGER,
    type_reglement VARCHAR(20),
    numero VARCHAR(20),
    date_reglement DATE,
    tiers_code VARCHAR(17),
    tiers_type VARCHAR(20),
    montant NUMERIC(15,2),
    mode_reglement VARCHAR(20),
    reference_banque VARCHAR(50),
    statut VARCHAR(20)
);

-- ============================================================================
-- BRONZE : MDE ERP - Tables miroir
-- ============================================================================

-- Clients MDE
CREATE TABLE bronze.mde_client (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(20),
    raison_sociale VARCHAR(150),
    type_client VARCHAR(30),
    siret VARCHAR(14),
    tva_intracom VARCHAR(20),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(150),
    commercial_id INTEGER,
    conditions_paiement INTEGER,
    taux_remise NUMERIC(5,2),
    encours_max NUMERIC(15,2),
    actif BOOLEAN
);

CREATE INDEX idx_bronze_mde_client_code ON bronze.mde_client(code);

-- Fournisseurs MDE
CREATE TABLE bronze.mde_fournisseur (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(20),
    raison_sociale VARCHAR(150),
    type_fournisseur VARCHAR(30),
    siret VARCHAR(14),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(150),
    delai_livraison INTEGER,
    conditions_paiement INTEGER,
    actif BOOLEAN
);

-- Sous-traitants MDE
CREATE TABLE bronze.mde_sous_traitant (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(20),
    raison_sociale VARCHAR(150),
    siret VARCHAR(14),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(150),
    corps_metier VARCHAR(50),
    qualification VARCHAR(50),
    taux_horaire NUMERIC(10,2),
    actif BOOLEAN
);

-- Salaries MDE
CREATE TABLE bronze.mde_salarie (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    matricule VARCHAR(20),
    nom VARCHAR(50),
    prenom VARCHAR(50),
    date_naissance DATE,
    date_entree DATE,
    date_sortie DATE,
    poste VARCHAR(50),
    qualification VARCHAR(30),
    coefficient INTEGER,
    taux_horaire NUMERIC(10,2),
    cout_horaire_charge NUMERIC(10,2),
    responsable_id INTEGER,
    actif BOOLEAN
);

CREATE INDEX idx_bronze_mde_salarie_matricule ON bronze.mde_salarie(matricule);

-- Elements catalogue MDE
CREATE TABLE bronze.mde_element (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(30),
    designation VARCHAR(200),
    type_element VARCHAR(20),
    famille VARCHAR(50),
    sous_famille VARCHAR(50),
    unite VARCHAR(10),
    prix_achat NUMERIC(15,4),
    prix_vente NUMERIC(15,4),
    coefficient_vente NUMERIC(6,2),
    temps_unitaire NUMERIC(10,4),
    fournisseur_principal_id INTEGER,
    compte_achat VARCHAR(13),
    compte_vente VARCHAR(13),
    actif BOOLEAN
);

CREATE INDEX idx_bronze_mde_element_code ON bronze.mde_element(code);
CREATE INDEX idx_bronze_mde_element_type ON bronze.mde_element(type_element);

-- Affaires MDE
CREATE TABLE bronze.mde_affaire (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    code VARCHAR(20),
    libelle VARCHAR(200),
    client_id INTEGER,
    client_code VARCHAR(20),
    commercial_id INTEGER,
    responsable_id INTEGER,
    etat VARCHAR(20),
    type_affaire VARCHAR(30),
    date_creation DATE,
    date_debut_prevue DATE,
    date_fin_prevue DATE,
    date_debut_reelle DATE,
    date_fin_reelle DATE,
    adresse_chantier TEXT,
    cp_chantier VARCHAR(10),
    ville_chantier VARCHAR(100),
    montant_devis NUMERIC(15,2),
    montant_commande NUMERIC(15,2),
    montant_facture NUMERIC(15,2),
    marge_prevue NUMERIC(5,2),
    budget_heures NUMERIC(10,2),
    heures_realisees NUMERIC(10,2)
);

CREATE INDEX idx_bronze_mde_affaire_code ON bronze.mde_affaire(code);
CREATE INDEX idx_bronze_mde_affaire_etat ON bronze.mde_affaire(etat);
CREATE INDEX idx_bronze_mde_affaire_client ON bronze.mde_affaire(client_id);

-- Chantiers MDE
CREATE TABLE bronze.mde_chantier (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    affaire_id INTEGER,
    affaire_code VARCHAR(20),
    code VARCHAR(20),
    libelle VARCHAR(200),
    etat VARCHAR(20),
    chef_chantier_id INTEGER,
    date_debut DATE,
    date_fin_prevue DATE,
    date_fin_reelle DATE,
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    avancement_pct NUMERIC(5,2)
);

CREATE INDEX idx_bronze_mde_chantier_affaire ON bronze.mde_chantier(affaire_id);
CREATE INDEX idx_bronze_mde_chantier_etat ON bronze.mde_chantier(etat);

-- Documents MDE (entetes)
CREATE TABLE bronze.mde_document_entete (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    type_document VARCHAR(20),
    numero VARCHAR(20),
    date_document DATE,
    tiers_id INTEGER,
    tiers_code VARCHAR(20),
    tiers_type VARCHAR(20),
    affaire_id INTEGER,
    affaire_code VARCHAR(20),
    chantier_id INTEGER,
    objet VARCHAR(200),
    montant_ht NUMERIC(15,2),
    montant_tva NUMERIC(15,2),
    montant_ttc NUMERIC(15,2),
    taux_tva NUMERIC(5,2),
    statut VARCHAR(20),
    date_validation DATE,
    document_origine_id INTEGER
);

CREATE INDEX idx_bronze_mde_doc_type ON bronze.mde_document_entete(type_document);
CREATE INDEX idx_bronze_mde_doc_date ON bronze.mde_document_entete(date_document);
CREATE INDEX idx_bronze_mde_doc_affaire ON bronze.mde_document_entete(affaire_id);

-- Documents MDE (lignes)
CREATE TABLE bronze.mde_document_ligne (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    entete_id INTEGER,
    numero_ligne INTEGER,
    element_id INTEGER,
    element_code VARCHAR(30),
    designation VARCHAR(200),
    quantite NUMERIC(15,4),
    unite VARCHAR(10),
    prix_unitaire NUMERIC(15,4),
    remise_pct NUMERIC(5,2),
    montant_ht NUMERIC(15,2),
    taux_tva NUMERIC(5,2)
);

CREATE INDEX idx_bronze_mde_ligne_entete ON bronze.mde_document_ligne(entete_id);

-- Suivi main d'oeuvre MDE
CREATE TABLE bronze.mde_suivi_mo (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    salarie_id INTEGER,
    salarie_matricule VARCHAR(20),
    affaire_id INTEGER,
    affaire_code VARCHAR(20),
    chantier_id INTEGER,
    semaine_iso VARCHAR(10),
    date_debut_semaine DATE,
    heures_normales NUMERIC(6,2),
    heures_supp_25 NUMERIC(6,2),
    heures_supp_50 NUMERIC(6,2),
    heures_nuit NUMERIC(6,2),
    heures_dimanche NUMERIC(6,2),
    heures_deplacement NUMERIC(6,2),
    indemnites_repas NUMERIC(8,2),
    indemnites_trajet NUMERIC(8,2),
    commentaire TEXT
);

CREATE INDEX idx_bronze_mde_suivi_salarie ON bronze.mde_suivi_mo(salarie_id);
CREATE INDEX idx_bronze_mde_suivi_affaire ON bronze.mde_suivi_mo(affaire_id);
CREATE INDEX idx_bronze_mde_suivi_semaine ON bronze.mde_suivi_mo(date_debut_semaine);

-- Mouvements stock MDE
CREATE TABLE bronze.mde_mouvement_stock (
    _bronze_id BIGSERIAL PRIMARY KEY,
    _source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    _ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    _batch_id BIGINT,
    _source_id INTEGER,
    -- Donnees source
    societe_id INTEGER,
    depot_id INTEGER,
    depot_code VARCHAR(20),
    element_id INTEGER,
    element_code VARCHAR(30),
    type_mouvement VARCHAR(20),
    date_mouvement DATE,
    quantite NUMERIC(15,4),
    prix_unitaire NUMERIC(15,4),
    affaire_id INTEGER,
    document_id INTEGER,
    reference VARCHAR(50),
    commentaire TEXT
);

CREATE INDEX idx_bronze_mde_mvt_element ON bronze.mde_mouvement_stock(element_id);
CREATE INDEX idx_bronze_mde_mvt_date ON bronze.mde_mouvement_stock(date_mouvement);

-- ============================================================================
-- TABLES D'AUDIT ET LINEAGE
-- ============================================================================

-- Lignee des donnees
CREATE TABLE audit.data_lineage (
    id BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(50) NOT NULL,
    source_table VARCHAR(100) NOT NULL,
    source_id BIGINT,
    target_layer VARCHAR(20) NOT NULL,
    target_table VARCHAR(100) NOT NULL,
    target_id BIGINT,
    transformation_type VARCHAR(50),
    job_id BIGINT REFERENCES etl.job_execution(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lineage_source ON audit.data_lineage(source_system, source_table, source_id);
CREATE INDEX idx_lineage_target ON audit.data_lineage(target_layer, target_table, target_id);

-- Qualite des donnees
CREATE TABLE audit.data_quality_check (
    id BIGSERIAL PRIMARY KEY,
    check_name VARCHAR(100) NOT NULL,
    layer VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    check_type VARCHAR(50) NOT NULL, -- COMPLETENESS, UNIQUENESS, VALIDITY, CONSISTENCY
    check_query TEXT NOT NULL,
    expected_result TEXT,
    actual_result TEXT,
    passed BOOLEAN,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    job_id BIGINT REFERENCES etl.job_execution(id)
);

-- Anomalies detectees
CREATE TABLE audit.data_anomaly (
    id BIGSERIAL PRIMARY KEY,
    layer VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    anomaly_type VARCHAR(50) NOT NULL,
    description TEXT,
    severity VARCHAR(20) DEFAULT 'WARNING', -- INFO, WARNING, ERROR, CRITICAL
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    resolution_comment TEXT
);

-- ============================================================================
-- FONCTIONS UTILITAIRES BRONZE
-- ============================================================================

-- Fonction pour generer un ID de batch
CREATE OR REPLACE FUNCTION etl.get_next_batch_id()
RETURNS BIGINT AS $$
DECLARE
    v_batch_id BIGINT;
BEGIN
    INSERT INTO etl.job_execution (job_name, source_system, target_layer, status)
    VALUES ('BATCH_' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD_HH24MISS'), 'SYSTEM', 'BRONZE', 'RUNNING')
    RETURNING id INTO v_batch_id;

    RETURN v_batch_id;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour terminer un batch
CREATE OR REPLACE FUNCTION etl.complete_batch(
    p_batch_id BIGINT,
    p_rows_inserted BIGINT DEFAULT 0,
    p_status VARCHAR(20) DEFAULT 'SUCCESS'
)
RETURNS VOID AS $$
BEGIN
    UPDATE etl.job_execution
    SET end_time = CURRENT_TIMESTAMP,
        status = p_status,
        rows_inserted = p_rows_inserted
    WHERE id = p_batch_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VUES BRONZE - Statistiques d'ingestion
-- ============================================================================

CREATE OR REPLACE VIEW bronze.v_ingestion_stats AS
SELECT
    'sage_societe' AS table_name, COUNT(*) AS row_count, MAX(_ingestion_time) AS last_ingestion FROM bronze.sage_societe
UNION ALL SELECT 'sage_compte_general', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_compte_general
UNION ALL SELECT 'sage_journal', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_journal
UNION ALL SELECT 'sage_piece', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_piece
UNION ALL SELECT 'sage_ecriture', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_ecriture
UNION ALL SELECT 'sage_client', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_client
UNION ALL SELECT 'sage_fournisseur', COUNT(*), MAX(_ingestion_time) FROM bronze.sage_fournisseur
UNION ALL SELECT 'mde_client', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_client
UNION ALL SELECT 'mde_fournisseur', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_fournisseur
UNION ALL SELECT 'mde_salarie', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_salarie
UNION ALL SELECT 'mde_element', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_element
UNION ALL SELECT 'mde_affaire', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_affaire
UNION ALL SELECT 'mde_chantier', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_chantier
UNION ALL SELECT 'mde_document_entete', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_document_entete
UNION ALL SELECT 'mde_document_ligne', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_document_ligne
UNION ALL SELECT 'mde_suivi_mo', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_suivi_mo
UNION ALL SELECT 'mde_mouvement_stock', COUNT(*), MAX(_ingestion_time) FROM bronze.mde_mouvement_stock
ORDER BY table_name;

-- ============================================================================
-- FIN BRONZE LAYER
-- ============================================================================

\echo 'Bronze Layer cree avec succes'

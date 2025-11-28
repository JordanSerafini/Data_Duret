-- ============================================================================
-- SAGE 100 COMPTABILITE - PostgreSQL Database Schema
-- Base de donnees comptable du Groupe DURET
-- Migration depuis SQL Server / Structure Sage 100
-- ============================================================================

-- Suppression si existe
DROP DATABASE IF EXISTS sage_compta;
CREATE DATABASE sage_compta
    WITH ENCODING = 'UTF8'
    LC_COLLATE = 'fr_FR.utf8'
    LC_CTYPE = 'fr_FR.utf8'
    TEMPLATE = template0;

\c sage_compta;

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ============================================================================
-- SCHEMA ORGANISATION
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS ref;      -- Referentiels
CREATE SCHEMA IF NOT EXISTS compta;   -- Comptabilite generale
CREATE SCHEMA IF NOT EXISTS tiers;    -- Gestion des tiers
CREATE SCHEMA IF NOT EXISTS tresor;   -- Tresorerie
CREATE SCHEMA IF NOT EXISTS audit;    -- Audit et logs

-- ============================================================================
-- TABLES REFERENTIELS (ref.*)
-- ============================================================================

-- Societes du groupe
CREATE TABLE ref.societe (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    siren VARCHAR(9),
    code_ape VARCHAR(5),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'FRANCE',
    telephone VARCHAR(20),
    email VARCHAR(100),
    capital NUMERIC(15,2),
    forme_juridique VARCHAR(50),
    date_creation DATE,
    exercice_debut DATE,
    exercice_fin DATE,
    devise_defaut VARCHAR(3) DEFAULT 'EUR',
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Devises
CREATE TABLE ref.devise (
    code VARCHAR(3) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    symbole VARCHAR(5),
    taux_euro NUMERIC(18,6) DEFAULT 1.0,
    nb_decimales SMALLINT DEFAULT 2,
    date_maj TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Pays
CREATE TABLE ref.pays (
    code_iso VARCHAR(2) PRIMARY KEY,
    code_iso3 VARCHAR(3),
    nom VARCHAR(100) NOT NULL,
    code_devise VARCHAR(3) REFERENCES ref.devise(code),
    code_telephone VARCHAR(5),
    ue BOOLEAN DEFAULT FALSE
);

-- Modes de reglement
CREATE TABLE ref.mode_reglement (
    code VARCHAR(4) PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    type_reglement VARCHAR(20), -- ESPECES, CHEQUE, VIREMENT, PRELEVEMENT, CB, TRAITE
    nb_jours INTEGER DEFAULT 0,
    fin_de_mois BOOLEAN DEFAULT FALSE,
    actif BOOLEAN DEFAULT TRUE
);

-- Exercices comptables
CREATE TABLE ref.exercice (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(10) NOT NULL,
    libelle VARCHAR(50),
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    cloture BOOLEAN DEFAULT FALSE,
    date_cloture TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- ============================================================================
-- TABLES PLAN COMPTABLE (compta.*)
-- ============================================================================

-- Plan comptable general
CREATE TABLE compta.compte_general (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    numero VARCHAR(13) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    classe CHAR(1) GENERATED ALWAYS AS (LEFT(numero, 1)) STORED,
    type_compte VARCHAR(20), -- BILAN, GESTION, SPECIAL
    nature VARCHAR(20), -- ACTIF, PASSIF, CHARGE, PRODUIT
    sens_defaut CHAR(1), -- D=Debit, C=Credit
    lettrable BOOLEAN DEFAULT FALSE,
    pointable BOOLEAN DEFAULT FALSE,
    collectif BOOLEAN DEFAULT FALSE,
    analytique_oblig BOOLEAN DEFAULT FALSE,
    sommeil BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, numero)
);

CREATE INDEX idx_compte_numero ON compta.compte_general(numero);
CREATE INDEX idx_compte_classe ON compta.compte_general(classe);

-- Plan comptable analytique
CREATE TABLE compta.axe_analytique (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(10) NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    obligatoire BOOLEAN DEFAULT FALSE,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

CREATE TABLE compta.compte_analytique (
    id SERIAL PRIMARY KEY,
    axe_id INTEGER REFERENCES compta.axe_analytique(id),
    numero VARCHAR(13) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES compta.compte_analytique(id),
    niveau SMALLINT DEFAULT 1,
    sommeil BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(axe_id, numero)
);

-- Journaux comptables
CREATE TABLE compta.journal (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(6) NOT NULL,
    intitule VARCHAR(50) NOT NULL,
    type_journal VARCHAR(20) NOT NULL, -- ACHAT, VENTE, TRESORERIE, OD, AN, SITUATION
    compte_contrepartie VARCHAR(13),
    numerotation VARCHAR(20) DEFAULT 'CONTINUE', -- CONTINUE, MENSUELLE, PERIODIQUE
    dernier_numero INTEGER DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

-- Taux de TVA
CREATE TABLE compta.taux_tva (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    taux NUMERIC(5,2) NOT NULL,
    type_tva VARCHAR(20), -- NORMAL, INTERMEDIAIRE, REDUIT, SUPER_REDUIT, EXONERE
    compte_tva_collectee VARCHAR(13),
    compte_tva_deductible VARCHAR(13),
    date_debut DATE,
    date_fin DATE,
    actif BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- TABLES TIERS (tiers.*)
-- ============================================================================

-- Table principale des tiers (clients et fournisseurs)
CREATE TABLE tiers.tiers (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(17) NOT NULL,
    type_tiers VARCHAR(15) NOT NULL, -- CLIENT, FOURNISSEUR, SALARIE
    intitule VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    code_ape VARCHAR(5),
    numero_tva VARCHAR(20),
    -- Coordonnees
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(2) REFERENCES ref.pays(code_iso),
    telephone VARCHAR(25),
    telecopie VARCHAR(25),
    email VARCHAR(100),
    site_web VARCHAR(200),
    -- Comptabilite
    compte_collectif VARCHAR(13),
    mode_reglement_code VARCHAR(4) REFERENCES ref.mode_reglement(code),
    encours_autorise NUMERIC(15,2) DEFAULT 0,
    -- Banque principale
    banque_nom VARCHAR(50),
    banque_bic VARCHAR(11),
    banque_iban VARCHAR(34),
    -- Metadata
    sommeil BOOLEAN DEFAULT FALSE,
    bloque BOOLEAN DEFAULT FALSE,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

CREATE INDEX idx_tiers_code ON tiers.tiers(code);
CREATE INDEX idx_tiers_type ON tiers.tiers(type_tiers);
CREATE INDEX idx_tiers_intitule ON tiers.tiers USING gin(intitule gin_trgm_ops);

-- Adresses multiples des tiers
CREATE TABLE tiers.tiers_adresse (
    id SERIAL PRIMARY KEY,
    tiers_id INTEGER REFERENCES tiers.tiers(id) ON DELETE CASCADE,
    type_adresse VARCHAR(20) NOT NULL, -- PRINCIPALE, FACTURATION, LIVRAISON
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(2) REFERENCES ref.pays(code_iso),
    contact_nom VARCHAR(50),
    contact_telephone VARCHAR(25),
    contact_email VARCHAR(100),
    defaut BOOLEAN DEFAULT FALSE
);

-- Contacts des tiers
CREATE TABLE tiers.tiers_contact (
    id SERIAL PRIMARY KEY,
    tiers_id INTEGER REFERENCES tiers.tiers(id) ON DELETE CASCADE,
    civilite VARCHAR(10),
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50),
    fonction VARCHAR(50),
    telephone VARCHAR(25),
    portable VARCHAR(25),
    email VARCHAR(100),
    principal BOOLEAN DEFAULT FALSE
);

-- RIB multiples des tiers
CREATE TABLE tiers.tiers_banque (
    id SERIAL PRIMARY KEY,
    tiers_id INTEGER REFERENCES tiers.tiers(id) ON DELETE CASCADE,
    intitule VARCHAR(50),
    banque_nom VARCHAR(50),
    code_banque VARCHAR(5),
    code_guichet VARCHAR(5),
    numero_compte VARCHAR(20),
    cle_rib VARCHAR(2),
    bic VARCHAR(11),
    iban VARCHAR(34),
    domiciliation VARCHAR(100),
    pays_code VARCHAR(2) REFERENCES ref.pays(code_iso),
    principal BOOLEAN DEFAULT FALSE
);

-- ============================================================================
-- TABLES ECRITURES COMPTABLES (compta.*)
-- ============================================================================

-- Pieces comptables (entetes)
CREATE TABLE compta.piece (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    exercice_id INTEGER REFERENCES ref.exercice(id),
    journal_id INTEGER REFERENCES compta.journal(id),
    numero_piece VARCHAR(20) NOT NULL,
    date_piece DATE NOT NULL,
    libelle VARCHAR(100),
    devise_code VARCHAR(3) REFERENCES ref.devise(code) DEFAULT 'EUR',
    taux_devise NUMERIC(18,6) DEFAULT 1,
    total_debit NUMERIC(18,2) DEFAULT 0,
    total_credit NUMERIC(18,2) DEFAULT 0,
    etat VARCHAR(20) DEFAULT 'BROUILLARD', -- BROUILLARD, VALIDE, CLOTURE
    origine VARCHAR(50), -- SAISIE, IMPORT, FACTURE, etc.
    reference_origine VARCHAR(50),
    date_validation TIMESTAMP,
    utilisateur_validation VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_piece_date ON compta.piece(date_piece);
CREATE INDEX idx_piece_journal ON compta.piece(journal_id);
CREATE INDEX idx_piece_numero ON compta.piece(numero_piece);

-- Lignes d'ecritures comptables
CREATE TABLE compta.ecriture (
    id BIGSERIAL PRIMARY KEY,
    piece_id INTEGER REFERENCES compta.piece(id) ON DELETE CASCADE,
    ligne_numero SMALLINT NOT NULL,
    date_ecriture DATE NOT NULL,
    compte_id INTEGER REFERENCES compta.compte_general(id),
    compte_numero VARCHAR(13) NOT NULL,
    tiers_id INTEGER REFERENCES tiers.tiers(id),
    libelle VARCHAR(100),
    reference VARCHAR(35),
    debit NUMERIC(18,2) DEFAULT 0,
    credit NUMERIC(18,2) DEFAULT 0,
    debit_devise NUMERIC(18,2) DEFAULT 0,
    credit_devise NUMERIC(18,2) DEFAULT 0,
    -- Echeance
    date_echeance DATE,
    mode_reglement_code VARCHAR(4),
    -- Lettrage
    lettre VARCHAR(8),
    date_lettrage DATE,
    -- Rapprochement bancaire
    rapprochement VARCHAR(8),
    date_rapprochement DATE,
    -- Analytique
    analytique_id INTEGER REFERENCES compta.compte_analytique(id),
    -- TVA
    taux_tva_id INTEGER REFERENCES compta.taux_tva(id),
    base_tva NUMERIC(18,2),
    -- Quantite
    quantite NUMERIC(18,4),
    unite VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ecriture_date ON compta.ecriture(date_ecriture);
CREATE INDEX idx_ecriture_compte ON compta.ecriture(compte_numero);
CREATE INDEX idx_ecriture_tiers ON compta.ecriture(tiers_id);
CREATE INDEX idx_ecriture_lettre ON compta.ecriture(lettre) WHERE lettre IS NOT NULL;

-- ============================================================================
-- TABLES TRESORERIE (tresor.*)
-- ============================================================================

-- Banques de la societe
CREATE TABLE tresor.banque (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(10) NOT NULL,
    intitule VARCHAR(50) NOT NULL,
    -- Etablissement bancaire
    nom_banque VARCHAR(50),
    adresse VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    -- Coordonnees bancaires
    code_banque VARCHAR(5),
    code_guichet VARCHAR(5),
    numero_compte VARCHAR(20),
    cle_rib VARCHAR(2),
    bic VARCHAR(11),
    iban VARCHAR(34),
    -- Comptabilite
    compte_comptable VARCHAR(13),
    journal_id INTEGER REFERENCES compta.journal(id),
    -- Conditions
    decouvert_autorise NUMERIC(15,2) DEFAULT 0,
    taux_debit NUMERIC(5,2) DEFAULT 0,
    taux_credit NUMERIC(5,2) DEFAULT 0,
    frais_tenue_compte NUMERIC(10,2) DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

-- Echeances (balance agee)
CREATE TABLE tresor.echeance (
    id BIGSERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    tiers_id INTEGER REFERENCES tiers.tiers(id),
    type_echeance VARCHAR(15) NOT NULL, -- CLIENT, FOURNISSEUR
    -- Document origine
    document_type VARCHAR(20), -- FACTURE, AVOIR, OD
    document_numero VARCHAR(20),
    document_date DATE,
    -- Echeance
    date_echeance DATE NOT NULL,
    montant_origine NUMERIC(18,2) NOT NULL,
    montant_regle NUMERIC(18,2) DEFAULT 0,
    montant_restant NUMERIC(18,2) GENERATED ALWAYS AS (montant_origine - montant_regle) STORED,
    devise_code VARCHAR(3) DEFAULT 'EUR',
    -- Reglement
    mode_reglement_code VARCHAR(4) REFERENCES ref.mode_reglement(code),
    -- Etat
    etat VARCHAR(20) DEFAULT 'A_REGLER', -- A_REGLER, PARTIEL, REGLE, LITIGE
    date_reglement DATE,
    -- Lien ecriture
    ecriture_id BIGINT REFERENCES compta.ecriture(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_echeance_date ON tresor.echeance(date_echeance);
CREATE INDEX idx_echeance_tiers ON tresor.echeance(tiers_id);
CREATE INDEX idx_echeance_etat ON tresor.echeance(etat);

-- Reglements
CREATE TABLE tresor.reglement (
    id BIGSERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    type_reglement VARCHAR(15) NOT NULL, -- ENCAISSEMENT, DECAISSEMENT
    date_reglement DATE NOT NULL,
    montant NUMERIC(18,2) NOT NULL,
    devise_code VARCHAR(3) DEFAULT 'EUR',
    mode_reglement_code VARCHAR(4) REFERENCES ref.mode_reglement(code),
    banque_id INTEGER REFERENCES tresor.banque(id),
    tiers_id INTEGER REFERENCES tiers.tiers(id),
    -- Informations cheque/virement
    numero_piece VARCHAR(20),
    reference VARCHAR(50),
    libelle VARCHAR(100),
    -- Remise en banque
    remise_id INTEGER,
    date_remise DATE,
    -- Etat
    etat VARCHAR(20) DEFAULT 'SAISI', -- SAISI, REMIS, ENCAISSE, REJETE
    date_valeur DATE,
    -- Lien comptable
    piece_id INTEGER REFERENCES compta.piece(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lien reglement/echeances
CREATE TABLE tresor.reglement_echeance (
    id SERIAL PRIMARY KEY,
    reglement_id BIGINT REFERENCES tresor.reglement(id) ON DELETE CASCADE,
    echeance_id BIGINT REFERENCES tresor.echeance(id),
    montant_affecte NUMERIC(18,2) NOT NULL
);

-- Mandats SEPA
CREATE TABLE tresor.mandat_sepa (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    tiers_id INTEGER REFERENCES tiers.tiers(id),
    rum VARCHAR(35) NOT NULL UNIQUE, -- Reference Unique du Mandat
    date_signature DATE NOT NULL,
    type_mandat VARCHAR(20), -- CORE, B2B
    type_paiement VARCHAR(20), -- RECURRENT, PONCTUEL
    iban_debiteur VARCHAR(34),
    bic_debiteur VARCHAR(11),
    statut VARCHAR(20) DEFAULT 'ACTIF', -- ACTIF, SUSPENDU, REVOQUE
    date_dernier_prelevement DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLES AUDIT (audit.*)
-- ============================================================================

CREATE TABLE audit.log_operation (
    id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    utilisateur VARCHAR(50),
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- FONCTIONS ET TRIGGERS
-- ============================================================================

-- Fonction de mise a jour du timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de mise a jour
CREATE TRIGGER tr_societe_timestamp BEFORE UPDATE ON ref.societe
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER tr_tiers_timestamp BEFORE UPDATE ON tiers.tiers
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER tr_piece_timestamp BEFORE UPDATE ON compta.piece
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Fonction de verification equilibre piece
CREATE OR REPLACE FUNCTION check_piece_equilibree()
RETURNS TRIGGER AS $$
DECLARE
    v_total_debit NUMERIC(18,2);
    v_total_credit NUMERIC(18,2);
BEGIN
    SELECT COALESCE(SUM(debit), 0), COALESCE(SUM(credit), 0)
    INTO v_total_debit, v_total_credit
    FROM compta.ecriture
    WHERE piece_id = NEW.piece_id;

    UPDATE compta.piece
    SET total_debit = v_total_debit,
        total_credit = v_total_credit
    WHERE id = NEW.piece_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_ecriture_equilibre AFTER INSERT OR UPDATE OR DELETE ON compta.ecriture
FOR EACH ROW EXECUTE FUNCTION check_piece_equilibree();

-- ============================================================================
-- VUES UTILES
-- ============================================================================

-- Vue balance generale
CREATE OR REPLACE VIEW compta.v_balance_generale AS
SELECT
    cg.societe_id,
    cg.numero AS compte,
    cg.intitule,
    cg.classe,
    COALESCE(SUM(e.debit), 0) AS total_debit,
    COALESCE(SUM(e.credit), 0) AS total_credit,
    COALESCE(SUM(e.debit), 0) - COALESCE(SUM(e.credit), 0) AS solde
FROM compta.compte_general cg
LEFT JOIN compta.ecriture e ON cg.id = e.compte_id
GROUP BY cg.societe_id, cg.id, cg.numero, cg.intitule, cg.classe
ORDER BY cg.numero;

-- Vue balance agee clients
CREATE OR REPLACE VIEW tresor.v_balance_agee_clients AS
SELECT
    t.code AS code_client,
    t.intitule AS nom_client,
    SUM(CASE WHEN e.date_echeance >= CURRENT_DATE THEN e.montant_restant ELSE 0 END) AS non_echu,
    SUM(CASE WHEN e.date_echeance < CURRENT_DATE AND e.date_echeance >= CURRENT_DATE - 30 THEN e.montant_restant ELSE 0 END) AS echu_0_30,
    SUM(CASE WHEN e.date_echeance < CURRENT_DATE - 30 AND e.date_echeance >= CURRENT_DATE - 60 THEN e.montant_restant ELSE 0 END) AS echu_30_60,
    SUM(CASE WHEN e.date_echeance < CURRENT_DATE - 60 AND e.date_echeance >= CURRENT_DATE - 90 THEN e.montant_restant ELSE 0 END) AS echu_60_90,
    SUM(CASE WHEN e.date_echeance < CURRENT_DATE - 90 THEN e.montant_restant ELSE 0 END) AS echu_plus_90,
    SUM(e.montant_restant) AS total_du
FROM tresor.echeance e
JOIN tiers.tiers t ON e.tiers_id = t.id
WHERE e.type_echeance = 'CLIENT' AND e.etat != 'REGLE'
GROUP BY t.id, t.code, t.intitule
ORDER BY total_du DESC;

-- Vue grand livre
CREATE OR REPLACE VIEW compta.v_grand_livre AS
SELECT
    p.date_piece,
    j.code AS journal,
    p.numero_piece,
    cg.numero AS compte,
    cg.intitule AS libelle_compte,
    e.libelle,
    e.reference,
    t.code AS code_tiers,
    t.intitule AS nom_tiers,
    e.debit,
    e.credit,
    SUM(e.debit - e.credit) OVER (PARTITION BY cg.id ORDER BY p.date_piece, p.id, e.ligne_numero) AS solde_cumule
FROM compta.ecriture e
JOIN compta.piece p ON e.piece_id = p.id
JOIN compta.journal j ON p.journal_id = j.id
JOIN compta.compte_general cg ON e.compte_id = cg.id
LEFT JOIN tiers.tiers t ON e.tiers_id = t.id
ORDER BY cg.numero, p.date_piece, p.id, e.ligne_numero;

COMMENT ON DATABASE sage_compta IS 'Base de donnees SAGE 100 Comptabilite - Groupe DURET - Migration PostgreSQL';

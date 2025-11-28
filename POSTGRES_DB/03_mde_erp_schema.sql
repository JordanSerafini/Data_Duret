-- ============================================================================
-- MDE ERP - PostgreSQL Database Schema
-- Gestion des Affaires, Chantiers et Documents - Groupe DURET
-- Migration depuis SQL Server / Structure MDE Batiment
-- ============================================================================

-- Suppression si existe
DROP DATABASE IF EXISTS mde_erp;
CREATE DATABASE mde_erp
    WITH ENCODING = 'UTF8'
    LC_COLLATE = 'fr_FR.utf8'
    LC_CTYPE = 'fr_FR.utf8'
    TEMPLATE = template0;

\c mde_erp;

-- ============================================================================
-- EXTENSIONS
-- ============================================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ============================================================================
-- SCHEMAS
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS ref;        -- Referentiels
CREATE SCHEMA IF NOT EXISTS tiers;      -- Gestion des tiers
CREATE SCHEMA IF NOT EXISTS affaire;    -- Gestion des affaires
CREATE SCHEMA IF NOT EXISTS chantier;   -- Gestion des chantiers
CREATE SCHEMA IF NOT EXISTS document;   -- Documents commerciaux
CREATE SCHEMA IF NOT EXISTS stock;      -- Gestion des stocks
CREATE SCHEMA IF NOT EXISTS planning;   -- Planning et ressources
CREATE SCHEMA IF NOT EXISTS compta;     -- Interface comptable

-- ============================================================================
-- TYPES ENUMERES
-- ============================================================================
CREATE TYPE ref.type_tiers AS ENUM ('CLIENT', 'FOURNISSEUR', 'SOUS_TRAITANT', 'ARCHITECTE', 'SALARIE');
CREATE TYPE ref.etat_affaire AS ENUM ('PROSPECT', 'ETUDE', 'DEVIS', 'ACCEPTE', 'EN_COURS', 'TERMINE', 'ANNULE', 'ARCHIVE');
CREATE TYPE ref.etat_chantier AS ENUM ('A_PLANIFIER', 'PLANIFIE', 'EN_COURS', 'SUSPENDU', 'TERMINE', 'CLOTURE');
CREATE TYPE ref.type_document AS ENUM ('DEVIS', 'COMMANDE', 'BON_LIVRAISON', 'FACTURE', 'AVOIR', 'SITUATION', 'DGD');
CREATE TYPE ref.categorie_achat_vente AS ENUM ('VENTE_FRANCE', 'VENTE_CEE', 'VENTE_EXPORT', 'ACHAT_FRANCE', 'ACHAT_CEE', 'ACHAT_IMPORT');
CREATE TYPE ref.nature_element AS ENUM ('FOURNITURE', 'MAIN_OEUVRE', 'MATERIEL', 'SOUS_TRAITANCE', 'FRAIS', 'OUVRAGE');
CREATE TYPE ref.type_mvt_stock AS ENUM ('ENTREE', 'SORTIE', 'TRANSFERT', 'INVENTAIRE', 'RETOUR');

-- ============================================================================
-- TABLES REFERENTIELS (ref.*)
-- ============================================================================

-- Societes du groupe (dossiers)
CREATE TABLE ref.societe (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    raison_sociale VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    code_ape VARCHAR(5),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    date_creation DATE,
    actif BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Devises
CREATE TABLE ref.devise (
    code VARCHAR(4) PRIMARY KEY,
    nom VARCHAR(30),
    symbole VARCHAR(3),
    taux_euro NUMERIC(18,6) DEFAULT 1.0,
    code_iso VARCHAR(3),
    actif BOOLEAN DEFAULT TRUE
);

-- Pays
CREATE TABLE ref.pays (
    code VARCHAR(5) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    code_devise VARCHAR(4) REFERENCES ref.devise(code),
    code_nomenclature_deb VARCHAR(2)
);

-- Modes de reglement
CREATE TABLE ref.mode_reglement (
    code VARCHAR(10) PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    nb_jours INTEGER DEFAULT 0,
    fin_de_mois BOOLEAN DEFAULT FALSE,
    type_paiement VARCHAR(20)
);

-- Unites de mesure
CREATE TABLE ref.unite_mesure (
    code VARCHAR(5) PRIMARY KEY,
    libelle VARCHAR(30) NOT NULL,
    type_unite VARCHAR(20) -- QUANTITE, TEMPS, SURFACE, VOLUME, LONGUEUR
);

-- Taux de TVA
CREATE TABLE ref.taux_tva (
    id SERIAL PRIMARY KEY,
    code VARCHAR(5) NOT NULL UNIQUE,
    libelle VARCHAR(30),
    taux NUMERIC(5,2) NOT NULL,
    compte_collecte VARCHAR(13),
    compte_deductible VARCHAR(13),
    actif BOOLEAN DEFAULT TRUE
);

-- Categories achat/vente
CREATE TABLE ref.categorie_av (
    code VARCHAR(1) PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL,
    type_categorie ref.categorie_achat_vente,
    journal_vente VARCHAR(6),
    journal_achat VARCHAR(6),
    tva_autoliquidee BOOLEAN DEFAULT FALSE
);

-- Nature des travaux
CREATE TABLE ref.nature_travaux (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    actif BOOLEAN DEFAULT TRUE
);

-- Types de marche
CREATE TABLE ref.type_marche (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL
);

-- Etats d'affaire
CREATE TABLE ref.etat_affaire_param (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    ordre INTEGER,
    couleur VARCHAR(7) -- Code couleur hex
);

-- Etats de chantier
CREATE TABLE ref.etat_chantier_param (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    ordre INTEGER
);

-- Etats de document
CREATE TABLE ref.etat_document (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    type_document ref.type_document
);

-- Natures d'elements (configuration)
CREATE TABLE ref.config_nature_element (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    nature ref.nature_element NOT NULL,
    compte_vente VARCHAR(13),
    compte_achat VARCHAR(13),
    taux_tva_id INTEGER REFERENCES ref.taux_tva(id)
);

-- Postes de travaux
CREATE TABLE ref.poste_travaux (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES ref.poste_travaux(id),
    niveau INTEGER DEFAULT 1
);

-- Activites (centres de profit)
CREATE TABLE ref.activite (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    responsable_id INTEGER
);

-- Secteurs geographiques
CREATE TABLE ref.secteur_geo (
    id SERIAL PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL
);

-- Depots
CREATE TABLE ref.depot (
    id SERIAL PRIMARY KEY,
    code VARCHAR(8) NOT NULL UNIQUE,
    libelle VARCHAR(50) NOT NULL,
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    responsable_id INTEGER,
    depot_principal BOOLEAN DEFAULT FALSE,
    actif BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- TABLES TIERS (tiers.*)
-- ============================================================================

-- Clients
CREATE TABLE tiers.client (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    numero_tva VARCHAR(20),
    -- Adresse principale
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(5) REFERENCES ref.pays(code),
    -- Contacts
    telephone VARCHAR(25),
    telecopie VARCHAR(25),
    email VARCHAR(100),
    site_web VARCHAR(200),
    -- Commercial
    charge_affaire_id INTEGER,
    secteur_geo_id INTEGER REFERENCES ref.secteur_geo(id),
    mode_reglement_code VARCHAR(10) REFERENCES ref.mode_reglement(code),
    categorie_av_code VARCHAR(1) REFERENCES ref.categorie_av(code),
    encours_max NUMERIC(15,2) DEFAULT 0,
    -- Comptabilite
    compte_collectif VARCHAR(13),
    devise_code VARCHAR(4) REFERENCES ref.devise(code) DEFAULT 'EUR',
    -- Statut
    statut_id INTEGER,
    sommeil BOOLEAN DEFAULT FALSE,
    bloque BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

CREATE INDEX idx_client_code ON tiers.client(code);
CREATE INDEX idx_client_intitule ON tiers.client USING gin(intitule gin_trgm_ops);

-- Fournisseurs
CREATE TABLE tiers.fournisseur (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    numero_tva VARCHAR(20),
    -- Adresse
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(5) REFERENCES ref.pays(code),
    -- Contacts
    telephone VARCHAR(25),
    email VARCHAR(100),
    -- Commercial
    mode_reglement_code VARCHAR(10) REFERENCES ref.mode_reglement(code),
    categorie_av_code VARCHAR(1) REFERENCES ref.categorie_av(code),
    delai_livraison INTEGER DEFAULT 0,
    franco_port NUMERIC(10,2) DEFAULT 0,
    -- Comptabilite
    compte_collectif VARCHAR(13),
    devise_code VARCHAR(4) REFERENCES ref.devise(code) DEFAULT 'EUR',
    -- Statut
    sommeil BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- Sous-traitants
CREATE TABLE tiers.sous_traitant (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    siret VARCHAR(14),
    numero_tva VARCHAR(20),
    adresse_ligne1 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(5) REFERENCES ref.pays(code),
    telephone VARCHAR(25),
    email VARCHAR(100),
    -- Qualifications
    qualification TEXT,
    assurance_rc VARCHAR(50),
    date_validite_assurance DATE,
    -- Commercial
    mode_reglement_code VARCHAR(10) REFERENCES ref.mode_reglement(code),
    compte_collectif VARCHAR(13),
    sommeil BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- Architectes / Maitres d'oeuvre
CREATE TABLE tiers.architecte (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    adresse_ligne1 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    telephone VARCHAR(25),
    email VARCHAR(100),
    numero_ordre VARCHAR(20),
    activite_id INTEGER REFERENCES ref.activite(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- Salaries
CREATE TABLE tiers.salarie (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    matricule VARCHAR(15),
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50),
    -- Coordonnees
    adresse VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    telephone VARCHAR(25),
    portable VARCHAR(25),
    email VARCHAR(100),
    -- Emploi
    fonction VARCHAR(50),
    service VARCHAR(50),
    date_entree DATE,
    date_sortie DATE,
    type_contrat VARCHAR(20), -- CDI, CDD, INTERIM, APPRENTI
    qualification VARCHAR(50),
    -- Tarification
    cout_horaire NUMERIC(10,2) DEFAULT 0,
    cout_journalier NUMERIC(10,2) DEFAULT 0,
    -- Statut
    actif BOOLEAN DEFAULT TRUE,
    conducteur_travaux BOOLEAN DEFAULT FALSE,
    chef_equipe BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- Equipes
CREATE TABLE tiers.equipe (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    libelle VARCHAR(50) NOT NULL,
    chef_equipe_id INTEGER REFERENCES tiers.salarie(id),
    cout_horaire NUMERIC(10,2) DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

-- Composition des equipes
CREATE TABLE tiers.equipe_membre (
    id SERIAL PRIMARY KEY,
    equipe_id INTEGER REFERENCES tiers.equipe(id) ON DELETE CASCADE,
    salarie_id INTEGER REFERENCES tiers.salarie(id),
    date_debut DATE,
    date_fin DATE
);

-- Charge d'affaires
CREATE TABLE tiers.charge_affaire (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(100) NOT NULL,
    salarie_id INTEGER REFERENCES tiers.salarie(id),
    activite_id INTEGER REFERENCES ref.activite(id),
    secteur_geo_id INTEGER REFERENCES ref.secteur_geo(id),
    email VARCHAR(100),
    telephone VARCHAR(25),
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

-- ============================================================================
-- TABLES ARTICLES / ELEMENTS (ref.*)
-- ============================================================================

-- Bibliotheques d'articles
CREATE TABLE ref.bibliotheque (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    type_biblio VARCHAR(20), -- INTERNE, FOURNISSEUR, STANDARD
    fournisseur_id INTEGER
);

-- Elements / Articles
CREATE TABLE ref.element (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(30) NOT NULL,
    designation VARCHAR(200) NOT NULL,
    designation_longue TEXT,
    -- Classification
    nature_id INTEGER REFERENCES ref.config_nature_element(id),
    bibliotheque_id INTEGER REFERENCES ref.bibliotheque(id),
    famille VARCHAR(50),
    sous_famille VARCHAR(50),
    -- Caracteristiques
    unite_mesure_code VARCHAR(5) REFERENCES ref.unite_mesure(code),
    poids NUMERIC(10,3),
    volume NUMERIC(10,4),
    -- Prix
    prix_achat NUMERIC(15,4) DEFAULT 0,
    prix_vente NUMERIC(15,4) DEFAULT 0,
    coefficient NUMERIC(8,4) DEFAULT 1,
    remise_max NUMERIC(5,2) DEFAULT 0,
    -- TVA
    taux_tva_id INTEGER REFERENCES ref.taux_tva(id),
    -- Stock
    gere_en_stock BOOLEAN DEFAULT FALSE,
    stock_mini NUMERIC(15,4) DEFAULT 0,
    stock_maxi NUMERIC(15,4) DEFAULT 0,
    delai_appro INTEGER DEFAULT 0,
    -- Statut
    actif BOOLEAN DEFAULT TRUE,
    sommeil BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

CREATE INDEX idx_element_code ON ref.element(code);
CREATE INDEX idx_element_designation ON ref.element USING gin(designation gin_trgm_ops);

-- Tarifs fournisseurs par article
CREATE TABLE ref.element_fournisseur (
    id SERIAL PRIMARY KEY,
    element_id INTEGER REFERENCES ref.element(id) ON DELETE CASCADE,
    fournisseur_id INTEGER REFERENCES tiers.fournisseur(id),
    reference_fournisseur VARCHAR(50),
    prix_achat NUMERIC(15,4),
    remise NUMERIC(5,2) DEFAULT 0,
    delai_livraison INTEGER DEFAULT 0,
    quantite_mini NUMERIC(15,4) DEFAULT 1,
    conditionnement NUMERIC(15,4) DEFAULT 1,
    date_validite DATE,
    fournisseur_principal BOOLEAN DEFAULT FALSE
);

-- Ouvrages (compositions)
CREATE TABLE ref.ouvrage (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(30) NOT NULL,
    designation VARCHAR(200) NOT NULL,
    unite_mesure_code VARCHAR(5) REFERENCES ref.unite_mesure(code),
    prix_vente_unitaire NUMERIC(15,4) DEFAULT 0,
    temps_unitaire NUMERIC(10,4) DEFAULT 0,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, code)
);

-- Composition des ouvrages
CREATE TABLE ref.ouvrage_composition (
    id SERIAL PRIMARY KEY,
    ouvrage_id INTEGER REFERENCES ref.ouvrage(id) ON DELETE CASCADE,
    ligne_numero INTEGER,
    element_id INTEGER REFERENCES ref.element(id),
    quantite NUMERIC(15,4) DEFAULT 1,
    coefficient NUMERIC(8,4) DEFAULT 1
);

-- ============================================================================
-- TABLES AFFAIRES (affaire.*)
-- ============================================================================

-- Affaires
CREATE TABLE affaire.affaire (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(200) NOT NULL,
    -- Client
    client_id INTEGER REFERENCES tiers.client(id),
    client_final_id INTEGER,
    -- Adresse chantier
    adresse_chantier VARCHAR(100),
    code_postal_chantier VARCHAR(10),
    ville_chantier VARCHAR(50),
    -- Classification
    nature_travaux_id INTEGER REFERENCES ref.nature_travaux(id),
    type_marche_id INTEGER REFERENCES ref.type_marche(id),
    activite_id INTEGER REFERENCES ref.activite(id),
    -- Responsables
    charge_affaire_id INTEGER REFERENCES tiers.charge_affaire(id),
    architecte_id INTEGER REFERENCES tiers.architecte(id),
    -- Etat et dates
    etat ref.etat_affaire DEFAULT 'PROSPECT',
    date_creation DATE DEFAULT CURRENT_DATE,
    date_acceptation DATE,
    date_debut_prevue DATE,
    date_fin_prevue DATE,
    date_fin_reelle DATE,
    -- Montants marche
    montant_marche_ht NUMERIC(15,2) DEFAULT 0,
    montant_avenant_ht NUMERIC(15,2) DEFAULT 0,
    montant_total_ht NUMERIC(15,2) GENERATED ALWAYS AS (montant_marche_ht + montant_avenant_ht) STORED,
    -- Budget previsionnel
    budget_fournitures NUMERIC(15,2) DEFAULT 0,
    budget_main_oeuvre NUMERIC(15,2) DEFAULT 0,
    budget_sous_traitance NUMERIC(15,2) DEFAULT 0,
    budget_materiel NUMERIC(15,2) DEFAULT 0,
    budget_frais NUMERIC(15,2) DEFAULT 0,
    -- Avancement
    pct_avancement NUMERIC(5,2) DEFAULT 0,
    montant_facture_ht NUMERIC(15,2) DEFAULT 0,
    montant_encaisse NUMERIC(15,2) DEFAULT 0,
    -- Notes
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

CREATE INDEX idx_affaire_code ON affaire.affaire(code);
CREATE INDEX idx_affaire_client ON affaire.affaire(client_id);
CREATE INDEX idx_affaire_etat ON affaire.affaire(etat);

-- Documents contractuels de l'affaire
CREATE TABLE affaire.affaire_document (
    id SERIAL PRIMARY KEY,
    affaire_id INTEGER REFERENCES affaire.affaire(id) ON DELETE CASCADE,
    type_document VARCHAR(50),
    numero_document VARCHAR(50),
    date_document DATE,
    montant_ht NUMERIC(15,2),
    fichier_path VARCHAR(500),
    notes TEXT
);

-- Clients multiples sur une affaire
CREATE TABLE affaire.affaire_client (
    id SERIAL PRIMARY KEY,
    affaire_id INTEGER REFERENCES affaire.affaire(id) ON DELETE CASCADE,
    client_id INTEGER REFERENCES tiers.client(id),
    type_client VARCHAR(20), -- PRINCIPAL, PAYEUR, DESTINATAIRE
    quote_part NUMERIC(5,2) DEFAULT 100
);

-- Actions commerciales sur l'affaire
CREATE TABLE affaire.affaire_action (
    id SERIAL PRIMARY KEY,
    affaire_id INTEGER REFERENCES affaire.affaire(id) ON DELETE CASCADE,
    action_type VARCHAR(50),
    date_action TIMESTAMP,
    description TEXT,
    responsable_id INTEGER REFERENCES tiers.salarie(id),
    date_rappel DATE,
    termine BOOLEAN DEFAULT FALSE
);

-- Calendrier de l'affaire
CREATE TABLE affaire.affaire_calendrier (
    id SERIAL PRIMARY KEY,
    affaire_id INTEGER REFERENCES affaire.affaire(id) ON DELETE CASCADE,
    date_jalon DATE NOT NULL,
    libelle VARCHAR(100),
    type_jalon VARCHAR(50), -- DEBUT, FIN, RECEPTION, LEVEE_RESERVES
    realise BOOLEAN DEFAULT FALSE,
    date_reelle DATE
);

-- ============================================================================
-- TABLES CHANTIERS (chantier.*)
-- ============================================================================

-- Chantiers (decoupage de l'affaire)
CREATE TABLE chantier.chantier (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    affaire_id INTEGER REFERENCES affaire.affaire(id),
    code VARCHAR(20) NOT NULL,
    intitule VARCHAR(200) NOT NULL,
    -- Client
    client_id INTEGER REFERENCES tiers.client(id),
    -- Localisation
    adresse VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    -- Classification
    nature_travaux_id INTEGER REFERENCES ref.nature_travaux(id),
    -- Responsables
    conducteur_travaux_id INTEGER REFERENCES tiers.salarie(id),
    chef_equipe_id INTEGER REFERENCES tiers.salarie(id),
    -- Etat et dates
    etat ref.etat_chantier DEFAULT 'A_PLANIFIER',
    date_debut_prevue DATE,
    date_fin_prevue DATE,
    date_debut_reelle DATE,
    date_fin_reelle DATE,
    -- Montants
    montant_ht NUMERIC(15,2) DEFAULT 0,
    -- Avancement
    pct_avancement NUMERIC(5,2) DEFAULT 0,
    -- Notes
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

CREATE INDEX idx_chantier_affaire ON chantier.chantier(affaire_id);
CREATE INDEX idx_chantier_etat ON chantier.chantier(etat);

-- Budget detaille par nature (previsionnel)
CREATE TABLE chantier.chantier_budget (
    id SERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id) ON DELETE CASCADE,
    nature_id INTEGER REFERENCES ref.config_nature_element(id),
    budget_prevu NUMERIC(15,2) DEFAULT 0,
    budget_engage NUMERIC(15,2) DEFAULT 0,
    budget_realise NUMERIC(15,2) DEFAULT 0
);

-- Coefficients de frais generaux
CREATE TABLE chantier.chantier_coeff_fg (
    id SERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id) ON DELETE CASCADE,
    nature_id INTEGER REFERENCES ref.config_nature_element(id),
    coefficient NUMERIC(8,4) DEFAULT 1
);

-- Suivi main d'oeuvre
CREATE TABLE chantier.suivi_mo (
    id BIGSERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    salarie_id INTEGER REFERENCES tiers.salarie(id),
    date_travail DATE NOT NULL,
    heures_normales NUMERIC(5,2) DEFAULT 0,
    heures_sup_25 NUMERIC(5,2) DEFAULT 0,
    heures_sup_50 NUMERIC(5,2) DEFAULT 0,
    heures_nuit NUMERIC(5,2) DEFAULT 0,
    heures_dimanche NUMERIC(5,2) DEFAULT 0,
    deplacements INTEGER DEFAULT 0,
    paniers INTEGER DEFAULT 0,
    notes VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_suivi_mo_chantier_date ON chantier.suivi_mo(chantier_id, date_travail);

-- Suivi fournitures consommees
CREATE TABLE chantier.suivi_fournitures (
    id BIGSERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    element_id INTEGER REFERENCES ref.element(id),
    date_consommation DATE NOT NULL,
    quantite NUMERIC(15,4),
    prix_unitaire NUMERIC(15,4),
    montant_total NUMERIC(15,2),
    bon_sortie_id INTEGER,
    notes VARCHAR(200)
);

-- Suivi sous-traitance
CREATE TABLE chantier.suivi_sst (
    id BIGSERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    sous_traitant_id INTEGER REFERENCES tiers.sous_traitant(id),
    date_intervention DATE NOT NULL,
    description TEXT,
    montant_prevu NUMERIC(15,2),
    montant_realise NUMERIC(15,2),
    bon_commande_id INTEGER
);

-- Suivi materiel
CREATE TABLE chantier.suivi_materiel (
    id BIGSERIAL PRIMARY KEY,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    materiel_id INTEGER,
    date_debut DATE NOT NULL,
    date_fin DATE,
    nb_jours INTEGER,
    cout_journalier NUMERIC(10,2),
    montant_total NUMERIC(15,2),
    notes VARCHAR(200)
);

-- ============================================================================
-- TABLES DOCUMENTS COMMERCIAUX (document.*)
-- ============================================================================

-- Entete de documents (devis, commandes, factures, etc.)
CREATE TABLE document.entete_document (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    type_document ref.type_document NOT NULL,
    numero VARCHAR(20) NOT NULL,
    -- Dates
    date_document DATE NOT NULL,
    date_validite DATE,
    date_livraison DATE,
    -- Tiers
    tiers_type ref.type_tiers NOT NULL,
    tiers_id INTEGER NOT NULL,
    -- Adresse facturation
    fact_intitule VARCHAR(100),
    fact_adresse VARCHAR(100),
    fact_code_postal VARCHAR(10),
    fact_ville VARCHAR(50),
    fact_pays VARCHAR(50),
    -- Adresse livraison
    liv_intitule VARCHAR(100),
    liv_adresse VARCHAR(100),
    liv_code_postal VARCHAR(10),
    liv_ville VARCHAR(50),
    -- Affaire/Chantier
    affaire_id INTEGER REFERENCES affaire.affaire(id),
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    -- Commercial
    redacteur_id INTEGER REFERENCES tiers.salarie(id),
    categorie_av_code VARCHAR(1) REFERENCES ref.categorie_av(code),
    mode_reglement_code VARCHAR(10) REFERENCES ref.mode_reglement(code),
    -- Devise
    devise_code VARCHAR(4) REFERENCES ref.devise(code) DEFAULT 'EUR',
    taux_devise NUMERIC(18,6) DEFAULT 1,
    -- Montants
    montant_ht NUMERIC(15,2) DEFAULT 0,
    montant_remise NUMERIC(15,2) DEFAULT 0,
    montant_net_ht NUMERIC(15,2) DEFAULT 0,
    montant_tva NUMERIC(15,2) DEFAULT 0,
    montant_ttc NUMERIC(15,2) DEFAULT 0,
    -- Etat
    etat_id INTEGER REFERENCES ref.etat_document(id),
    -- Reference externe
    reference_client VARCHAR(50),
    reference_commande VARCHAR(50),
    -- Observations
    observations TEXT,
    conditions_paiement TEXT,
    -- Tracabilite
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transfere_compta BOOLEAN DEFAULT FALSE,
    date_transfert_compta TIMESTAMP,
    UNIQUE(societe_id, type_document, numero)
);

CREATE INDEX idx_document_type ON document.entete_document(type_document);
CREATE INDEX idx_document_date ON document.entete_document(date_document);
CREATE INDEX idx_document_tiers ON document.entete_document(tiers_type, tiers_id);
CREATE INDEX idx_document_affaire ON document.entete_document(affaire_id);

-- Lignes de documents
CREATE TABLE document.ligne_document (
    id BIGSERIAL PRIMARY KEY,
    entete_id INTEGER REFERENCES document.entete_document(id) ON DELETE CASCADE,
    ligne_numero INTEGER NOT NULL,
    -- Type de ligne
    type_ligne VARCHAR(20) DEFAULT 'ARTICLE', -- ARTICLE, TEXTE, TITRE, SOUS_TOTAL, POSTE
    -- Article
    element_id INTEGER REFERENCES ref.element(id),
    code_article VARCHAR(30),
    designation VARCHAR(500),
    -- Chantier (si plusieurs chantiers dans le doc)
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    -- Poste de travaux
    poste_travaux_id INTEGER REFERENCES ref.poste_travaux(id),
    -- Quantites
    quantite NUMERIC(15,4) DEFAULT 0,
    unite_code VARCHAR(5),
    -- Prix
    prix_unitaire NUMERIC(15,4) DEFAULT 0,
    remise_pct NUMERIC(5,2) DEFAULT 0,
    remise_montant NUMERIC(15,4) DEFAULT 0,
    montant_net_ht NUMERIC(15,2) DEFAULT 0,
    -- TVA
    taux_tva_id INTEGER REFERENCES ref.taux_tva(id),
    montant_tva NUMERIC(15,2) DEFAULT 0,
    -- Stock
    depot_id INTEGER REFERENCES ref.depot(id),
    -- Analytique
    nature_id INTEGER REFERENCES ref.config_nature_element(id)
);

CREATE INDEX idx_ligne_document_entete ON document.ligne_document(entete_id);

-- Pieds de document (TVA, port, etc.)
CREATE TABLE document.pied_document (
    id SERIAL PRIMARY KEY,
    entete_id INTEGER REFERENCES document.entete_document(id) ON DELETE CASCADE,
    type_pied VARCHAR(20), -- TVA, PORT, ESCOMPTE, FRAIS
    taux_tva_id INTEGER REFERENCES ref.taux_tva(id),
    base_ht NUMERIC(15,2) DEFAULT 0,
    taux NUMERIC(5,2) DEFAULT 0,
    montant NUMERIC(15,2) DEFAULT 0
);

-- Situations de travaux
CREATE TABLE document.situation (
    id SERIAL PRIMARY KEY,
    entete_id INTEGER REFERENCES document.entete_document(id) ON DELETE CASCADE,
    numero_situation INTEGER DEFAULT 1,
    date_situation DATE NOT NULL,
    -- Cumuls
    cumul_anterieur_ht NUMERIC(15,2) DEFAULT 0,
    travaux_periode_ht NUMERIC(15,2) DEFAULT 0,
    cumul_actuel_ht NUMERIC(15,2) DEFAULT 0,
    -- Retenues
    retenue_garantie_taux NUMERIC(5,2) DEFAULT 0,
    retenue_garantie_montant NUMERIC(15,2) DEFAULT 0,
    -- Acomptes
    acompte_verse NUMERIC(15,2) DEFAULT 0,
    -- Net a payer
    net_a_payer NUMERIC(15,2) DEFAULT 0
);

-- Detail des situations par poste
CREATE TABLE document.situation_detail (
    id BIGSERIAL PRIMARY KEY,
    situation_id INTEGER REFERENCES document.situation(id) ON DELETE CASCADE,
    ligne_document_id BIGINT REFERENCES document.ligne_document(id),
    -- Avancement
    quantite_marche NUMERIC(15,4) DEFAULT 0,
    quantite_anterieure NUMERIC(15,4) DEFAULT 0,
    quantite_periode NUMERIC(15,4) DEFAULT 0,
    quantite_cumul NUMERIC(15,4) DEFAULT 0,
    pct_avancement NUMERIC(5,2) DEFAULT 0,
    -- Montants
    montant_marche_ht NUMERIC(15,2) DEFAULT 0,
    montant_anterieur_ht NUMERIC(15,2) DEFAULT 0,
    montant_periode_ht NUMERIC(15,2) DEFAULT 0,
    montant_cumul_ht NUMERIC(15,2) DEFAULT 0
);

-- Lien entre documents (devis -> commande -> facture)
CREATE TABLE document.lien_document (
    id SERIAL PRIMARY KEY,
    document_source_id INTEGER REFERENCES document.entete_document(id),
    document_cible_id INTEGER REFERENCES document.entete_document(id),
    type_lien VARCHAR(20), -- TRANSFORMATION, FACTURE_PARTIELLE, AVOIR
    date_lien TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLES STOCK (stock.*)
-- ============================================================================

-- Stock par depot et article
CREATE TABLE stock.stock_article (
    id SERIAL PRIMARY KEY,
    element_id INTEGER REFERENCES ref.element(id),
    depot_id INTEGER REFERENCES ref.depot(id),
    quantite_stock NUMERIC(15,4) DEFAULT 0,
    quantite_reservee NUMERIC(15,4) DEFAULT 0,
    quantite_commandee NUMERIC(15,4) DEFAULT 0,
    quantite_disponible NUMERIC(15,4) GENERATED ALWAYS AS (quantite_stock - quantite_reservee + quantite_commandee) STORED,
    prix_moyen_pondere NUMERIC(15,4) DEFAULT 0,
    dernier_prix_achat NUMERIC(15,4) DEFAULT 0,
    date_dernier_mvt DATE,
    UNIQUE(element_id, depot_id)
);

-- Mouvements de stock
CREATE TABLE stock.mouvement (
    id BIGSERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    element_id INTEGER REFERENCES ref.element(id),
    depot_id INTEGER REFERENCES ref.depot(id),
    depot_destination_id INTEGER REFERENCES ref.depot(id),
    -- Mouvement
    type_mvt ref.type_mvt_stock NOT NULL,
    date_mvt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantite NUMERIC(15,4) NOT NULL,
    prix_unitaire NUMERIC(15,4),
    montant_total NUMERIC(15,2),
    -- Origine
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    document_id INTEGER REFERENCES document.entete_document(id),
    ligne_document_id BIGINT,
    -- Lot/Serie
    numero_lot VARCHAR(35),
    numero_serie VARCHAR(35),
    -- Reference
    reference VARCHAR(50),
    libelle VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_mvt_stock_element ON stock.mouvement(element_id);
CREATE INDEX idx_mvt_stock_date ON stock.mouvement(date_mvt);
CREATE INDEX idx_mvt_stock_depot ON stock.mouvement(depot_id);

-- Bons de sortie chantier
CREATE TABLE stock.bon_sortie (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    numero VARCHAR(20) NOT NULL,
    date_bon DATE NOT NULL,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    depot_id INTEGER REFERENCES ref.depot(id),
    demandeur_id INTEGER REFERENCES tiers.salarie(id),
    validateur_id INTEGER REFERENCES tiers.salarie(id),
    etat VARCHAR(20) DEFAULT 'BROUILLON', -- BROUILLON, VALIDE, ANNULE
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, numero)
);

-- Lignes bon de sortie
CREATE TABLE stock.bon_sortie_ligne (
    id SERIAL PRIMARY KEY,
    bon_sortie_id INTEGER REFERENCES stock.bon_sortie(id) ON DELETE CASCADE,
    element_id INTEGER REFERENCES ref.element(id),
    quantite_demandee NUMERIC(15,4),
    quantite_servie NUMERIC(15,4),
    emplacement VARCHAR(50)
);

-- Inventaires
CREATE TABLE stock.inventaire (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code VARCHAR(20) NOT NULL,
    date_inventaire DATE NOT NULL,
    depot_id INTEGER REFERENCES ref.depot(id),
    etat VARCHAR(20) DEFAULT 'EN_COURS', -- EN_COURS, VALIDE, ANNULE
    responsable_id INTEGER REFERENCES tiers.salarie(id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code)
);

-- Lignes d'inventaire
CREATE TABLE stock.inventaire_ligne (
    id BIGSERIAL PRIMARY KEY,
    inventaire_id INTEGER REFERENCES stock.inventaire(id) ON DELETE CASCADE,
    element_id INTEGER REFERENCES ref.element(id),
    quantite_theorique NUMERIC(15,4),
    quantite_comptee NUMERIC(15,4),
    ecart NUMERIC(15,4) GENERATED ALWAYS AS (quantite_comptee - quantite_theorique) STORED,
    valorisation_theorique NUMERIC(15,2),
    valorisation_comptee NUMERIC(15,2),
    notes VARCHAR(200)
);

-- ============================================================================
-- TABLES PLANNING (planning.*)
-- ============================================================================

-- Planning des taches
CREATE TABLE planning.tache (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    affaire_id INTEGER REFERENCES affaire.affaire(id),
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    code VARCHAR(20),
    libelle VARCHAR(200) NOT NULL,
    -- Dates
    date_debut_prevue DATE,
    date_fin_prevue DATE,
    date_debut_reelle DATE,
    date_fin_reelle DATE,
    duree_prevue NUMERIC(10,2), -- en heures
    duree_reelle NUMERIC(10,2),
    -- Avancement
    pct_avancement NUMERIC(5,2) DEFAULT 0,
    -- Dependances
    tache_predecesseur_id INTEGER REFERENCES planning.tache(id),
    type_liaison VARCHAR(10) DEFAULT 'FD', -- FD, DD, FF, DF
    decalage INTEGER DEFAULT 0,
    -- Responsable
    responsable_id INTEGER REFERENCES tiers.salarie(id),
    -- Statut
    etat VARCHAR(20) DEFAULT 'A_FAIRE', -- A_FAIRE, EN_COURS, TERMINE, ANNULE
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tache_chantier ON planning.tache(chantier_id);
CREATE INDEX idx_tache_dates ON planning.tache(date_debut_prevue, date_fin_prevue);

-- Affectation des ressources aux taches
CREATE TABLE planning.tache_ressource (
    id SERIAL PRIMARY KEY,
    tache_id INTEGER REFERENCES planning.tache(id) ON DELETE CASCADE,
    type_ressource VARCHAR(20), -- SALARIE, EQUIPE, MATERIEL
    ressource_id INTEGER,
    heures_prevues NUMERIC(10,2),
    heures_reelles NUMERIC(10,2) DEFAULT 0
);

-- Planning des salaries
CREATE TABLE planning.planning_salarie (
    id SERIAL PRIMARY KEY,
    salarie_id INTEGER REFERENCES tiers.salarie(id),
    date_planning DATE NOT NULL,
    chantier_id INTEGER REFERENCES chantier.chantier(id),
    tache_id INTEGER REFERENCES planning.tache(id),
    heures_prevues NUMERIC(5,2),
    notes VARCHAR(200)
);

CREATE INDEX idx_planning_salarie ON planning.planning_salarie(salarie_id, date_planning);

-- Conges et absences
CREATE TABLE planning.absence (
    id SERIAL PRIMARY KEY,
    salarie_id INTEGER REFERENCES tiers.salarie(id),
    type_absence VARCHAR(30), -- CP, RTT, MALADIE, FORMATION, AUTRE
    date_debut DATE NOT NULL,
    date_fin DATE NOT NULL,
    nb_jours NUMERIC(5,2),
    valide BOOLEAN DEFAULT FALSE,
    validateur_id INTEGER REFERENCES tiers.salarie(id),
    notes TEXT
);

-- ============================================================================
-- TABLES INTERFACE COMPTABLE (compta.*)
-- ============================================================================

-- Lignes a transferer en comptabilite
CREATE TABLE compta.transfert_ligne (
    id BIGSERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    -- Source
    document_id INTEGER REFERENCES document.entete_document(id),
    ligne_document_id BIGINT,
    -- Ecriture
    journal VARCHAR(6) NOT NULL,
    date_ecriture DATE NOT NULL,
    compte VARCHAR(13) NOT NULL,
    compte_tiers VARCHAR(17),
    reference VARCHAR(17),
    libelle VARCHAR(60),
    montant NUMERIC(15,2),
    sens INTEGER, -- 1=Debit, -1=Credit
    devise VARCHAR(4) DEFAULT 'EUR',
    montant_devise NUMERIC(15,2),
    -- Analytique
    code_analytique VARCHAR(13),
    -- TVA
    code_tva VARCHAR(5),
    taux_tva NUMERIC(5,2),
    -- Statut
    transfere BOOLEAN DEFAULT FALSE,
    date_transfert TIMESTAMP,
    piece_comptable VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transfert_document ON compta.transfert_ligne(document_id);
CREATE INDEX idx_transfert_statut ON compta.transfert_ligne(transfere);

-- ============================================================================
-- FONCTIONS ET TRIGGERS
-- ============================================================================

-- Mise a jour automatique des timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_societe_timestamp BEFORE UPDATE ON ref.societe FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER tr_client_timestamp BEFORE UPDATE ON tiers.client FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER tr_element_timestamp BEFORE UPDATE ON ref.element FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER tr_affaire_timestamp BEFORE UPDATE ON affaire.affaire FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER tr_document_timestamp BEFORE UPDATE ON document.entete_document FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Recalcul totaux document
CREATE OR REPLACE FUNCTION recalculer_totaux_document()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE document.entete_document
    SET montant_ht = COALESCE((
            SELECT SUM(montant_net_ht)
            FROM document.ligne_document
            WHERE entete_id = NEW.entete_id AND type_ligne = 'ARTICLE'
        ), 0),
        montant_tva = COALESCE((
            SELECT SUM(montant_tva)
            FROM document.ligne_document
            WHERE entete_id = NEW.entete_id
        ), 0)
    WHERE id = NEW.entete_id;

    UPDATE document.entete_document
    SET montant_net_ht = montant_ht - montant_remise,
        montant_ttc = montant_ht - montant_remise + montant_tva
    WHERE id = NEW.entete_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_ligne_document_totaux AFTER INSERT OR UPDATE OR DELETE ON document.ligne_document
FOR EACH ROW EXECUTE FUNCTION recalculer_totaux_document();

-- ============================================================================
-- VUES
-- ============================================================================

-- Vue synthese affaires
CREATE OR REPLACE VIEW affaire.v_synthese_affaire AS
SELECT
    a.id,
    a.code,
    a.intitule,
    c.intitule AS client,
    a.etat,
    a.date_creation,
    a.montant_total_ht,
    a.budget_fournitures + a.budget_main_oeuvre + a.budget_sous_traitance + a.budget_materiel + a.budget_frais AS budget_total,
    a.pct_avancement,
    a.montant_facture_ht,
    a.montant_total_ht - a.montant_facture_ht AS reste_a_facturer,
    ca.intitule AS charge_affaire,
    COUNT(DISTINCT ch.id) AS nb_chantiers
FROM affaire.affaire a
LEFT JOIN tiers.client c ON a.client_id = c.id
LEFT JOIN tiers.charge_affaire ca ON a.charge_affaire_id = ca.id
LEFT JOIN chantier.chantier ch ON ch.affaire_id = a.id
GROUP BY a.id, c.intitule, ca.intitule;

-- Vue synthese chantiers
CREATE OR REPLACE VIEW chantier.v_synthese_chantier AS
SELECT
    ch.id,
    ch.code,
    ch.intitule,
    a.code AS code_affaire,
    a.intitule AS affaire,
    c.intitule AS client,
    ch.etat,
    ch.date_debut_prevue,
    ch.date_fin_prevue,
    ch.montant_ht,
    ch.pct_avancement,
    s.nom || ' ' || s.prenom AS conducteur_travaux
FROM chantier.chantier ch
LEFT JOIN affaire.affaire a ON ch.affaire_id = a.id
LEFT JOIN tiers.client c ON ch.client_id = c.id
LEFT JOIN tiers.salarie s ON ch.conducteur_travaux_id = s.id;

-- Vue CA par client
CREATE OR REPLACE VIEW document.v_ca_client AS
SELECT
    c.id AS client_id,
    c.code AS code_client,
    c.intitule AS client,
    EXTRACT(YEAR FROM d.date_document) AS annee,
    EXTRACT(MONTH FROM d.date_document) AS mois,
    SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_net_ht ELSE 0 END) AS ca_facture,
    SUM(CASE WHEN d.type_document = 'AVOIR' THEN d.montant_net_ht ELSE 0 END) AS avoirs,
    SUM(CASE WHEN d.type_document = 'FACTURE' THEN d.montant_net_ht ELSE -d.montant_net_ht END) AS ca_net
FROM tiers.client c
JOIN document.entete_document d ON d.tiers_id = c.id AND d.tiers_type = 'CLIENT'
WHERE d.type_document IN ('FACTURE', 'AVOIR')
GROUP BY c.id, c.code, c.intitule, EXTRACT(YEAR FROM d.date_document), EXTRACT(MONTH FROM d.date_document);

COMMENT ON DATABASE mde_erp IS 'Base de donnees MDE ERP - Gestion des Affaires et Chantiers - Groupe DURET';

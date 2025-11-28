-- ============================================================================
-- DATA WAREHOUSE - SILVER LAYER
-- Donnees nettoyees, conformees et historisees (SCD Type 2)
-- ============================================================================

\c dwh_groupe_duret;

-- ============================================================================
-- SILVER : DIMENSIONS CONFORMEES
-- ============================================================================

-- Dimension Temps (generee)
CREATE TABLE silver.dim_temps (
    date_key INTEGER PRIMARY KEY, -- Format YYYYMMDD
    date_complete DATE NOT NULL UNIQUE,
    jour_semaine INTEGER, -- 1=Lundi, 7=Dimanche
    jour_semaine_nom VARCHAR(15),
    jour_mois INTEGER,
    jour_annee INTEGER,
    semaine_iso INTEGER,
    semaine_annee VARCHAR(10), -- 2024-W01
    mois INTEGER,
    mois_nom VARCHAR(15),
    mois_abrege VARCHAR(3),
    trimestre INTEGER,
    trimestre_nom VARCHAR(10), -- T1, T2, T3, T4
    semestre INTEGER,
    annee INTEGER,
    annee_mois VARCHAR(7), -- 2024-01
    annee_trimestre VARCHAR(7), -- 2024-T1
    est_weekend BOOLEAN,
    est_jour_ferie BOOLEAN DEFAULT FALSE,
    nom_jour_ferie VARCHAR(50),
    est_fin_mois BOOLEAN,
    est_fin_trimestre BOOLEAN,
    est_fin_annee BOOLEAN,
    nb_jours_ouvres_mois INTEGER,
    nb_jours_ouvres_restants_mois INTEGER
);

-- Generer la dimension temps (2020-2030)
INSERT INTO silver.dim_temps
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d AS date_complete,
    EXTRACT(ISODOW FROM d)::INTEGER AS jour_semaine,
    TO_CHAR(d, 'TMDay') AS jour_semaine_nom,
    EXTRACT(DAY FROM d)::INTEGER AS jour_mois,
    EXTRACT(DOY FROM d)::INTEGER AS jour_annee,
    EXTRACT(WEEK FROM d)::INTEGER AS semaine_iso,
    TO_CHAR(d, 'IYYY') || '-W' || LPAD(EXTRACT(WEEK FROM d)::TEXT, 2, '0') AS semaine_annee,
    EXTRACT(MONTH FROM d)::INTEGER AS mois,
    TO_CHAR(d, 'TMMonth') AS mois_nom,
    TO_CHAR(d, 'Mon') AS mois_abrege,
    EXTRACT(QUARTER FROM d)::INTEGER AS trimestre,
    'T' || EXTRACT(QUARTER FROM d)::TEXT AS trimestre_nom,
    CASE WHEN EXTRACT(MONTH FROM d) <= 6 THEN 1 ELSE 2 END AS semestre,
    EXTRACT(YEAR FROM d)::INTEGER AS annee,
    TO_CHAR(d, 'YYYY-MM') AS annee_mois,
    EXTRACT(YEAR FROM d)::TEXT || '-T' || EXTRACT(QUARTER FROM d)::TEXT AS annee_trimestre,
    EXTRACT(ISODOW FROM d) IN (6, 7) AS est_weekend,
    FALSE AS est_jour_ferie,
    NULL AS nom_jour_ferie,
    d = (DATE_TRUNC('MONTH', d) + INTERVAL '1 month - 1 day')::DATE AS est_fin_mois,
    d = (DATE_TRUNC('QUARTER', d) + INTERVAL '3 months - 1 day')::DATE AS est_fin_trimestre,
    EXTRACT(MONTH FROM d) = 12 AND EXTRACT(DAY FROM d) = 31 AS est_fin_annee,
    0 AS nb_jours_ouvres_mois,
    0 AS nb_jours_ouvres_restants_mois
FROM generate_series('2020-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) AS d;

-- Mise a jour des jours feries francais
UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Jour de l''an'
WHERE mois = 1 AND jour_mois = 1;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Fete du travail'
WHERE mois = 5 AND jour_mois = 1;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Victoire 1945'
WHERE mois = 5 AND jour_mois = 8;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Fete nationale'
WHERE mois = 7 AND jour_mois = 14;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Assomption'
WHERE mois = 8 AND jour_mois = 15;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Toussaint'
WHERE mois = 11 AND jour_mois = 1;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Armistice 1918'
WHERE mois = 11 AND jour_mois = 11;

UPDATE silver.dim_temps SET est_jour_ferie = TRUE, nom_jour_ferie = 'Noel'
WHERE mois = 12 AND jour_mois = 25;

CREATE INDEX idx_dim_temps_date ON silver.dim_temps(date_complete);
CREATE INDEX idx_dim_temps_annee_mois ON silver.dim_temps(annee, mois);

-- ============================================================================
-- Dimension Societe (SCD Type 2)
-- ============================================================================

CREATE TABLE silver.dim_societe (
    societe_sk SERIAL PRIMARY KEY, -- Surrogate key
    societe_nk VARCHAR(20) NOT NULL, -- Natural key (code)
    source_system VARCHAR(20) NOT NULL,
    source_id INTEGER,
    code VARCHAR(10),
    raison_sociale VARCHAR(100),
    siret VARCHAR(14),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    departement VARCHAR(3),
    region VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    regime_tva VARCHAR(20),
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    -- Hash pour detection changements
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_societe_nk ON silver.dim_societe(societe_nk, is_current);
CREATE INDEX idx_dim_societe_current ON silver.dim_societe(is_current) WHERE is_current = TRUE;

-- ============================================================================
-- Dimension Client unifie (fusion SAGE + MDE)
-- ============================================================================

CREATE TABLE silver.dim_client (
    client_sk SERIAL PRIMARY KEY,
    client_nk VARCHAR(30) NOT NULL, -- code_source:code
    source_system VARCHAR(20) NOT NULL,
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    code VARCHAR(20),
    raison_sociale VARCHAR(150),
    type_client VARCHAR(30),
    siret VARCHAR(14),
    siren VARCHAR(9) GENERATED ALWAYS AS (SUBSTRING(siret FROM 1 FOR 9)) STORED,
    tva_intracom VARCHAR(20),
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    departement VARCHAR(3),
    region VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'FRANCE',
    telephone VARCHAR(20),
    email VARCHAR(150),
    mode_reglement VARCHAR(20),
    conditions_paiement INTEGER,
    encours_max NUMERIC(15,2),
    taux_remise NUMERIC(5,2),
    -- Champs calcules
    segment_client VARCHAR(20), -- PREMIUM, STANDARD, OCCASIONNEL
    score_risque INTEGER, -- 1-100
    -- Liens cross-system
    sage_code VARCHAR(17),
    mde_code VARCHAR(20),
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_client_nk ON silver.dim_client(client_nk, is_current);
CREATE INDEX idx_dim_client_current ON silver.dim_client(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_dim_client_siret ON silver.dim_client(siret);
CREATE INDEX idx_dim_client_ville ON silver.dim_client(ville);

-- ============================================================================
-- Dimension Fournisseur unifie
-- ============================================================================

CREATE TABLE silver.dim_fournisseur (
    fournisseur_sk SERIAL PRIMARY KEY,
    fournisseur_nk VARCHAR(30) NOT NULL,
    source_system VARCHAR(20) NOT NULL,
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    code VARCHAR(20),
    raison_sociale VARCHAR(150),
    type_fournisseur VARCHAR(30),
    siret VARCHAR(14),
    siren VARCHAR(9) GENERATED ALWAYS AS (SUBSTRING(siret FROM 1 FOR 9)) STORED,
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    departement VARCHAR(3),
    region VARCHAR(50),
    pays VARCHAR(50) DEFAULT 'FRANCE',
    telephone VARCHAR(20),
    email VARCHAR(150),
    mode_reglement VARCHAR(20),
    conditions_paiement INTEGER,
    delai_livraison INTEGER,
    -- Liens cross-system
    sage_code VARCHAR(17),
    mde_code VARCHAR(20),
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_fournisseur_nk ON silver.dim_fournisseur(fournisseur_nk, is_current);
CREATE INDEX idx_dim_fournisseur_current ON silver.dim_fournisseur(is_current) WHERE is_current = TRUE;

-- ============================================================================
-- Dimension Salarie
-- ============================================================================

CREATE TABLE silver.dim_salarie (
    salarie_sk SERIAL PRIMARY KEY,
    salarie_nk VARCHAR(30) NOT NULL, -- societe:matricule
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    matricule VARCHAR(20),
    nom VARCHAR(50),
    prenom VARCHAR(50),
    nom_complet VARCHAR(100) GENERATED ALWAYS AS (prenom || ' ' || nom) STORED,
    date_naissance DATE,
    age INTEGER,
    date_entree DATE,
    date_sortie DATE,
    anciennete_mois INTEGER,
    poste VARCHAR(50),
    categorie_poste VARCHAR(30), -- OUVRIER, ETAM, CADRE
    qualification VARCHAR(30),
    coefficient INTEGER,
    taux_horaire NUMERIC(10,2),
    cout_horaire_charge NUMERIC(10,2),
    responsable_sk INTEGER,
    est_actif BOOLEAN,
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_salarie_nk ON silver.dim_salarie(salarie_nk, is_current);
CREATE INDEX idx_dim_salarie_current ON silver.dim_salarie(is_current) WHERE is_current = TRUE;
CREATE INDEX idx_dim_salarie_matricule ON silver.dim_salarie(matricule);

-- ============================================================================
-- Dimension Element (catalogue articles/ouvrages)
-- ============================================================================

CREATE TABLE silver.dim_element (
    element_sk SERIAL PRIMARY KEY,
    element_nk VARCHAR(40) NOT NULL,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    code VARCHAR(30),
    designation VARCHAR(200),
    type_element VARCHAR(20),
    famille VARCHAR(50),
    sous_famille VARCHAR(50),
    unite VARCHAR(10),
    prix_achat_standard NUMERIC(15,4),
    prix_vente_standard NUMERIC(15,4),
    marge_standard_pct NUMERIC(6,2),
    temps_unitaire_heures NUMERIC(10,4),
    compte_achat VARCHAR(13),
    compte_vente VARCHAR(13),
    fournisseur_principal_sk INTEGER,
    est_actif BOOLEAN,
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_element_nk ON silver.dim_element(element_nk, is_current);
CREATE INDEX idx_dim_element_type ON silver.dim_element(type_element);
CREATE INDEX idx_dim_element_famille ON silver.dim_element(famille);

-- ============================================================================
-- Dimension Compte General
-- ============================================================================

CREATE TABLE silver.dim_compte (
    compte_sk SERIAL PRIMARY KEY,
    compte_nk VARCHAR(30) NOT NULL,
    source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    numero VARCHAR(13),
    intitule VARCHAR(100),
    type_compte VARCHAR(20),
    classe VARCHAR(1),
    classe_libelle VARCHAR(50),
    nature VARCHAR(20),
    sens_solde VARCHAR(10),
    niveau_agregation INTEGER, -- 1=classe, 2=sous-classe, 3=compte, 4=sous-compte
    compte_parent VARCHAR(13),
    est_lettrable BOOLEAN,
    est_rapprochable BOOLEAN,
    est_actif BOOLEAN,
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_compte_nk ON silver.dim_compte(compte_nk, is_current);
CREATE INDEX idx_dim_compte_numero ON silver.dim_compte(numero);
CREATE INDEX idx_dim_compte_classe ON silver.dim_compte(classe);

-- Libelles des classes comptables
UPDATE silver.dim_compte SET classe_libelle = CASE classe
    WHEN '1' THEN 'Capitaux'
    WHEN '2' THEN 'Immobilisations'
    WHEN '3' THEN 'Stocks'
    WHEN '4' THEN 'Tiers'
    WHEN '5' THEN 'Financier'
    WHEN '6' THEN 'Charges'
    WHEN '7' THEN 'Produits'
    WHEN '8' THEN 'Speciaux'
    ELSE 'Autre'
END;

-- ============================================================================
-- Dimension Affaire
-- ============================================================================

CREATE TABLE silver.dim_affaire (
    affaire_sk SERIAL PRIMARY KEY,
    affaire_nk VARCHAR(30) NOT NULL,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    commercial_sk INTEGER REFERENCES silver.dim_salarie(salarie_sk),
    responsable_sk INTEGER REFERENCES silver.dim_salarie(salarie_sk),
    code VARCHAR(20),
    libelle VARCHAR(200),
    etat VARCHAR(20),
    etat_groupe VARCHAR(20), -- EN_COURS, TERMINE, ANNULE
    type_affaire VARCHAR(30),
    date_creation DATE,
    date_debut_prevue DATE,
    date_fin_prevue DATE,
    date_debut_reelle DATE,
    date_fin_reelle DATE,
    duree_prevue_jours INTEGER,
    duree_reelle_jours INTEGER,
    adresse_chantier TEXT,
    code_postal_chantier VARCHAR(10),
    ville_chantier VARCHAR(100),
    departement_chantier VARCHAR(3),
    region_chantier VARCHAR(50),
    montant_devis NUMERIC(15,2),
    montant_commande NUMERIC(15,2),
    budget_heures NUMERIC(10,2),
    marge_prevue_pct NUMERIC(5,2),
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_affaire_nk ON silver.dim_affaire(affaire_nk, is_current);
CREATE INDEX idx_dim_affaire_code ON silver.dim_affaire(code);
CREATE INDEX idx_dim_affaire_etat ON silver.dim_affaire(etat);
CREATE INDEX idx_dim_affaire_client ON silver.dim_affaire(client_sk);

-- ============================================================================
-- Dimension Chantier
-- ============================================================================

CREATE TABLE silver.dim_chantier (
    chantier_sk SERIAL PRIMARY KEY,
    chantier_nk VARCHAR(40) NOT NULL,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    chef_chantier_sk INTEGER REFERENCES silver.dim_salarie(salarie_sk),
    code VARCHAR(20),
    libelle VARCHAR(200),
    etat VARCHAR(20),
    date_debut DATE,
    date_fin_prevue DATE,
    date_fin_reelle DATE,
    adresse TEXT,
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    departement VARCHAR(3),
    coordonnees_gps_lat NUMERIC(10,7),
    coordonnees_gps_lon NUMERIC(10,7),
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_chantier_nk ON silver.dim_chantier(chantier_nk, is_current);
CREATE INDEX idx_dim_chantier_affaire ON silver.dim_chantier(affaire_sk);

-- ============================================================================
-- Dimension Journal Comptable
-- ============================================================================

CREATE TABLE silver.dim_journal (
    journal_sk SERIAL PRIMARY KEY,
    journal_nk VARCHAR(20) NOT NULL,
    source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    source_id INTEGER,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    code VARCHAR(6),
    libelle VARCHAR(50),
    type_journal VARCHAR(20),
    type_journal_groupe VARCHAR(20), -- TRESORERIE, OPERATION, SITUATION
    compte_contrepartie VARCHAR(13),
    est_actif BOOLEAN,
    -- SCD Type 2
    is_current BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP DEFAULT '9999-12-31 23:59:59',
    row_hash VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- TABLES DE FAITS SILVER (donnees nettoyees, non agregees)
-- ============================================================================

-- Faits Ecritures Comptables
CREATE TABLE silver.fact_ecriture_compta (
    ecriture_sk BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(20) DEFAULT 'SAGE_COMPTA',
    source_id INTEGER,
    -- Cles de dimension
    date_sk INTEGER REFERENCES silver.dim_temps(date_key),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    journal_sk INTEGER REFERENCES silver.dim_journal(journal_sk),
    compte_sk INTEGER REFERENCES silver.dim_compte(compte_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    fournisseur_sk INTEGER REFERENCES silver.dim_fournisseur(fournisseur_sk),
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    -- Attributs degenerees
    numero_piece VARCHAR(20),
    numero_ligne INTEGER,
    libelle VARCHAR(200),
    reference VARCHAR(50),
    compte_numero VARCHAR(13),
    compte_tiers VARCHAR(17),
    -- Mesures
    montant_debit NUMERIC(15,2) DEFAULT 0,
    montant_credit NUMERIC(15,2) DEFAULT 0,
    montant_solde NUMERIC(15,2) GENERATED ALWAYS AS (montant_debit - montant_credit) STORED,
    -- Lettrage
    code_lettrage VARCHAR(10),
    date_lettrage DATE,
    est_lettre BOOLEAN DEFAULT FALSE,
    -- Echeance
    date_echeance DATE,
    -- Metadata
    etat_piece VARCHAR(20),
    origine VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_ecriture_date ON silver.fact_ecriture_compta(date_sk);
CREATE INDEX idx_fact_ecriture_compte ON silver.fact_ecriture_compta(compte_sk);
CREATE INDEX idx_fact_ecriture_societe ON silver.fact_ecriture_compta(societe_sk);
CREATE INDEX idx_fact_ecriture_piece ON silver.fact_ecriture_compta(numero_piece);

-- Faits Documents Commerciaux
CREATE TABLE silver.fact_document_commercial (
    document_sk BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    -- Cles de dimension
    date_sk INTEGER REFERENCES silver.dim_temps(date_key),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    fournisseur_sk INTEGER REFERENCES silver.dim_fournisseur(fournisseur_sk),
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    chantier_sk INTEGER REFERENCES silver.dim_chantier(chantier_sk),
    -- Attributs degenerees
    type_document VARCHAR(20),
    numero VARCHAR(20),
    objet VARCHAR(200),
    statut VARCHAR(20),
    -- Mesures
    montant_ht NUMERIC(15,2),
    montant_tva NUMERIC(15,2),
    montant_ttc NUMERIC(15,2),
    taux_tva_moyen NUMERIC(5,2),
    nb_lignes INTEGER,
    -- Dates
    date_validation DATE,
    -- Liens
    document_origine_sk BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_document_date ON silver.fact_document_commercial(date_sk);
CREATE INDEX idx_fact_document_type ON silver.fact_document_commercial(type_document);
CREATE INDEX idx_fact_document_client ON silver.fact_document_commercial(client_sk);
CREATE INDEX idx_fact_document_affaire ON silver.fact_document_commercial(affaire_sk);

-- Faits Lignes Documents
CREATE TABLE silver.fact_ligne_document (
    ligne_sk BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    -- Cles de dimension
    document_sk BIGINT REFERENCES silver.fact_document_commercial(document_sk),
    element_sk INTEGER REFERENCES silver.dim_element(element_sk),
    -- Attributs
    numero_ligne INTEGER,
    designation VARCHAR(200),
    unite VARCHAR(10),
    -- Mesures
    quantite NUMERIC(15,4),
    prix_unitaire NUMERIC(15,4),
    remise_pct NUMERIC(5,2),
    montant_ht NUMERIC(15,2),
    taux_tva NUMERIC(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_ligne_document ON silver.fact_ligne_document(document_sk);
CREATE INDEX idx_fact_ligne_element ON silver.fact_ligne_document(element_sk);

-- Faits Suivi Main d'Oeuvre
CREATE TABLE silver.fact_suivi_mo (
    suivi_sk BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    -- Cles de dimension
    date_sk INTEGER REFERENCES silver.dim_temps(date_key),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    salarie_sk INTEGER REFERENCES silver.dim_salarie(salarie_sk),
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    chantier_sk INTEGER REFERENCES silver.dim_chantier(chantier_sk),
    -- Attributs
    semaine_iso VARCHAR(10),
    -- Mesures heures
    heures_normales NUMERIC(6,2) DEFAULT 0,
    heures_supp_25 NUMERIC(6,2) DEFAULT 0,
    heures_supp_50 NUMERIC(6,2) DEFAULT 0,
    heures_nuit NUMERIC(6,2) DEFAULT 0,
    heures_dimanche NUMERIC(6,2) DEFAULT 0,
    heures_deplacement NUMERIC(6,2) DEFAULT 0,
    heures_total NUMERIC(8,2) GENERATED ALWAYS AS (
        heures_normales + heures_supp_25 + heures_supp_50 +
        heures_nuit + heures_dimanche + heures_deplacement
    ) STORED,
    -- Mesures couts
    cout_heures_normales NUMERIC(10,2),
    cout_heures_supp NUMERIC(10,2),
    cout_total NUMERIC(10,2),
    -- Indemnites
    indemnites_repas NUMERIC(8,2) DEFAULT 0,
    indemnites_trajet NUMERIC(8,2) DEFAULT 0,
    indemnites_total NUMERIC(8,2) GENERATED ALWAYS AS (indemnites_repas + indemnites_trajet) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_suivi_date ON silver.fact_suivi_mo(date_sk);
CREATE INDEX idx_fact_suivi_salarie ON silver.fact_suivi_mo(salarie_sk);
CREATE INDEX idx_fact_suivi_affaire ON silver.fact_suivi_mo(affaire_sk);

-- Faits Mouvements Stock
CREATE TABLE silver.fact_mouvement_stock (
    mouvement_sk BIGSERIAL PRIMARY KEY,
    source_system VARCHAR(20) DEFAULT 'MDE_ERP',
    source_id INTEGER,
    -- Cles de dimension
    date_sk INTEGER REFERENCES silver.dim_temps(date_key),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    element_sk INTEGER REFERENCES silver.dim_element(element_sk),
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    -- Attributs
    depot_code VARCHAR(20),
    type_mouvement VARCHAR(20),
    reference VARCHAR(50),
    -- Mesures
    quantite_entree NUMERIC(15,4) DEFAULT 0,
    quantite_sortie NUMERIC(15,4) DEFAULT 0,
    quantite_nette NUMERIC(15,4) GENERATED ALWAYS AS (quantite_entree - quantite_sortie) STORED,
    prix_unitaire NUMERIC(15,4),
    valeur_mouvement NUMERIC(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fact_mvt_date ON silver.fact_mouvement_stock(date_sk);
CREATE INDEX idx_fact_mvt_element ON silver.fact_mouvement_stock(element_sk);

-- ============================================================================
-- TABLE DE REFERENCE GEOGRAPHIQUE
-- ============================================================================

CREATE TABLE silver.ref_departement (
    code VARCHAR(3) PRIMARY KEY,
    nom VARCHAR(50),
    region VARCHAR(50),
    code_region VARCHAR(3)
);

INSERT INTO silver.ref_departement (code, nom, region, code_region) VALUES
('01', 'Ain', 'Auvergne-Rhone-Alpes', 'ARA'),
('02', 'Aisne', 'Hauts-de-France', 'HDF'),
('03', 'Allier', 'Auvergne-Rhone-Alpes', 'ARA'),
('04', 'Alpes-de-Haute-Provence', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('05', 'Hautes-Alpes', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('06', 'Alpes-Maritimes', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('07', 'Ardeche', 'Auvergne-Rhone-Alpes', 'ARA'),
('08', 'Ardennes', 'Grand Est', 'GES'),
('09', 'Ariege', 'Occitanie', 'OCC'),
('10', 'Aube', 'Grand Est', 'GES'),
('11', 'Aude', 'Occitanie', 'OCC'),
('12', 'Aveyron', 'Occitanie', 'OCC'),
('13', 'Bouches-du-Rhone', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('14', 'Calvados', 'Normandie', 'NOR'),
('15', 'Cantal', 'Auvergne-Rhone-Alpes', 'ARA'),
('16', 'Charente', 'Nouvelle-Aquitaine', 'NAQ'),
('17', 'Charente-Maritime', 'Nouvelle-Aquitaine', 'NAQ'),
('18', 'Cher', 'Centre-Val de Loire', 'CVL'),
('19', 'Correze', 'Nouvelle-Aquitaine', 'NAQ'),
('21', 'Cote-d''Or', 'Bourgogne-Franche-Comte', 'BFC'),
('22', 'Cotes-d''Armor', 'Bretagne', 'BRE'),
('23', 'Creuse', 'Nouvelle-Aquitaine', 'NAQ'),
('24', 'Dordogne', 'Nouvelle-Aquitaine', 'NAQ'),
('25', 'Doubs', 'Bourgogne-Franche-Comte', 'BFC'),
('26', 'Drome', 'Auvergne-Rhone-Alpes', 'ARA'),
('27', 'Eure', 'Normandie', 'NOR'),
('28', 'Eure-et-Loir', 'Centre-Val de Loire', 'CVL'),
('29', 'Finistere', 'Bretagne', 'BRE'),
('2A', 'Corse-du-Sud', 'Corse', 'COR'),
('2B', 'Haute-Corse', 'Corse', 'COR'),
('30', 'Gard', 'Occitanie', 'OCC'),
('31', 'Haute-Garonne', 'Occitanie', 'OCC'),
('32', 'Gers', 'Occitanie', 'OCC'),
('33', 'Gironde', 'Nouvelle-Aquitaine', 'NAQ'),
('34', 'Herault', 'Occitanie', 'OCC'),
('35', 'Ille-et-Vilaine', 'Bretagne', 'BRE'),
('36', 'Indre', 'Centre-Val de Loire', 'CVL'),
('37', 'Indre-et-Loire', 'Centre-Val de Loire', 'CVL'),
('38', 'Isere', 'Auvergne-Rhone-Alpes', 'ARA'),
('39', 'Jura', 'Bourgogne-Franche-Comte', 'BFC'),
('40', 'Landes', 'Nouvelle-Aquitaine', 'NAQ'),
('41', 'Loir-et-Cher', 'Centre-Val de Loire', 'CVL'),
('42', 'Loire', 'Auvergne-Rhone-Alpes', 'ARA'),
('43', 'Haute-Loire', 'Auvergne-Rhone-Alpes', 'ARA'),
('44', 'Loire-Atlantique', 'Pays de la Loire', 'PDL'),
('45', 'Loiret', 'Centre-Val de Loire', 'CVL'),
('46', 'Lot', 'Occitanie', 'OCC'),
('47', 'Lot-et-Garonne', 'Nouvelle-Aquitaine', 'NAQ'),
('48', 'Lozere', 'Occitanie', 'OCC'),
('49', 'Maine-et-Loire', 'Pays de la Loire', 'PDL'),
('50', 'Manche', 'Normandie', 'NOR'),
('51', 'Marne', 'Grand Est', 'GES'),
('52', 'Haute-Marne', 'Grand Est', 'GES'),
('53', 'Mayenne', 'Pays de la Loire', 'PDL'),
('54', 'Meurthe-et-Moselle', 'Grand Est', 'GES'),
('55', 'Meuse', 'Grand Est', 'GES'),
('56', 'Morbihan', 'Bretagne', 'BRE'),
('57', 'Moselle', 'Grand Est', 'GES'),
('58', 'Nievre', 'Bourgogne-Franche-Comte', 'BFC'),
('59', 'Nord', 'Hauts-de-France', 'HDF'),
('60', 'Oise', 'Hauts-de-France', 'HDF'),
('61', 'Orne', 'Normandie', 'NOR'),
('62', 'Pas-de-Calais', 'Hauts-de-France', 'HDF'),
('63', 'Puy-de-Dome', 'Auvergne-Rhone-Alpes', 'ARA'),
('64', 'Pyrenees-Atlantiques', 'Nouvelle-Aquitaine', 'NAQ'),
('65', 'Hautes-Pyrenees', 'Occitanie', 'OCC'),
('66', 'Pyrenees-Orientales', 'Occitanie', 'OCC'),
('67', 'Bas-Rhin', 'Grand Est', 'GES'),
('68', 'Haut-Rhin', 'Grand Est', 'GES'),
('69', 'Rhone', 'Auvergne-Rhone-Alpes', 'ARA'),
('70', 'Haute-Saone', 'Bourgogne-Franche-Comte', 'BFC'),
('71', 'Saone-et-Loire', 'Bourgogne-Franche-Comte', 'BFC'),
('72', 'Sarthe', 'Pays de la Loire', 'PDL'),
('73', 'Savoie', 'Auvergne-Rhone-Alpes', 'ARA'),
('74', 'Haute-Savoie', 'Auvergne-Rhone-Alpes', 'ARA'),
('75', 'Paris', 'Ile-de-France', 'IDF'),
('76', 'Seine-Maritime', 'Normandie', 'NOR'),
('77', 'Seine-et-Marne', 'Ile-de-France', 'IDF'),
('78', 'Yvelines', 'Ile-de-France', 'IDF'),
('79', 'Deux-Sevres', 'Nouvelle-Aquitaine', 'NAQ'),
('80', 'Somme', 'Hauts-de-France', 'HDF'),
('81', 'Tarn', 'Occitanie', 'OCC'),
('82', 'Tarn-et-Garonne', 'Occitanie', 'OCC'),
('83', 'Var', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('84', 'Vaucluse', 'Provence-Alpes-Cote d''Azur', 'PAC'),
('85', 'Vendee', 'Pays de la Loire', 'PDL'),
('86', 'Vienne', 'Nouvelle-Aquitaine', 'NAQ'),
('87', 'Haute-Vienne', 'Nouvelle-Aquitaine', 'NAQ'),
('88', 'Vosges', 'Grand Est', 'GES'),
('89', 'Yonne', 'Bourgogne-Franche-Comte', 'BFC'),
('90', 'Territoire de Belfort', 'Bourgogne-Franche-Comte', 'BFC'),
('91', 'Essonne', 'Ile-de-France', 'IDF'),
('92', 'Hauts-de-Seine', 'Ile-de-France', 'IDF'),
('93', 'Seine-Saint-Denis', 'Ile-de-France', 'IDF'),
('94', 'Val-de-Marne', 'Ile-de-France', 'IDF'),
('95', 'Val-d''Oise', 'Ile-de-France', 'IDF');

-- ============================================================================
-- FONCTION UTILITAIRE : Extraction departement depuis code postal
-- ============================================================================

CREATE OR REPLACE FUNCTION silver.get_departement_from_cp(p_code_postal VARCHAR(10))
RETURNS VARCHAR(3) AS $$
BEGIN
    IF p_code_postal IS NULL OR LENGTH(p_code_postal) < 2 THEN
        RETURN NULL;
    END IF;

    -- Cas speciaux Corse
    IF SUBSTRING(p_code_postal FROM 1 FOR 2) = '20' THEN
        IF p_code_postal::INTEGER < 20200 THEN
            RETURN '2A';
        ELSE
            RETURN '2B';
        END IF;
    END IF;

    -- Cas DOM-TOM
    IF SUBSTRING(p_code_postal FROM 1 FOR 2) IN ('97', '98') THEN
        RETURN SUBSTRING(p_code_postal FROM 1 FOR 3);
    END IF;

    RETURN SUBSTRING(p_code_postal FROM 1 FOR 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FONCTION UTILITAIRE : Calcul hash pour SCD
-- ============================================================================

CREATE OR REPLACE FUNCTION silver.compute_row_hash(p_values TEXT[])
RETURNS VARCHAR(64) AS $$
BEGIN
    RETURN MD5(ARRAY_TO_STRING(p_values, '|'));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================================================
-- FIN SILVER LAYER
-- ============================================================================

\echo 'Silver Layer cree avec succes'

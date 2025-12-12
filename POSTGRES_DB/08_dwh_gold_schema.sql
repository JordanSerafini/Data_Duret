-- ============================================================================
-- DATA WAREHOUSE - GOLD LAYER
-- Donnees metier agregees, KPIs, et modeles analytiques
-- ============================================================================

-- \c dwh_groupe_duret;

-- ============================================================================
-- GOLD : TABLES AGREGEES PAR DOMAINE METIER
-- ============================================================================

-- ============================================================================
-- 1. DOMAINE COMMERCIAL
-- ============================================================================

-- Agregation CA par periode
CREATE TABLE gold.agg_ca_periode (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    annee INTEGER NOT NULL,
    mois INTEGER,
    trimestre INTEGER,
    semaine_iso INTEGER,
    -- Niveau d'agregation
    niveau_agregation VARCHAR(20) NOT NULL, -- JOUR, SEMAINE, MOIS, TRIMESTRE, ANNEE
    date_debut DATE,
    date_fin DATE,
    -- Mesures CA
    ca_devis NUMERIC(15,2) DEFAULT 0,
    ca_commande NUMERIC(15,2) DEFAULT 0,
    ca_facture NUMERIC(15,2) DEFAULT 0,
    ca_avoir NUMERIC(15,2) DEFAULT 0,
    ca_net NUMERIC(15,2) GENERATED ALWAYS AS (ca_facture - ca_avoir) STORED,
    -- Comptages
    nb_devis INTEGER DEFAULT 0,
    nb_commandes INTEGER DEFAULT 0,
    nb_factures INTEGER DEFAULT 0,
    nb_avoirs INTEGER DEFAULT 0,
    nb_clients_actifs INTEGER DEFAULT 0,
    nb_affaires_actives INTEGER DEFAULT 0,
    -- Moyennes
    panier_moyen NUMERIC(15,2),
    taux_transformation NUMERIC(5,2), -- commandes/devis
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, niveau_agregation, annee, mois, trimestre, semaine_iso)
);

CREATE INDEX idx_agg_ca_societe ON gold.agg_ca_periode(societe_sk);
CREATE INDEX idx_agg_ca_periode ON gold.agg_ca_periode(annee, mois);

-- Agregation CA par client
CREATE TABLE gold.agg_ca_client (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    annee INTEGER NOT NULL,
    -- Mesures CA
    ca_cumule NUMERIC(15,2) DEFAULT 0,
    ca_n_moins_1 NUMERIC(15,2) DEFAULT 0,
    variation_ca_pct NUMERIC(6,2),
    -- Comptages
    nb_affaires INTEGER DEFAULT 0,
    nb_factures INTEGER DEFAULT 0,
    nb_avoirs INTEGER DEFAULT 0,
    -- Marges
    marge_brute NUMERIC(15,2) DEFAULT 0,
    taux_marge NUMERIC(5,2),
    -- Paiements
    encours_actuel NUMERIC(15,2) DEFAULT 0,
    retard_paiement_moyen_jours INTEGER,
    nb_impayes INTEGER DEFAULT 0,
    -- Scoring
    segment_ca VARCHAR(20), -- A, B, C, D
    score_fidelite INTEGER, -- 0-100
    potentiel_croissance VARCHAR(20), -- FORT, MOYEN, FAIBLE
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, client_sk, annee)
);

CREATE INDEX idx_agg_ca_client_client ON gold.agg_ca_client(client_sk);
CREATE INDEX idx_agg_ca_client_segment ON gold.agg_ca_client(segment_ca);

-- Agregation CA par affaire
CREATE TABLE gold.agg_ca_affaire (
    id SERIAL PRIMARY KEY,
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    -- Montants
    montant_devis NUMERIC(15,2) DEFAULT 0,
    montant_commande NUMERIC(15,2) DEFAULT 0,
    montant_facture NUMERIC(15,2) DEFAULT 0,
    montant_avoir NUMERIC(15,2) DEFAULT 0,
    montant_reste_a_facturer NUMERIC(15,2) GENERATED ALWAYS AS (montant_commande - montant_facture + montant_avoir) STORED,
    -- Couts
    cout_mo_prevu NUMERIC(15,2) DEFAULT 0,
    cout_mo_reel NUMERIC(15,2) DEFAULT 0,
    cout_achats_prevu NUMERIC(15,2) DEFAULT 0,
    cout_achats_reel NUMERIC(15,2) DEFAULT 0,
    cout_sous_traitance_prevu NUMERIC(15,2) DEFAULT 0,
    cout_sous_traitance_reel NUMERIC(15,2) DEFAULT 0,
    cout_total_prevu NUMERIC(15,2),
    cout_total_reel NUMERIC(15,2),
    -- Marges
    marge_prevue NUMERIC(15,2),
    marge_reelle NUMERIC(15,2),
    taux_marge_prevu NUMERIC(5,2),
    taux_marge_reel NUMERIC(5,2),
    ecart_marge NUMERIC(15,2) GENERATED ALWAYS AS (marge_reelle - marge_prevue) STORED,
    -- Heures
    heures_budget NUMERIC(10,2) DEFAULT 0,
    heures_realisees NUMERIC(10,2) DEFAULT 0,
    ecart_heures NUMERIC(10,2) GENERATED ALWAYS AS (heures_realisees - heures_budget) STORED,
    productivite_pct NUMERIC(10,2),
    -- Avancement
    avancement_facturation_pct NUMERIC(10,2),
    avancement_travaux_pct NUMERIC(10,2),
    -- Alertes
    est_en_depassement_budget BOOLEAN DEFAULT FALSE,
    est_en_retard BOOLEAN DEFAULT FALSE,
    niveau_risque VARCHAR(20), -- FAIBLE, MOYEN, ELEVE, CRITIQUE
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(affaire_sk)
);

CREATE INDEX idx_agg_ca_affaire_societe ON gold.agg_ca_affaire(societe_sk);
CREATE INDEX idx_agg_ca_affaire_client ON gold.agg_ca_affaire(client_sk);
CREATE INDEX idx_agg_ca_affaire_risque ON gold.agg_ca_affaire(niveau_risque);

-- ============================================================================
-- 2. DOMAINE COMPTABLE / FINANCIER
-- ============================================================================

-- Balance des comptes agregee
CREATE TABLE gold.agg_balance_compte (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    compte_sk INTEGER REFERENCES silver.dim_compte(compte_sk),
    annee INTEGER NOT NULL,
    mois INTEGER,
    -- Soldes
    solde_debit_ouverture NUMERIC(15,2) DEFAULT 0,
    solde_credit_ouverture NUMERIC(15,2) DEFAULT 0,
    mouvement_debit NUMERIC(15,2) DEFAULT 0,
    mouvement_credit NUMERIC(15,2) DEFAULT 0,
    solde_debit_cloture NUMERIC(15,2) DEFAULT 0,
    solde_credit_cloture NUMERIC(15,2) DEFAULT 0,
    solde_net NUMERIC(15,2) GENERATED ALWAYS AS (
        (solde_debit_ouverture + mouvement_debit) - (solde_credit_ouverture + mouvement_credit)
    ) STORED,
    -- Comptages
    nb_ecritures INTEGER DEFAULT 0,
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, compte_sk, annee, mois)
);

CREATE INDEX idx_agg_balance_compte ON gold.agg_balance_compte(compte_sk);
CREATE INDEX idx_agg_balance_periode ON gold.agg_balance_compte(annee, mois);

-- Tresorerie agregee
CREATE TABLE gold.agg_tresorerie (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    jour INTEGER,
    niveau_agregation VARCHAR(20) NOT NULL, -- JOUR, MOIS
    -- Soldes
    solde_banque NUMERIC(15,2) DEFAULT 0,
    solde_caisse NUMERIC(15,2) DEFAULT 0,
    solde_total NUMERIC(15,2) GENERATED ALWAYS AS (solde_banque + solde_caisse) STORED,
    -- Flux
    encaissements NUMERIC(15,2) DEFAULT 0,
    decaissements NUMERIC(15,2) DEFAULT 0,
    flux_net NUMERIC(15,2) GENERATED ALWAYS AS (encaissements - decaissements) STORED,
    -- Creances / Dettes
    creances_clients NUMERIC(15,2) DEFAULT 0,
    creances_echues NUMERIC(15,2) DEFAULT 0,
    dettes_fournisseurs NUMERIC(15,2) DEFAULT 0,
    dettes_echues NUMERIC(15,2) DEFAULT 0,
    -- BFR
    bfr_estime NUMERIC(15,2),
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, niveau_agregation, annee, mois, jour)
);

CREATE INDEX idx_agg_tresorerie_societe ON gold.agg_tresorerie(societe_sk);
CREATE INDEX idx_agg_tresorerie_periode ON gold.agg_tresorerie(annee, mois);

-- Balance agee clients
CREATE TABLE gold.agg_balance_agee_client (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    date_calcul DATE NOT NULL,
    -- Tranches d'age
    non_echu NUMERIC(15,2) DEFAULT 0,
    echu_0_30j NUMERIC(15,2) DEFAULT 0,
    echu_31_60j NUMERIC(15,2) DEFAULT 0,
    echu_61_90j NUMERIC(15,2) DEFAULT 0,
    echu_plus_90j NUMERIC(15,2) DEFAULT 0,
    total_creances NUMERIC(15,2) GENERATED ALWAYS AS (
        non_echu + echu_0_30j + echu_31_60j + echu_61_90j + echu_plus_90j
    ) STORED,
    total_echu NUMERIC(15,2) GENERATED ALWAYS AS (
        echu_0_30j + echu_31_60j + echu_61_90j + echu_plus_90j
    ) STORED,
    -- Indicateurs
    dso_jours INTEGER, -- Days Sales Outstanding
    taux_recouvrement NUMERIC(5,2),
    score_risque_credit INTEGER, -- 0-100
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, client_sk, date_calcul)
);

CREATE INDEX idx_agg_balance_agee_client ON gold.agg_balance_agee_client(client_sk);

-- ============================================================================
-- 3. DOMAINE RH / PRODUCTIVITE
-- ============================================================================

-- Agregation heures par salarie
CREATE TABLE gold.agg_heures_salarie (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    salarie_sk INTEGER REFERENCES silver.dim_salarie(salarie_sk),
    annee INTEGER NOT NULL,
    mois INTEGER,
    -- Heures
    heures_normales NUMERIC(10,2) DEFAULT 0,
    heures_supplementaires NUMERIC(10,2) DEFAULT 0,
    heures_total NUMERIC(10,2) DEFAULT 0,
    heures_theoriques NUMERIC(10,2) DEFAULT 0,
    taux_occupation NUMERIC(10,2),
    -- Affectation
    heures_productives NUMERIC(10,2) DEFAULT 0,
    heures_non_productives NUMERIC(10,2) DEFAULT 0,
    taux_productivite NUMERIC(10,2),
    nb_affaires_travaillees INTEGER DEFAULT 0,
    -- Couts
    cout_brut NUMERIC(12,2) DEFAULT 0,
    cout_charge NUMERIC(12,2) DEFAULT 0,
    indemnites NUMERIC(10,2) DEFAULT 0,
    cout_total NUMERIC(12,2) DEFAULT 0,
    cout_horaire_moyen NUMERIC(8,2),
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, salarie_sk, annee, mois)
);

CREATE INDEX idx_agg_heures_salarie ON gold.agg_heures_salarie(salarie_sk);
CREATE INDEX idx_agg_heures_periode ON gold.agg_heures_salarie(annee, mois);

-- Agregation heures par affaire
CREATE TABLE gold.agg_heures_affaire (
    id SERIAL PRIMARY KEY,
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    annee INTEGER,
    mois INTEGER,
    niveau_agregation VARCHAR(20) NOT NULL, -- MOIS, CUMUL
    -- Heures
    heures_budget NUMERIC(10,2) DEFAULT 0,
    heures_realisees NUMERIC(10,2) DEFAULT 0,
    ecart_heures NUMERIC(10,2) GENERATED ALWAYS AS (heures_realisees - heures_budget) STORED,
    ecart_heures_pct NUMERIC(6,2),
    -- Effectifs
    nb_salaries INTEGER DEFAULT 0,
    nb_jours_travailles INTEGER DEFAULT 0,
    -- Couts
    cout_mo_budget NUMERIC(12,2) DEFAULT 0,
    cout_mo_reel NUMERIC(12,2) DEFAULT 0,
    ecart_cout NUMERIC(12,2) GENERATED ALWAYS AS (cout_mo_reel - cout_mo_budget) STORED,
    -- Productivite
    ratio_heures_ca NUMERIC(8,4), -- heures par euro de CA
    productivite_theorique NUMERIC(12,2),
    productivite_reelle NUMERIC(12,2),
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(affaire_sk, niveau_agregation, annee, mois)
);

CREATE INDEX idx_agg_heures_affaire ON gold.agg_heures_affaire(affaire_sk);

-- ============================================================================
-- 4. DOMAINE STOCK
-- ============================================================================

-- Agregation stock par element
CREATE TABLE gold.agg_stock_element (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    element_sk INTEGER REFERENCES silver.dim_element(element_sk),
    depot_code VARCHAR(20),
    date_calcul DATE NOT NULL,
    -- Quantites
    stock_initial NUMERIC(15,4) DEFAULT 0,
    entrees NUMERIC(15,4) DEFAULT 0,
    sorties NUMERIC(15,4) DEFAULT 0,
    stock_final NUMERIC(15,4) GENERATED ALWAYS AS (stock_initial + entrees - sorties) STORED,
    -- Valorisation
    valeur_stock NUMERIC(15,2) DEFAULT 0,
    prix_moyen_pondere NUMERIC(15,4),
    -- Indicateurs
    rotation_stock NUMERIC(6,2), -- nb de fois par an
    couverture_jours INTEGER, -- nb jours de stock
    stock_minimum NUMERIC(15,4),
    est_sous_stock_mini BOOLEAN DEFAULT FALSE,
    est_surstock BOOLEAN DEFAULT FALSE,
    -- Consommation
    conso_moyenne_mensuelle NUMERIC(15,4),
    conso_dernier_mois NUMERIC(15,4),
    -- Metadata
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, element_sk, depot_code, date_calcul)
);

CREATE INDEX idx_agg_stock_element ON gold.agg_stock_element(element_sk);
CREATE INDEX idx_agg_stock_alerte ON gold.agg_stock_element(est_sous_stock_mini, est_surstock);

-- ============================================================================
-- 5. KPIs GLOBAUX
-- ============================================================================

-- Table des KPIs calcules
CREATE TABLE gold.kpi_global (
    id SERIAL PRIMARY KEY,
    societe_sk INTEGER REFERENCES silver.dim_societe(societe_sk),
    annee INTEGER NOT NULL,
    mois INTEGER NOT NULL,
    -- KPIs Commerciaux
    kpi_ca_mensuel NUMERIC(15,2),
    kpi_ca_cumul NUMERIC(15,2),
    kpi_ca_objectif NUMERIC(15,2),
    kpi_ca_realisation_pct NUMERIC(5,2),
    kpi_ca_variation_n1_pct NUMERIC(6,2),
    kpi_panier_moyen NUMERIC(15,2),
    kpi_nb_nouveaux_clients INTEGER,
    kpi_taux_transformation NUMERIC(5,2),
    -- KPIs Marge
    kpi_marge_brute NUMERIC(15,2),
    kpi_taux_marge NUMERIC(5,2),
    kpi_marge_objectif NUMERIC(15,2),
    -- KPIs Tresorerie
    kpi_tresorerie_nette NUMERIC(15,2),
    kpi_bfr NUMERIC(15,2),
    kpi_dso_jours INTEGER,
    kpi_dpo_jours INTEGER,
    -- KPIs RH
    kpi_effectif_moyen NUMERIC(6,1),
    kpi_heures_productives NUMERIC(10,2),
    kpi_taux_occupation NUMERIC(10,2),
    kpi_cout_mo_par_heure NUMERIC(8,2),
    kpi_ca_par_salarie NUMERIC(15,2),
    -- KPIs Affaires
    kpi_nb_affaires_en_cours INTEGER,
    kpi_nb_affaires_en_retard INTEGER,
    kpi_nb_affaires_en_depassement INTEGER,
    kpi_carnet_commandes NUMERIC(15,2),
    kpi_reste_a_facturer NUMERIC(15,2),
    -- Metadata
    calcul_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_sk, annee, mois)
);

CREATE INDEX idx_kpi_global_societe ON gold.kpi_global(societe_sk);
CREATE INDEX idx_kpi_global_periode ON gold.kpi_global(annee, mois);

-- ============================================================================
-- 6. TABLES POUR ML / ANALYTICS
-- ============================================================================

-- Features clients pour scoring/prediction
CREATE TABLE gold.ml_features_client (
    id SERIAL PRIMARY KEY,
    client_sk INTEGER REFERENCES silver.dim_client(client_sk),
    date_extraction DATE NOT NULL,
    -- Features CA
    ca_12m NUMERIC(15,2),
    ca_6m NUMERIC(15,2),
    ca_3m NUMERIC(15,2),
    ca_1m NUMERIC(15,2),
    tendance_ca VARCHAR(20), -- HAUSSE, STABLE, BAISSE
    volatilite_ca NUMERIC(8,4),
    -- Features Comportement
    nb_commandes_12m INTEGER,
    frequence_commande_jours NUMERIC(6,1),
    recence_derniere_commande_jours INTEGER,
    panier_moyen NUMERIC(15,2),
    panier_max NUMERIC(15,2),
    panier_min NUMERIC(15,2),
    -- Features Paiement
    delai_paiement_moyen_jours INTEGER,
    nb_retards_paiement_12m INTEGER,
    taux_impayes NUMERIC(5,2),
    -- Features Fidelite
    anciennete_mois INTEGER,
    nb_affaires_total INTEGER,
    type_affaires_principal VARCHAR(30),
    -- Scores
    score_rfm INTEGER, -- Recence/Frequence/Montant 0-100
    score_risque INTEGER, -- 0-100
    score_potentiel INTEGER, -- 0-100
    -- Classification
    segment_valeur VARCHAR(20), -- VIP, PREMIUM, STANDARD, PETIT
    segment_comportement VARCHAR(20), -- FIDELE, REGULIER, OCCASIONNEL, DORMANT
    segment_risque VARCHAR(20), -- FAIBLE, MOYEN, ELEVE
    probabilite_churn NUMERIC(5,4),
    -- Metadata
    UNIQUE(client_sk, date_extraction)
);

CREATE INDEX idx_ml_features_client ON gold.ml_features_client(client_sk);
CREATE INDEX idx_ml_features_segment ON gold.ml_features_client(segment_valeur, segment_comportement);

-- Features affaires pour prediction marge
CREATE TABLE gold.ml_features_affaire (
    id SERIAL PRIMARY KEY,
    affaire_sk INTEGER REFERENCES silver.dim_affaire(affaire_sk),
    date_extraction DATE NOT NULL,
    -- Features Affaire
    type_affaire VARCHAR(30),
    montant_commande NUMERIC(15,2),
    montant_log NUMERIC(10,4), -- log du montant pour normalisation
    duree_prevue_jours INTEGER,
    nb_lots INTEGER,
    -- Features Client
    client_anciennete_mois INTEGER,
    client_ca_historique NUMERIC(15,2),
    client_nb_affaires_historique INTEGER,
    client_marge_moyenne_historique NUMERIC(5,2),
    -- Features Localisation
    distance_siege_km NUMERIC(8,2),
    departement VARCHAR(3),
    zone_geographique VARCHAR(20),
    -- Features Temporelles
    mois_demarrage INTEGER,
    trimestre_demarrage INTEGER,
    -- Features Ressources
    nb_salaries_affectes INTEGER,
    heures_budget NUMERIC(10,2),
    ratio_mo_montant NUMERIC(8,4),
    -- Target Variables
    marge_reelle_pct NUMERIC(5,2),
    ecart_budget_heures_pct NUMERIC(6,2),
    retard_jours INTEGER,
    -- Predictions
    marge_predite_pct NUMERIC(5,2),
    risque_depassement_score INTEGER,
    -- Metadata
    UNIQUE(affaire_sk, date_extraction)
);

CREATE INDEX idx_ml_features_affaire ON gold.ml_features_affaire(affaire_sk);

-- ============================================================================
-- 7. VUES GOLD POUR REPORTING
-- ============================================================================

-- Vue tableau de bord direction
CREATE OR REPLACE VIEW gold.v_dashboard_direction AS
SELECT
    s.raison_sociale AS societe,
    k.annee,
    k.mois,
    -- CA
    k.kpi_ca_mensuel,
    k.kpi_ca_cumul,
    k.kpi_ca_realisation_pct,
    k.kpi_ca_variation_n1_pct,
    -- Marge
    k.kpi_marge_brute,
    k.kpi_taux_marge,
    -- Tresorerie
    k.kpi_tresorerie_nette,
    k.kpi_dso_jours,
    -- Carnet
    k.kpi_carnet_commandes,
    k.kpi_reste_a_facturer,
    -- Alertes
    k.kpi_nb_affaires_en_retard,
    k.kpi_nb_affaires_en_depassement
FROM gold.kpi_global k
JOIN silver.dim_societe s ON k.societe_sk = s.societe_sk AND s.is_current = TRUE
ORDER BY k.annee DESC, k.mois DESC, s.raison_sociale;

-- Vue analyse client
CREATE OR REPLACE VIEW gold.v_analyse_client AS
SELECT
    c.raison_sociale AS client,
    c.ville,
    c.segment_client,
    ac.annee,
    ac.ca_cumule,
    ac.ca_n_moins_1,
    ac.variation_ca_pct,
    ac.taux_marge,
    ac.encours_actuel,
    ac.retard_paiement_moyen_jours,
    ac.segment_ca,
    ac.score_fidelite,
    ac.potentiel_croissance
FROM gold.agg_ca_client ac
JOIN silver.dim_client c ON ac.client_sk = c.client_sk AND c.is_current = TRUE
ORDER BY ac.ca_cumule DESC;

-- Vue suivi affaires
CREATE OR REPLACE VIEW gold.v_suivi_affaires AS
SELECT
    a.code AS affaire,
    a.libelle,
    c.raison_sociale AS client,
    a.etat,
    a.date_debut_reelle,
    a.date_fin_prevue,
    aa.montant_commande,
    aa.montant_facture,
    aa.montant_reste_a_facturer,
    aa.taux_marge_prevu,
    aa.taux_marge_reel,
    aa.ecart_marge,
    aa.heures_budget,
    aa.heures_realisees,
    aa.ecart_heures,
    aa.avancement_facturation_pct,
    aa.avancement_travaux_pct,
    aa.niveau_risque,
    aa.est_en_retard,
    aa.est_en_depassement_budget
FROM gold.agg_ca_affaire aa
JOIN silver.dim_affaire a ON aa.affaire_sk = a.affaire_sk AND a.is_current = TRUE
LEFT JOIN silver.dim_client c ON aa.client_sk = c.client_sk AND c.is_current = TRUE
ORDER BY aa.niveau_risque DESC, aa.montant_commande DESC;

-- Vue productivite equipes
CREATE OR REPLACE VIEW gold.v_productivite_equipes AS
SELECT
    sal.nom_complet AS salarie,
    sal.poste,
    sal.qualification,
    h.annee,
    h.mois,
    h.heures_total,
    h.heures_theoriques,
    h.taux_occupation,
    h.heures_productives,
    h.taux_productivite,
    h.nb_affaires_travaillees,
    h.cout_horaire_moyen
FROM gold.agg_heures_salarie h
JOIN silver.dim_salarie sal ON h.salarie_sk = sal.salarie_sk AND sal.is_current = TRUE
ORDER BY h.annee DESC, h.mois DESC, h.taux_productivite DESC;

-- Vue alertes stock
CREATE OR REPLACE VIEW gold.v_alertes_stock AS
SELECT
    e.code AS element,
    e.designation,
    e.famille,
    s.depot_code,
    s.stock_final,
    s.stock_minimum,
    s.valeur_stock,
    s.rotation_stock,
    s.couverture_jours,
    CASE
        WHEN s.est_sous_stock_mini THEN 'RUPTURE IMMINENTE'
        WHEN s.est_surstock THEN 'SURSTOCK'
        ELSE 'OK'
    END AS alerte
FROM gold.agg_stock_element s
JOIN silver.dim_element e ON s.element_sk = e.element_sk AND e.is_current = TRUE
WHERE s.est_sous_stock_mini OR s.est_surstock
ORDER BY
    CASE WHEN s.est_sous_stock_mini THEN 1 ELSE 2 END,
    s.valeur_stock DESC;

-- Vue balance agee consolidee
CREATE OR REPLACE VIEW gold.v_balance_agee_consolidee AS
SELECT
    c.raison_sociale AS client,
    c.ville,
    ba.non_echu,
    ba.echu_0_30j,
    ba.echu_31_60j,
    ba.echu_61_90j,
    ba.echu_plus_90j,
    ba.total_creances,
    ba.total_echu,
    ba.dso_jours,
    ba.score_risque_credit,
    CASE
        WHEN ba.score_risque_credit >= 80 THEN 'CRITIQUE'
        WHEN ba.score_risque_credit >= 60 THEN 'ELEVE'
        WHEN ba.score_risque_credit >= 40 THEN 'MOYEN'
        ELSE 'FAIBLE'
    END AS niveau_risque
FROM gold.agg_balance_agee_client ba
JOIN silver.dim_client c ON ba.client_sk = c.client_sk AND c.is_current = TRUE
WHERE ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)
ORDER BY ba.total_echu DESC;

-- ============================================================================
-- 8. TABLES SNAPSHOT POUR HISTORIQUE
-- ============================================================================

-- Snapshot mensuel KPIs
CREATE TABLE gold.snapshot_kpi_mensuel (
    id SERIAL PRIMARY KEY,
    snapshot_date DATE NOT NULL,
    societe_sk INTEGER,
    donnees JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_snapshot_kpi_date ON gold.snapshot_kpi_mensuel(snapshot_date);

-- ============================================================================
-- FIN GOLD LAYER
-- ============================================================================

\echo 'Gold Layer cree avec succes'

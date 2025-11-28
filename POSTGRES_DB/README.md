# Bases de Données PostgreSQL - Groupe DURET

## Vue d'ensemble

Ce projet contient les scripts de création et de seeding de deux bases de données PostgreSQL issues de la migration des systèmes MSSQL existants :

1. **SAGE Comptabilité** (`sage_compta`) - Gestion comptable et financière
2. **MDE ERP** (`mde_erp`) - Gestion des affaires et chantiers BTP

## Architecture

```
POSTGRES_DB/
├── 01_sage_compta_schema.sql      # Structure BDD SAGE
├── 02_sage_compta_seed.sql        # Donnees SAGE
├── 03_mde_erp_schema.sql          # Structure BDD MDE
├── 04_mde_erp_seed.sql            # Donnees MDE
├── 05_coherence_et_liens.sql      # Scripts inter-bases
├── 06_dwh_bronze_schema.sql       # DWH Bronze Layer
├── 07_dwh_silver_schema.sql       # DWH Silver Layer
├── 08_dwh_gold_schema.sql         # DWH Gold Layer + KPIs
├── 09_dwh_etl_bronze_silver.sql   # ETL Bronze -> Silver
├── 10_dwh_etl_silver_gold.sql     # ETL Silver -> Gold
├── 11_dwh_seed_initial.sql        # Seed initial DWH
└── README.md                      # Documentation
```

## Installation

### Prérequis

- PostgreSQL 14+ installé
- Utilisateur avec droits CREATE DATABASE
- ~500 Mo d'espace disque

### Exécution des scripts

```bash
# 1. Créer et peupler SAGE Comptabilité
psql -U postgres -f 01_sage_compta_schema.sql
psql -U postgres -d sage_compta -f 02_sage_compta_seed.sql

# 2. Créer et peupler MDE ERP
psql -U postgres -f 03_mde_erp_schema.sql
psql -U postgres -d mde_erp -f 04_mde_erp_seed.sql

# 3. Installer les scripts de cohérence
psql -U postgres -f 05_coherence_et_liens.sql
```

### Script d'installation complet

```bash
#!/bin/bash
PGUSER="postgres"
SCRIPTS_DIR="/home/tinkerbell/Desktop/1/POSTGRES_DB"

for script in 01_sage_compta_schema.sql 02_sage_compta_seed.sql \
              03_mde_erp_schema.sql 04_mde_erp_seed.sql \
              05_coherence_et_liens.sql; do
    echo "Exécution de $script..."
    psql -U $PGUSER -f "$SCRIPTS_DIR/$script"
done
echo "Installation terminée."
```

---

## Base de données SAGE Comptabilité

### Schémas

| Schéma | Description |
|--------|-------------|
| `ref` | Référentiels (sociétés, devises, exercices, périodes) |
| `compta` | Comptabilité générale (comptes, journaux, pièces, écritures) |
| `tiers` | Tiers comptables (clients, fournisseurs) |
| `tresor` | Trésorerie (banques, échéances, règlements) |
| `audit` | Audit et traçabilité |

### Tables principales

#### Schéma `ref`
- `societe` - Sociétés du groupe (4 entités)
- `devise` - Devises (EUR, USD, GBP, CHF)
- `exercice` - Exercices comptables
- `periode` - Périodes mensuelles

#### Schéma `compta`
- `compte_general` - Plan comptable général (PCG)
- `journal` - Journaux comptables (ACH, VTE, BQ, OD, AN)
- `piece` - En-têtes de pièces comptables
- `ecriture` - Lignes d'écritures
- `analytique_section` - Sections analytiques

#### Schéma `tiers`
- `client` - Clients (~150)
- `fournisseur` - Fournisseurs (~80)

#### Schéma `tresor`
- `banque` - Comptes bancaires
- `echeance` - Échéances à payer/recevoir
- `reglement` - Règlements effectués
- `prevision_tresorerie` - Prévisions

### Statistiques du seed

| Élément | Quantité |
|---------|----------|
| Sociétés | 4 |
| Comptes généraux | ~300 par société |
| Clients | 150 |
| Fournisseurs | 80 |
| Écritures | ~500 pièces, ~2000 lignes |
| Exercices | 2 par société (2023, 2024) |

### Vues disponibles

- `compta.v_balance_generale` - Balance des comptes
- `compta.v_grand_livre` - Grand livre détaillé
- `compta.v_balance_agee_clients` - Balance âgée clients
- `compta.v_solde_journaux` - Équilibre des journaux

---

## Base de données MDE ERP

### Schémas

| Schéma | Description |
|--------|-------------|
| `ref` | Référentiels (sociétés, paramètres, éléments) |
| `tiers` | Tiers opérationnels (clients, fournisseurs, sous-traitants, salariés) |
| `affaire` | Gestion des affaires/projets |
| `chantier` | Gestion des chantiers |
| `document` | Documents commerciaux |
| `stock` | Gestion des stocks |
| `planning` | Planification et suivi |
| `compta` | Interface comptable |

### Tables principales

#### Schéma `ref`
- `societe` - Sociétés (4 entités)
- `element` - Catalogue articles/ouvrages (800+)
- `unite` - Unités de mesure
- `tva` - Taux de TVA

#### Schéma `tiers`
- `client` - Clients (150+)
- `fournisseur` - Fournisseurs (80+)
- `sous_traitant` - Sous-traitants (30)
- `salarie` - Salariés (100)

#### Schéma `affaire`
- `affaire` - Affaires/Projets (50)
- `lot` - Lots par affaire
- `budget_affaire` - Budgets prévisionnels

#### Schéma `chantier`
- `chantier` - Chantiers physiques
- `phase_chantier` - Phases de réalisation

#### Schéma `document`
- `entete_document` - En-têtes (devis, factures...)
- `ligne_document` - Lignes détaillées
- `situation` - Situations de travaux

#### Schéma `stock`
- `depot` - Dépôts de stockage
- `mouvement` - Mouvements de stock

#### Schéma `planning`
- `suivi_mo` - Suivi main d'œuvre (6 mois)
- `pointage_journalier` - Pointages quotidiens

### Types énumérés

```sql
etat_affaire: PROSPECT, DEVIS, COMMANDE, EN_COURS, TERMINE, ARCHIVE, ANNULE
etat_chantier: PREPARATION, EN_COURS, SUSPENDU, TERMINE, CLOTURE
type_document: DEVIS, COMMANDE, BON_LIVRAISON, FACTURE, AVOIR, SITUATION
type_element: FOURNITURE, MAIN_OEUVRE, MATERIEL, OUVRAGE, FRAIS
type_mouvement: ENTREE, SORTIE, TRANSFERT, INVENTAIRE
```

### Statistiques du seed

| Élément | Quantité |
|---------|----------|
| Sociétés | 4 |
| Clients | 150+ |
| Fournisseurs | 80+ |
| Sous-traitants | 30 |
| Salariés | 100 |
| Éléments catalogue | 800+ |
| Affaires | 50 |
| Chantiers | ~75 |
| Documents | ~200 |
| Lignes documents | ~1500 |
| Suivi MO | 6 mois de données |

### Vues disponibles

- `affaire.v_synthese_affaire` - Synthèse par affaire
- `affaire.v_marge_affaire` - Analyse des marges
- `chantier.v_avancement_chantier` - Avancement chantiers
- `document.v_ca_mensuel` - CA mensuel
- `planning.v_heures_par_affaire` - Heures par affaire

---

## Scripts de Cohérence Inter-Bases

### Tables de mapping

- `ref.mapping_tiers_mde` - Correspondance tiers MDE ↔ comptes SAGE
- `ref.mapping_affaire_analytique` - Correspondance affaires ↔ analytique

### Journal de transfert

- `compta.journal_transfert_mde` - Traçabilité des transferts comptables

### Fonctions

```sql
-- Générer des écritures comptables depuis une facture MDE
SELECT compta.generer_ecritures_facture_mde(
    p_societe_id := 1,
    p_type_document := 'FACTURE',
    p_numero_document := 'FC2024-0001',
    p_date_document := '2024-01-15',
    p_code_tiers := 'C0001',
    p_type_tiers := 'CLIENT',
    p_montant_ht := 15000.00,
    p_montant_tva := 3000.00,
    p_code_affaire := 'AFF2024-001'
);
```

### Procédures de contrôle

```sql
-- Vérifier la cohérence MDE ↔ Comptabilité
CALL compta.verifier_coherence_mde();
```

### Vues de réconciliation

- `compta.v_ecarts_ca_mde_compta` - Écarts CA entre MDE et comptabilité
- `compta.v_ca_consolide` - CA consolidé toutes sources

---

## Data Warehouse - Architecture Bronze/Silver/Gold

Le Data Warehouse (`dwh_groupe_duret`) agrege les donnees SAGE et MDE dans une architecture moderne en 3 couches.

### Installation du DWH

```bash
# Apres avoir installe SAGE et MDE, executer :
psql -U postgres -f 06_dwh_bronze_schema.sql
psql -U postgres -d dwh_groupe_duret -f 07_dwh_silver_schema.sql
psql -U postgres -d dwh_groupe_duret -f 08_dwh_gold_schema.sql
psql -U postgres -d dwh_groupe_duret -f 09_dwh_etl_bronze_silver.sql
psql -U postgres -d dwh_groupe_duret -f 10_dwh_etl_silver_gold.sql
psql -U postgres -d dwh_groupe_duret -f 11_dwh_seed_initial.sql
```

### Bronze Layer (Donnees brutes)

Extraction des donnees sources avec metadonnees d'ingestion.

| Schema | Tables | Description |
|--------|--------|-------------|
| `bronze` | sage_* | Miroir des tables SAGE |
| `bronze` | mde_* | Miroir des tables MDE |
| `etl` | job_execution | Suivi des jobs ETL |
| `audit` | data_lineage | Tracabilite des donnees |

**Metadonnees ajoutees :**
- `_bronze_id` : ID unique DWH
- `_source_system` : Systeme source
- `_ingestion_time` : Horodatage extraction
- `_batch_id` : ID du batch

### Silver Layer (Donnees nettoyees)

Dimensions conformees avec historisation SCD Type 2.

| Type | Tables | Description |
|------|--------|-------------|
| Dimension | `dim_temps` | Calendrier 2020-2030 avec jours feries |
| Dimension | `dim_societe` | Societes unifiees |
| Dimension | `dim_client` | Clients fusionnes SAGE+MDE |
| Dimension | `dim_fournisseur` | Fournisseurs fusionnes |
| Dimension | `dim_salarie` | Employes avec hierarchie |
| Dimension | `dim_element` | Catalogue articles |
| Dimension | `dim_compte` | Plan comptable |
| Dimension | `dim_affaire` | Affaires/Projets |
| Dimension | `dim_chantier` | Chantiers |
| Dimension | `dim_journal` | Journaux comptables |
| Fait | `fact_ecriture_compta` | Ecritures comptables |
| Fait | `fact_document_commercial` | Documents (devis, factures) |
| Fait | `fact_ligne_document` | Lignes de documents |
| Fait | `fact_suivi_mo` | Heures main d'oeuvre |
| Fait | `fact_mouvement_stock` | Mouvements de stock |

**Fonctionnalites :**
- Surrogate keys (`*_sk`)
- SCD Type 2 (`is_current`, `valid_from`, `valid_to`)
- Hash de detection de changements
- Reference geographique (departements/regions)

### Gold Layer (Donnees metier)

Agregations precalculees et KPIs.

| Table | Description |
|-------|-------------|
| `agg_ca_periode` | CA par mois/trimestre/annee |
| `agg_ca_client` | CA et marge par client |
| `agg_ca_affaire` | Rentabilite par affaire |
| `agg_balance_compte` | Balance comptable agregee |
| `agg_tresorerie` | Tresorerie et BFR |
| `agg_balance_agee_client` | Balance agee par client |
| `agg_heures_salarie` | Productivite par salarie |
| `agg_heures_affaire` | Heures par affaire |
| `agg_stock_element` | Stock et rotation |
| `kpi_global` | KPIs consolides |
| `ml_features_client` | Features pour ML clients |
| `ml_features_affaire` | Features pour ML affaires |

### KPIs disponibles

| Domaine | KPIs |
|---------|------|
| Commercial | CA mensuel/cumule, Taux transformation, Panier moyen |
| Marge | Marge brute, Taux marge par affaire |
| Tresorerie | Solde, BFR, DSO (delai paiement) |
| RH | Effectif, Heures productives, Taux occupation, CA/salarie |
| Affaires | Carnet commandes, Reste a facturer, Affaires en retard |
| Stock | Rotation, Couverture jours, Alertes rupture/surstock |

### Vues Gold pour Reporting

```sql
-- Tableau de bord direction
SELECT * FROM gold.v_dashboard_direction;

-- Analyse clients
SELECT * FROM gold.v_analyse_client;

-- Suivi affaires avec alertes
SELECT * FROM gold.v_suivi_affaires;

-- Productivite equipes
SELECT * FROM gold.v_productivite_equipes;

-- Alertes stock
SELECT * FROM gold.v_alertes_stock;

-- Balance agee consolidee
SELECT * FROM gold.v_balance_agee_consolidee;
```

### Execution ETL

```sql
-- ETL complet (Bronze -> Silver -> Gold)
CALL etl.run_full_etl();

-- Ou par etape
CALL etl.run_bronze_to_silver();
CALL etl.run_silver_to_gold();

-- ETL individuel par entite
CALL etl.load_dim_client();
CALL etl.load_fact_document_commercial();
CALL etl.load_agg_ca_affaire();
CALL etl.load_kpi_global();
```

### Machine Learning - Features pre-calculees

**Features Client (`gold.ml_features_client`):**
- CA sur 1/3/6/12 mois
- Tendance CA, Volatilite
- Frequence et recence commandes
- Score RFM (Recence/Frequence/Montant)
- Segmentation (VIP, Premium, Standard, Petit)
- Probabilite de churn

**Features Affaire (`gold.ml_features_affaire`):**
- Caracteristiques affaire (type, montant, duree)
- Historique client
- Localisation et distance
- Ressources allouees
- Target: marge reelle, ecart budget, retard

### Cas d'usage ML

```python
# Exemple: Prediction marge affaire
import pandas as pd
from sklearn.ensemble import RandomForestRegressor

# Extraction features
df = pd.read_sql("""
    SELECT * FROM gold.ml_features_affaire
    WHERE marge_reelle_pct IS NOT NULL
""", conn)

# Entrainement
X = df[['montant_log', 'duree_prevue_jours', 'client_marge_moyenne_historique',
        'ratio_mo_montant', 'distance_siege_km']]
y = df['marge_reelle_pct']

model = RandomForestRegressor()
model.fit(X, y)
```

---

## Connexion aux bases

```python
# Python avec psycopg2
import psycopg2

# SAGE Comptabilite
conn_sage = psycopg2.connect(
    host="localhost",
    database="sage_compta",
    user="postgres",
    password="votre_mot_de_passe"
)

# MDE ERP
conn_mde = psycopg2.connect(
    host="localhost",
    database="mde_erp",
    user="postgres",
    password="votre_mot_de_passe"
)

# Data Warehouse
conn_dwh = psycopg2.connect(
    host="localhost",
    database="dwh_groupe_duret",
    user="postgres",
    password="votre_mot_de_passe"
)
```

```javascript
// Node.js avec pg
const { Pool } = require('pg');

const sagePool = new Pool({
    host: 'localhost',
    database: 'sage_compta',
    user: 'postgres',
    password: 'votre_mot_de_passe'
});

const mdePool = new Pool({
    host: 'localhost',
    database: 'mde_erp',
    user: 'postgres',
    password: 'votre_mot_de_passe'
});

const dwhPool = new Pool({
    host: 'localhost',
    database: 'dwh_groupe_duret',
    user: 'postgres',
    password: 'votre_mot_de_passe'
});
```

---

## Support

Pour toute question sur la structure des données ou l'utilisation des scripts, référez-vous aux fichiers d'audit dans `/AUDIT_SYNTHESES/`.

---

*Généré le 2024 - Migration MSSQL → PostgreSQL*

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Data warehouse project for **Groupe DURET** (French BTP/construction company). Migrates data from MSSQL source systems (Sage 100 Comptabilité + MDE ERP) to PostgreSQL with a Bronze/Silver/Gold architecture.

## Source Systems (MSSQL on SRV-SAGE\SAGE100)

- **Sage 100 Comptabilité** (4 databases): DURETELEC, DURET_ENE, DURET_RES, DURET_SER - Accounting, treasury, SEPA mandates
- **MDE System** (3 databases): MDE_COMM, MDE_MDE, MDE_SYS - Shared configuration
- **MDE Dossiers** (9 databases): MDE_DOS_DURET, MDE_DOS_DURET_ELE, etc. - Business data (affaires, chantiers, devis, factures)

## PostgreSQL Databases

Three target databases:
- `sage_compta` - Accounting (schemas: ref, compta, tiers, tresor, audit)
- `mde_erp` - ERP operations (schemas: ref, tiers, affaire, chantier, document, stock, planning, compta)
- `dwh_groupe_duret` - Data warehouse (schemas: bronze, silver, gold, etl, audit)

## Commands

### PostgreSQL Setup (in order)
```bash
# Create and seed SAGE Comptabilité
psql -U postgres -f POSTGRES_DB/01_sage_compta_schema.sql
psql -U postgres -d sage_compta -f POSTGRES_DB/02_sage_compta_seed.sql

# Create and seed MDE ERP
psql -U postgres -f POSTGRES_DB/03_mde_erp_schema.sql
psql -U postgres -d mde_erp -f POSTGRES_DB/04_mde_erp_seed.sql

# Install coherence scripts
psql -U postgres -f POSTGRES_DB/05_coherence_et_liens.sql

# Create DWH layers
psql -U postgres -f POSTGRES_DB/06_dwh_bronze_schema.sql
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/07_dwh_silver_schema.sql
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/08_dwh_gold_schema.sql
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/09_dwh_etl_bronze_silver.sql
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/10_dwh_etl_silver_gold.sql
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/11_dwh_seed_initial.sql
```

### Node.js Schema Extraction (requires mssql/msnodesqlv8)
```bash
node client.js         # Extract single database schema
node v2.js             # Extract all databases schemas
node scan_targets.js   # Scan for F_DOCENTETE tables
```

### ETL Execution (PostgreSQL)
```sql
CALL etl.run_full_etl();           -- Full ETL (inclut qualité + refresh vues)
CALL etl.run_bronze_to_silver();   -- Bronze → Silver only
CALL etl.run_silver_to_gold();     -- Silver → Gold only
CALL etl.refresh_materialized_views(); -- Refresh vues matérialisées
CALL audit.run_data_quality_checks();  -- Contrôles qualité données
```

### Optimisations DWH (script 12)

```bash
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/12_dwh_optimizations.sql
```

### Correction des incohérences de seed (script 13)

Si les données ont déjà été chargées et présentent des incohérences (productivité 100%, budgets incorrects), exécuter :

```bash
psql -U postgres -d dwh_groupe_duret -f POSTGRES_DB/13_fix_seed_coherence.sql
```

Ce script corrige :
- Productivité à 100% → ajoute ~20% d'heures non-productives (formation, réunions, etc.)
- Doublons dans les dimensions Silver
- Budget heures incohérent avec heures réalisées
- Montants documents ≠ somme des lignes
- Absence de règlements clients/fournisseurs
- Inventaire stock initial manquant

## Architecture

### DWH Layers
- **Bronze** (`bronze.*`): Raw mirrors of source tables with ingestion metadata (`_bronze_id`, `_source_system`, `_ingestion_time`, `_batch_id`)
- **Silver** (`silver.*`): Conformed dimensions with SCD Type 2 (`dim_*` tables) and fact tables (`fact_*`)
- **Gold** (`gold.*`): Pre-aggregated tables (`agg_*`), KPIs (`kpi_global`), ML features (`ml_features_*`)

### Key Tables
| Layer | Type | Examples |
|-------|------|----------|
| Silver | Dimensions | dim_temps, dim_societe, dim_client, dim_affaire, dim_compte |
| Silver | Facts | fact_ecriture_compta, fact_document_commercial, fact_suivi_mo |
| Silver | Partitioned | fact_ecriture_compta_partitioned, fact_document_commercial_partitioned |
| Gold | Aggregates | agg_ca_periode, agg_ca_client, agg_ca_affaire, agg_tresorerie |
| Gold | Materialized Views | mv_ca_societe_mensuel, mv_balance_client, mv_rentabilite_affaire |
| Gold | ML Features | ml_features_client, ml_features_affaire |
| Audit | Quality | data_quality_rules, data_quality_check, data_anomaly |

### Inter-System Mapping
- `ref.mapping_tiers_mde`: Links MDE clients/fournisseurs to Sage compte tiers
- `ref.mapping_affaire_analytique`: Links MDE affaires to Sage analytical sections
- `compta.journal_transfert_mde`: Transfer audit trail

## Key Domain Terms (French)
- **Affaire**: Project/deal
- **Chantier**: Construction site
- **Devis**: Quote
- **Facture**: Invoice
- **Tiers**: Third party (client/fournisseur)
- **Écritures**: Accounting entries
- **Règlement**: Payment

## Directory Structure
- `POSTGRES_DB/`: SQL scripts (01-11 numbered for execution order)
- `EXPORT_SCHEMA/`, `EXPORT_SCHEMA_FULL/`: Extracted MSSQL schemas (JSON + MD)
- `EXPORT_ADVANCED/`: Foreign key relationship analysis
- `AUDIT_SYNTHESES/`: Database audit documentation

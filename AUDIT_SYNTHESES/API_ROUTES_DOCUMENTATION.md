# Documentation API Backend - DWH Groupe DURET

> **Base URL:** `http://localhost:3000`
> **Swagger UI:** `http://localhost:3000/api`
> **Date:** 2024-11-28

---

## Table des Matières

1. [KPI Dashboard](#1-kpi-dashboard)
2. [Commercial](#2-commercial)
3. [Trésorerie](#3-trésorerie)
4. [Ressources Humaines](#4-ressources-humaines)
5. [Stock](#5-stock)
6. [Anomalies (Business)](#6-anomalies-business)
7. [Machine Learning](#7-machine-learning)
8. [Data Quality (NOUVEAU)](#8-data-quality-nouveau)
9. [ETL Monitoring (NOUVEAU)](#9-etl-monitoring-nouveau)

---

## Filtres Communs

### PeriodeFilterDto
```typescript
interface PeriodeFilterDto {
  annee?: number;      // Ex: 2024
  mois?: number;       // 1-12
  trimestre?: number;  // 1-4
  societeId?: number;  // ID société
}
```

### PaginationDto
```typescript
interface PaginationDto {
  page?: number;   // Défaut: 1
  limit?: number;  // Défaut: 20
}
```

---

## 1. KPI Dashboard

**Base:** `/api/kpi`

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/dashboard` | Tableau de bord direction avec tous les KPIs | PeriodeFilterDto | Dashboard principal |
| GET | `/summary` | Résumé consolidé des KPIs récents | - | Header/Sidebar |
| GET | `/latest` | KPIs de la dernière période | - | Widgets temps réel |
| GET | `/evolution` | Évolution des KPIs dans le temps | PeriodeFilterDto | Graphiques évolution |
| GET | `/societes` | Liste des sociétés | - | Sélecteur société |
| GET | `/societe/:id` | KPIs détaillés par société | id, PeriodeFilterDto | Vue société |

### Exemple Response `/dashboard`
```json
{
  "ca_total": 1250000,
  "ca_variation": 5.2,
  "marge_brute": 320000,
  "marge_pct": 25.6,
  "tresorerie": 450000,
  "nb_affaires_cours": 42,
  "nb_clients_actifs": 156
}
```

---

## 2. Commercial

**Base:** `/api/commercial`

### Chiffre d'Affaires

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/ca` | CA par période | PeriodeFilterDto | Vue CA |
| GET | `/ca/evolution` | Évolution mensuelle du CA | PeriodeFilterDto | Graphique CA |
| GET | `/segments` | Liste des segments CA | - | Filtres |

### Clients

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/clients` | Liste clients avec KPIs | PeriodeFilterDto, PaginationDto | Liste clients |
| GET | `/clients/top` | Top clients par CA | PeriodeFilterDto, limit? | Widget top clients |
| GET | `/clients/:id` | Détail client | id, PeriodeFilterDto | Fiche client |

### Affaires

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/affaires` | Liste affaires avec KPIs | PeriodeFilterDto, PaginationDto | Liste affaires |
| GET | `/affaires/retard` | Affaires en retard | PeriodeFilterDto | Alertes |
| GET | `/affaires/depassement` | Affaires en dépassement budget | PeriodeFilterDto | Alertes |
| GET | `/affaires/:id` | Détail affaire | id | Fiche affaire |

---

## 3. Trésorerie

**Base:** `/api/tresorerie`

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/solde` | Solde et flux de trésorerie | PeriodeFilterDto | Dashboard tréso |
| GET | `/evolution` | Évolution mensuelle | PeriodeFilterDto | Graphique tréso |
| GET | `/bfr` | Besoin en Fonds de Roulement | PeriodeFilterDto | KPI BFR |
| GET | `/balance-agee` | Balance âgée par client | PeriodeFilterDto, PaginationDto | Table balance |
| GET | `/balance-agee/synthese` | Totaux par tranche d'âge | PeriodeFilterDto | Graphique âge |
| GET | `/risque-credit` | Clients à risque crédit | PeriodeFilterDto, seuil? | Alertes crédit |

### Exemple Response `/balance-agee/synthese`
```json
{
  "non_echu": 125000,
  "0_30_jours": 45000,
  "31_60_jours": 23000,
  "61_90_jours": 12000,
  "plus_90_jours": 8500,
  "total": 213500
}
```

---

## 4. Ressources Humaines

**Base:** `/api/rh`

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/productivite` | Productivité des salariés | PeriodeFilterDto, PaginationDto | Table productivité |
| GET | `/synthese` | Synthèse mensuelle RH | PeriodeFilterDto | Dashboard RH |
| GET | `/top-productifs` | Top salariés productifs | PeriodeFilterDto, limit? | Widget top |
| GET | `/sous-occupes` | Salariés sous-occupés | PeriodeFilterDto, seuil? | Alertes RH |
| GET | `/postes` | Liste des postes | - | Filtres |
| GET | `/qualifications` | Liste des qualifications | - | Filtres |
| GET | `/synthese-mensuelle` | Détail heures salarié | id, PeriodeFilterDto | Fiche salarié |

---

## 5. Stock

**Base:** `/api/stock`

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/` | Liste stocks avec filtres | StockFilterDto | Table stocks |
| GET | `/familles` | Liste des familles articles | - | Filtres |
| GET | `/alertes` | Toutes alertes stock | PeriodeFilterDto | Dashboard alertes |
| GET | `/alertes/rupture` | Articles en rupture | PeriodeFilterDto | Alertes rupture |
| GET | `/alertes/surstock` | Articles en surstock | PeriodeFilterDto | Alertes surstock |
| GET | `/rotation` | Rotation des stocks | PeriodeFilterDto, PaginationDto | Table rotation |
| GET | `/synthese` | Synthèse globale stocks | PeriodeFilterDto | KPIs stock |
| GET | `/valeur-famille` | Valeur par famille | PeriodeFilterDto | Graphique répartition |

---

## 6. Anomalies (Business)

**Base:** `/api/anomalies`

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/` | Toutes anomalies business | PeriodeFilterDto | Liste anomalies |
| GET | `/synthese` | Comptage par sévérité/catégorie | PeriodeFilterDto | Dashboard anomalies |
| GET | `/ecarts-budget` | Affaires en dépassement budget | PeriodeFilterDto | Alertes budget |
| GET | `/retards` | Affaires en retard | PeriodeFilterDto | Alertes retard |
| GET | `/impayes` | Clients avec impayés | PeriodeFilterDto | Alertes impayés |
| GET | `/risque-credit` | Clients risque crédit élevé | PeriodeFilterDto | Alertes crédit |
| GET | `/stock` | Alertes stock (ruptures/surstocks) | PeriodeFilterDto | Alertes stock |

### Exemple Response `/synthese`
```json
{
  "total": 45,
  "par_severite": {
    "critique": 3,
    "haute": 12,
    "moyenne": 20,
    "basse": 10
  },
  "par_categorie": {
    "affaires": 15,
    "clients": 22,
    "stock": 8
  }
}
```

---

## 7. Machine Learning

**Base:** `/api/ml`

### Statistiques

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/stats` | Stats globales ML (clients + affaires) | - | Dashboard ML |

### Clients ML

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/clients/segmentation` | Segmentation RFM clients | PaginationDto | Table segmentation |
| GET | `/clients/segmentation/synthese` | Stats par segment | - | Graphique segments |
| GET | `/clients/segment/:segment` | Clients d'un segment | segment, PaginationDto | Liste filtrée |
| GET | `/clients/churn-risk` | Clients à risque churn | seuil?, PaginationDto | Alertes churn |
| GET | `/clients/fort-potentiel` | Clients fort potentiel | seuil?, PaginationDto | Opportunités |
| GET | `/clients/:id/features` | Features ML d'un client | id | Fiche ML client |

### Affaires ML

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/affaires/predictions` | Prédictions marge affaires | PaginationDto | Table prédictions |
| GET | `/affaires/risque-depassement` | Affaires à risque dépassement | seuil?, PaginationDto | Alertes risque |
| GET | `/affaires/:id/features` | Features ML d'une affaire | id | Fiche ML affaire |

### Exemple Response `/clients/segmentation/synthese`
```json
[
  { "segment_valeur": "VIP", "nb_clients": 12, "ca_total": 850000, "score_rfm_moyen": 92 },
  { "segment_valeur": "PREMIUM", "nb_clients": 45, "ca_total": 620000, "score_rfm_moyen": 75 },
  { "segment_valeur": "STANDARD", "nb_clients": 89, "ca_total": 280000, "score_rfm_moyen": 55 },
  { "segment_valeur": "PETIT", "nb_clients": 124, "ca_total": 95000, "score_rfm_moyen": 25 }
]
```

---

## 8. Data Quality (NOUVEAU)

**Base:** `/api/data-quality`

### Dashboard

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/dashboard` | Vue d'ensemble qualité données | - | Dashboard qualité |

### Règles

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/rules` | Toutes les règles de qualité | - | Admin règles |
| GET | `/rules/active` | Règles actives uniquement | - | Liste règles |
| GET | `/rules/layer/:layer` | Règles par couche (BRONZE/SILVER/GOLD) | layer | Filtrage |

### Contrôles

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/checks` | Derniers contrôles exécutés | PaginationDto | Historique checks |
| GET | `/checks/summary` | Synthèse des contrôles | - | KPIs qualité |
| GET | `/checks/failed` | Contrôles en échec | PaginationDto | Alertes qualité |

### Anomalies Data

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/anomalies` | Anomalies détectées | PaginationDto, severity? | Liste anomalies |
| GET | `/anomalies/summary` | Synthèse des anomalies | - | Dashboard |
| GET | `/anomalies/unresolved` | Anomalies non résolues | PaginationDto | À traiter |
| GET | `/anomalies/layer/:layer` | Anomalies par couche | layer | Filtrage |
| PATCH | `/anomalies/:id/resolve` | Marquer anomalie résolue | id, comment | Action résolution |

### Exemple Response `/dashboard`
```json
{
  "checks": {
    "total_checks": 156,
    "today": { "passed": 8, "failed": 0, "total": 8, "success_rate": "100.0" },
    "last_execution": "2024-11-28T20:15:00Z",
    "failed_by_type": []
  },
  "anomalies": {
    "last_30_days": 23,
    "unresolved": 5,
    "by_severity": { "warning": 3, "error": 2 },
    "by_layer": { "silver": 4, "gold": 1 }
  },
  "rules_count": 8
}
```

### Exemple Response `/anomalies/summary`
```json
{
  "last_30_days": 23,
  "unresolved": 5,
  "by_severity": {
    "info": 2,
    "warning": 8,
    "error": 10,
    "critical": 3
  },
  "by_layer": {
    "bronze": 5,
    "silver": 12,
    "gold": 6
  },
  "top_types": [
    { "type": "COMPLETENESS", "count": 8 },
    { "type": "VALIDITY", "count": 6 },
    { "type": "CONSISTENCY", "count": 5 }
  ]
}
```

---

## 9. ETL Monitoring (NOUVEAU)

**Base:** `/api/etl`

### Dashboard & Stats

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/dashboard` | Vue d'ensemble ETL complète | - | Dashboard ETL |
| GET | `/stats` | Statistiques des jobs | - | KPIs ETL |
| GET | `/layers` | Stats par couche (BRONZE/SILVER/GOLD) | - | Vue par couche |

### Jobs

| Méthode | Endpoint | Description | Params | Frontend Page |
|---------|----------|-------------|--------|---------------|
| GET | `/jobs` | Liste des jobs ETL | PaginationDto, status? | Historique jobs |
| GET | `/jobs/running` | Jobs en cours d'exécution | - | Monitoring live |
| GET | `/jobs/failed` | Jobs en échec | PaginationDto | Alertes ETL |
| GET | `/jobs/:id` | Détail d'un job | id | Fiche job |
| GET | `/jobs/history/:jobName` | Historique d'un job | jobName, days? | Historique spécifique |
| GET | `/layers/:layer` | Jobs d'une couche | layer | Filtrage |

### Exemple Response `/dashboard`
```json
{
  "total_jobs": 1250,
  "running": 0,
  "today": { "success": 12, "failed": 0, "total": 12 },
  "last_7_days": {
    "success": { "count": 84, "inserts": 125000, "updates": 3500 },
    "failed": { "count": 2, "inserts": 0, "updates": 0 }
  },
  "last_job": {
    "id": 1250,
    "job_name": "LOAD_SILVER_DIM_CLIENT",
    "status": "SUCCESS",
    "start_time": "2024-11-28T19:00:00Z"
  },
  "avg_duration_seconds": 45.2,
  "layers": [
    { "layer": "BRONZE", "total_jobs": 42, "success": 42, "failed": 0, "success_rate": "100.0" },
    { "layer": "SILVER", "total_jobs": 28, "success": 27, "failed": 1, "success_rate": "96.4" },
    { "layer": "GOLD", "total_jobs": 14, "success": 13, "failed": 1, "success_rate": "92.9" }
  ],
  "running_jobs": []
}
```

### Exemple Response `/stats`
```json
{
  "total_jobs": 1250,
  "running": 0,
  "today": { "success": 12, "failed": 0, "total": 12 },
  "last_7_days": {
    "success": { "count": 84, "inserts": 125000, "updates": 3500 }
  },
  "avg_duration_seconds": 45.2
}
```

---

## Mapping Frontend Suggéré

### Pages Principales

| Page Frontend | Endpoints Principaux |
|---------------|---------------------|
| Dashboard Direction | `/api/kpi/dashboard`, `/api/anomalies/synthese` |
| Commercial > CA | `/api/commercial/ca`, `/api/commercial/ca/evolution` |
| Commercial > Clients | `/api/commercial/clients`, `/api/ml/clients/segmentation` |
| Commercial > Affaires | `/api/commercial/affaires`, `/api/ml/affaires/predictions` |
| Trésorerie | `/api/tresorerie/solde`, `/api/tresorerie/balance-agee` |
| RH > Productivité | `/api/rh/productivite`, `/api/rh/synthese` |
| Stock | `/api/stock/synthese`, `/api/stock/alertes` |
| **Qualité Données** | `/api/data-quality/dashboard`, `/api/data-quality/anomalies` |
| **ETL Monitoring** | `/api/etl/dashboard`, `/api/etl/jobs` |
| **ML Analytics** | `/api/ml/stats`, `/api/ml/clients/churn-risk` |

### Widgets Alertes

| Widget | Endpoints |
|--------|-----------|
| Alertes Critiques | `/api/anomalies/synthese`, `/api/data-quality/anomalies/unresolved` |
| ETL Status | `/api/etl/jobs/running`, `/api/etl/jobs/failed` |
| Qualité Score | `/api/data-quality/checks/summary` |
| Churn Risk | `/api/ml/clients/churn-risk?seuil=0.7` |
| Affaires à Risque | `/api/ml/affaires/risque-depassement?seuil=70` |

---

## Types TypeScript Frontend

```typescript
// Anomalie Data Quality
interface DataAnomaly {
  id: number;
  layer: 'BRONZE' | 'SILVER' | 'GOLD';
  tableName: string;
  anomalyType: string;
  description: string;
  severity: 'INFO' | 'WARNING' | 'ERROR' | 'CRITICAL';
  detectedAt: Date;
  resolvedAt?: Date;
  resolutionComment?: string;
}

// Job ETL
interface JobExecution {
  id: number;
  jobName: string;
  sourceSystem: string;
  targetLayer: 'BRONZE' | 'SILVER' | 'GOLD';
  startTime: Date;
  endTime?: Date;
  status: 'RUNNING' | 'SUCCESS' | 'FAILED' | 'WARNING';
  rowsInserted: number;
  rowsUpdated: number;
  errorMessage?: string;
}

// ML Features Client
interface MlFeaturesClient {
  clientSk: number;
  segmentValeur: 'VIP' | 'PREMIUM' | 'STANDARD' | 'PETIT';
  segmentRisque: 'FAIBLE' | 'MOYEN' | 'ELEVE';
  scoreRfm: number;
  scorePotentiel: number;
  probabiliteChurn: number;
  ca12m: number;
  tendanceCa: number;
}

// ML Features Affaire
interface MlFeaturesAffaire {
  affaireSk: number;
  typeAffaire: string;
  montantCommande: number;
  risqueDepassementScore: number;
  margeReellePct?: number;
  margePreditePct?: number;
  ecartBudgetHeuresPct?: number;
  retardJours?: number;
}
```

---

## Notes d'Implémentation

1. **Pagination** : Toutes les listes supportent `page` et `limit`
2. **Filtres** : Utiliser `societeId` pour filtrer par société
3. **Seuils** : Les endpoints alertes acceptent des seuils personnalisables
4. **Dates** : Format ISO 8601 (ex: `2024-11-28T19:00:00Z`)
5. **Swagger** : Documentation interactive sur `/api`

---

*Généré automatiquement - DWH Groupe DURET*

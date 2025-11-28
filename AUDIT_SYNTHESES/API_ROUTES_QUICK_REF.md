# API Routes - Quick Reference

## Toutes les Routes (copier-coller)

```typescript
// ============ KPI ============
GET  /api/kpi/dashboard
GET  /api/kpi/summary
GET  /api/kpi/latest
GET  /api/kpi/evolution
GET  /api/kpi/societes
GET  /api/kpi/societe/:id

// ============ COMMERCIAL ============
GET  /api/commercial/ca
GET  /api/commercial/ca/evolution
GET  /api/commercial/segments
GET  /api/commercial/clients
GET  /api/commercial/clients/top
GET  /api/commercial/clients/:id
GET  /api/commercial/affaires
GET  /api/commercial/affaires/retard
GET  /api/commercial/affaires/depassement
GET  /api/commercial/affaires/:id

// ============ TRESORERIE ============
GET  /api/tresorerie/solde
GET  /api/tresorerie/evolution
GET  /api/tresorerie/bfr
GET  /api/tresorerie/balance-agee
GET  /api/tresorerie/balance-agee/synthese
GET  /api/tresorerie/risque-credit

// ============ RH ============
GET  /api/rh/productivite
GET  /api/rh/synthese
GET  /api/rh/top-productifs
GET  /api/rh/sous-occupes
GET  /api/rh/postes
GET  /api/rh/qualifications
GET  /api/rh/synthese-mensuelle

// ============ STOCK ============
GET  /api/stock
GET  /api/stock/familles
GET  /api/stock/alertes
GET  /api/stock/alertes/rupture
GET  /api/stock/alertes/surstock
GET  /api/stock/rotation
GET  /api/stock/synthese
GET  /api/stock/valeur-famille

// ============ ANOMALIES (Business) ============
GET  /api/anomalies
GET  /api/anomalies/synthese
GET  /api/anomalies/ecarts-budget
GET  /api/anomalies/retards
GET  /api/anomalies/impayes
GET  /api/anomalies/risque-credit
GET  /api/anomalies/stock

// ============ ML ============
GET  /api/ml/stats
GET  /api/ml/clients/segmentation
GET  /api/ml/clients/segmentation/synthese
GET  /api/ml/clients/segment/:segment
GET  /api/ml/clients/churn-risk
GET  /api/ml/clients/fort-potentiel
GET  /api/ml/clients/:id/features
GET  /api/ml/affaires/predictions
GET  /api/ml/affaires/risque-depassement
GET  /api/ml/affaires/:id/features

// ============ DATA QUALITY (NOUVEAU) ============
GET   /api/data-quality/dashboard
GET   /api/data-quality/rules
GET   /api/data-quality/rules/active
GET   /api/data-quality/rules/layer/:layer
GET   /api/data-quality/checks
GET   /api/data-quality/checks/summary
GET   /api/data-quality/checks/failed
GET   /api/data-quality/anomalies
GET   /api/data-quality/anomalies/summary
GET   /api/data-quality/anomalies/unresolved
GET   /api/data-quality/anomalies/layer/:layer
PATCH /api/data-quality/anomalies/:id/resolve

// ============ ETL (NOUVEAU) ============
GET  /api/etl/dashboard
GET  /api/etl/stats
GET  /api/etl/jobs
GET  /api/etl/jobs/running
GET  /api/etl/jobs/failed
GET  /api/etl/jobs/:id
GET  /api/etl/jobs/history/:jobName
GET  /api/etl/layers
GET  /api/etl/layers/:layer
```

## Service API TypeScript

```typescript
// api.service.ts
const API_BASE = 'http://localhost:3000';

export const api = {
  // KPI
  kpi: {
    dashboard: (params?) => fetch(`${API_BASE}/api/kpi/dashboard?${new URLSearchParams(params)}`),
    summary: () => fetch(`${API_BASE}/api/kpi/summary`),
    latest: () => fetch(`${API_BASE}/api/kpi/latest`),
    evolution: (params?) => fetch(`${API_BASE}/api/kpi/evolution?${new URLSearchParams(params)}`),
    societes: () => fetch(`${API_BASE}/api/kpi/societes`),
    societe: (id, params?) => fetch(`${API_BASE}/api/kpi/societe/${id}?${new URLSearchParams(params)}`),
  },

  // Commercial
  commercial: {
    ca: (params?) => fetch(`${API_BASE}/api/commercial/ca?${new URLSearchParams(params)}`),
    caEvolution: (params?) => fetch(`${API_BASE}/api/commercial/ca/evolution?${new URLSearchParams(params)}`),
    clients: (params?) => fetch(`${API_BASE}/api/commercial/clients?${new URLSearchParams(params)}`),
    topClients: (params?) => fetch(`${API_BASE}/api/commercial/clients/top?${new URLSearchParams(params)}`),
    client: (id, params?) => fetch(`${API_BASE}/api/commercial/clients/${id}?${new URLSearchParams(params)}`),
    affaires: (params?) => fetch(`${API_BASE}/api/commercial/affaires?${new URLSearchParams(params)}`),
    affaire: (id) => fetch(`${API_BASE}/api/commercial/affaires/${id}`),
  },

  // Trésorerie
  tresorerie: {
    solde: (params?) => fetch(`${API_BASE}/api/tresorerie/solde?${new URLSearchParams(params)}`),
    evolution: (params?) => fetch(`${API_BASE}/api/tresorerie/evolution?${new URLSearchParams(params)}`),
    bfr: (params?) => fetch(`${API_BASE}/api/tresorerie/bfr?${new URLSearchParams(params)}`),
    balanceAgee: (params?) => fetch(`${API_BASE}/api/tresorerie/balance-agee?${new URLSearchParams(params)}`),
    balanceAgeeSynthese: (params?) => fetch(`${API_BASE}/api/tresorerie/balance-agee/synthese?${new URLSearchParams(params)}`),
  },

  // RH
  rh: {
    productivite: (params?) => fetch(`${API_BASE}/api/rh/productivite?${new URLSearchParams(params)}`),
    synthese: (params?) => fetch(`${API_BASE}/api/rh/synthese?${new URLSearchParams(params)}`),
    topProductifs: (params?) => fetch(`${API_BASE}/api/rh/top-productifs?${new URLSearchParams(params)}`),
    sousOccupes: (params?) => fetch(`${API_BASE}/api/rh/sous-occupes?${new URLSearchParams(params)}`),
  },

  // Stock
  stock: {
    list: (params?) => fetch(`${API_BASE}/api/stock?${new URLSearchParams(params)}`),
    alertes: (params?) => fetch(`${API_BASE}/api/stock/alertes?${new URLSearchParams(params)}`),
    synthese: (params?) => fetch(`${API_BASE}/api/stock/synthese?${new URLSearchParams(params)}`),
  },

  // Anomalies (Business)
  anomalies: {
    all: (params?) => fetch(`${API_BASE}/api/anomalies?${new URLSearchParams(params)}`),
    synthese: (params?) => fetch(`${API_BASE}/api/anomalies/synthese?${new URLSearchParams(params)}`),
  },

  // ML
  ml: {
    stats: () => fetch(`${API_BASE}/api/ml/stats`),
    clientSegmentation: (params?) => fetch(`${API_BASE}/api/ml/clients/segmentation?${new URLSearchParams(params)}`),
    clientSegmentationSynthese: () => fetch(`${API_BASE}/api/ml/clients/segmentation/synthese`),
    clientChurnRisk: (params?) => fetch(`${API_BASE}/api/ml/clients/churn-risk?${new URLSearchParams(params)}`),
    clientFeatures: (id) => fetch(`${API_BASE}/api/ml/clients/${id}/features`),
    affairePredictions: (params?) => fetch(`${API_BASE}/api/ml/affaires/predictions?${new URLSearchParams(params)}`),
    affaireRisque: (params?) => fetch(`${API_BASE}/api/ml/affaires/risque-depassement?${new URLSearchParams(params)}`),
    affaireFeatures: (id) => fetch(`${API_BASE}/api/ml/affaires/${id}/features`),
  },

  // Data Quality (NOUVEAU)
  dataQuality: {
    dashboard: () => fetch(`${API_BASE}/api/data-quality/dashboard`),
    rules: () => fetch(`${API_BASE}/api/data-quality/rules`),
    rulesActive: () => fetch(`${API_BASE}/api/data-quality/rules/active`),
    rulesByLayer: (layer) => fetch(`${API_BASE}/api/data-quality/rules/layer/${layer}`),
    checks: (params?) => fetch(`${API_BASE}/api/data-quality/checks?${new URLSearchParams(params)}`),
    checksSummary: () => fetch(`${API_BASE}/api/data-quality/checks/summary`),
    checksFailed: (params?) => fetch(`${API_BASE}/api/data-quality/checks/failed?${new URLSearchParams(params)}`),
    anomalies: (params?) => fetch(`${API_BASE}/api/data-quality/anomalies?${new URLSearchParams(params)}`),
    anomaliesSummary: () => fetch(`${API_BASE}/api/data-quality/anomalies/summary`),
    anomaliesUnresolved: (params?) => fetch(`${API_BASE}/api/data-quality/anomalies/unresolved?${new URLSearchParams(params)}`),
    anomaliesByLayer: (layer) => fetch(`${API_BASE}/api/data-quality/anomalies/layer/${layer}`),
    resolveAnomaly: (id, comment) => fetch(`${API_BASE}/api/data-quality/anomalies/${id}/resolve`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ comment }),
    }),
  },

  // ETL (NOUVEAU)
  etl: {
    dashboard: () => fetch(`${API_BASE}/api/etl/dashboard`),
    stats: () => fetch(`${API_BASE}/api/etl/stats`),
    jobs: (params?) => fetch(`${API_BASE}/api/etl/jobs?${new URLSearchParams(params)}`),
    jobsRunning: () => fetch(`${API_BASE}/api/etl/jobs/running`),
    jobsFailed: (params?) => fetch(`${API_BASE}/api/etl/jobs/failed?${new URLSearchParams(params)}`),
    job: (id) => fetch(`${API_BASE}/api/etl/jobs/${id}`),
    jobHistory: (jobName, days?) => fetch(`${API_BASE}/api/etl/jobs/history/${jobName}?days=${days || 30}`),
    layers: () => fetch(`${API_BASE}/api/etl/layers`),
    layerJobs: (layer) => fetch(`${API_BASE}/api/etl/layers/${layer}`),
  },
};
```

## Comptage Routes

| Module | Routes | Nouveau |
|--------|--------|---------|
| KPI | 6 | - |
| Commercial | 10 | - |
| Trésorerie | 6 | - |
| RH | 7 | - |
| Stock | 8 | - |
| Anomalies | 7 | - |
| ML | 10 | - |
| **Data Quality** | **12** | **OUI** |
| **ETL** | **9** | **OUI** |
| **TOTAL** | **75** | **21 nouveaux** |

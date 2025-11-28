# AUDIT DATA WAREHOUSE & PLAN DASHBOARD FRONTEND

## Groupe DURET - Analyse et Recommandations

**Date:** 2024
**Version:** 1.0
**Auteur:** Audit Technique

---

## Table des matieres

1. [Audit Data Warehouse](#1-audit-data-warehouse)
2. [Architecture Dashboard](#2-architecture-dashboard)
3. [Sections detaillees](#3-sections-detaillees)
4. [Recommandations UI/UX](#4-recommandations-uiux)
5. [Stack Technique](#5-stack-technique)
6. [Plan d'implementation](#6-plan-dimplementation)

---

## 1. Audit Data Warehouse

### 1.1 Donnees disponibles - Couche Gold

| Domaine | Table Gold | Metriques cles | Potentiel visuel |
|---------|------------|----------------|------------------|
| **KPIs Direction** | `kpi_global` | CA, Marge, Treso, RH, Affaires | Excellent |
| **Commercial** | `agg_ca_periode`, `agg_ca_client` | CA mensuel/client, transformation | Excellent |
| **Affaires/Projets** | `agg_ca_affaire` | Marges, risques, depassements | Excellent |
| **RH/Productivite** | `agg_heures_salarie`, `agg_heures_affaire` | Taux occupation, couts MO | Tres bon |
| **Creances** | `agg_balance_agee_client` | DSO, echus, risque credit | Excellent |
| **Stock** | `agg_stock_element` | Alertes, rotation, couverture | Tres bon |
| **ML/Predictif** | `ml_features_client` | Segmentation RFM, churn, potentiel | Excellent |

### 1.2 Vues Gold disponibles

| Vue | Description | Usage Dashboard |
|-----|-------------|-----------------|
| `v_dashboard_direction` | KPIs consolides direction | Section Vue d'ensemble |
| `v_analyse_client` | Analyse clients | Section Commercial |
| `v_suivi_affaires` | Suivi projets avec risques | Section Affaires |
| `v_productivite_equipes` | Productivite RH | Section RH |
| `v_alertes_stock` | Alertes rupture/surstock | Section Stock |
| `v_balance_agee_consolidee` | Creances par tranche | Section Tresorerie |

### 1.3 Structure KPI Global

```sql
-- Metriques disponibles dans kpi_global
kpi_ca_mensuel              -- CA du mois
kpi_ca_cumul                -- CA cumule annee
kpi_ca_objectif             -- Objectif CA
kpi_ca_realisation_pct      -- % realisation
kpi_ca_variation_n1_pct     -- Variation N-1
kpi_panier_moyen            -- Panier moyen
kpi_nb_nouveaux_clients     -- Nouveaux clients
kpi_taux_transformation     -- Taux transfo devis->commande
kpi_marge_brute             -- Marge brute
kpi_taux_marge              -- Taux de marge
kpi_tresorerie_nette        -- Tresorerie
kpi_bfr                     -- BFR
kpi_dso_jours               -- Delai paiement clients
kpi_dpo_jours               -- Delai paiement fournisseurs
kpi_effectif_moyen          -- Effectif
kpi_heures_productives      -- Heures productives
kpi_taux_occupation         -- Taux occupation
kpi_ca_par_salarie          -- CA par salarie
kpi_nb_affaires_en_cours    -- Affaires en cours
kpi_nb_affaires_en_retard   -- Affaires en retard
kpi_carnet_commandes        -- Carnet commandes
kpi_reste_a_facturer        -- Reste a facturer
```

### 1.4 Societes du groupe

| Code | Nom |
|------|-----|
| DURETELEC | DURET ELECTRICITE SAS |
| DURETENE | DURET ENERGIE SARL |
| DURETRES | DURET RESEAUX SAS |
| DURETSER | DURET SERVICES SARL |

---

## 2. Architecture Dashboard

### 2.1 Structure globale

```
+---------------------------------------------------------------------+
|  HEADER                                                              |
|  [Logo] [Selecteur Societe] [Selecteur Periode] [Notifications] [User]|
+-------------+-------------------------------------------------------+
|  SIDEBAR    |  MAIN CONTENT                                         |
|  ---------  |  -------------                                         |
|             |                                                        |
|  Vue        |  +-------------+-------------+-------------+           |
|  d'ensemble |  | KPI Card 1  | KPI Card 2  | KPI Card 3  |           |
|             |  +-------------+-------------+-------------+           |
|  Commercial |                                                        |
|             |  +---------------------------+------------------------+|
|  Affaires   |  |     Chart Principal       |    Chart Secondaire    ||
|             |  |     (Line/Bar)            |    (Doughnut/Pie)      ||
|  RH         |  +---------------------------+------------------------+|
|             |                                                        |
|  Tresorerie |  +---------------------------+------------------------+|
|             |  |     Chart 3               |    Chart 4             ||
|  Stocks     |  +---------------------------+------------------------+|
|             |                                                        |
|  ML/IA      |  +---------------------------------------------------+|
|             |  |     DataTable                                      ||
|  Alertes    |  +---------------------------------------------------+|
|             |                                                        |
+-------------+-------------------------------------------------------+
```

### 2.2 Navigation

```
Sidebar Menu:
├── Vue d'ensemble      (icone: LayoutDashboard)
├── Commercial          (icone: TrendingUp)
│   ├── CA & Pipeline
│   └── Clients
├── Affaires            (icone: Briefcase)
│   ├── Suivi projets
│   └── Rentabilite
├── RH & Productivite   (icone: Users)
├── Tresorerie          (icone: Wallet)
│   ├── Flux
│   └── Creances
├── Stocks              (icone: Package)
├── Intelligence Client (icone: Brain)
└── Alertes             (icone: AlertTriangle)
```

---

## 3. Sections detaillees

### 3.1 Vue d'ensemble (Direction)

#### Layout

```
+----------+----------+----------+----------+----------+----------+
| CA Mois  | CA Cumul | Marge %  | Treso    | Carnet   | Affaires |
| +12%     | +8%      | -2%      | +5%      | Commandes| Retard   |
| (trend)  | (trend)  | (trend)  | (trend)  | (amount) | (count)  |
+----------+----------+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  CA Evolution 12 mois          |  Repartition CA par societe    |
|  [Line Chart multi-societe]    |  [Doughnut Chart]              |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Comparatif N vs N-1           |  Objectifs vs Realise          |
|  [Bar Chart grouped]           |  [Progress bars / Gauge]       |
+--------------------------------+--------------------------------+
```

#### Charts recommandes

| Widget | Type Chart.js | Source donnees | Options cles |
|--------|---------------|----------------|--------------|
| KPI Cards | HTML + Sparkline | `kpi_global` | Animation compteur |
| CA Evolution | `Line` | `agg_ca_periode` | Multi-dataset, tension: 0.4 |
| Repartition | `Doughnut` | `agg_ca_periode` GROUP BY societe | cutout: 60% |
| N vs N-1 | `Bar` grouped | `kpi_global` | Couleurs distinctes |
| Objectifs | Semi-doughnut | `kpi_ca_realisation_pct` | rotation: -90, circumference: 180 |

#### Code exemple - KPI Card

```jsx
const KPICard = ({ label, value, variation, trend, icon }) => (
  <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100">
    <div className="flex items-center justify-between mb-4">
      <span className="text-gray-500 text-sm font-medium">{label}</span>
      <div className="p-2 bg-blue-50 rounded-lg">{icon}</div>
    </div>
    <div className="text-3xl font-bold text-gray-900 mb-2">
      {formatCurrency(value)}
    </div>
    <div className={`flex items-center text-sm ${
      variation >= 0 ? 'text-green-600' : 'text-red-600'
    }`}>
      {variation >= 0 ? <TrendingUp size={16}/> : <TrendingDown size={16}/>}
      <span className="ml-1">{Math.abs(variation)}% vs N-1</span>
    </div>
    <div className="mt-4 h-12">
      <Sparkline data={trend} />
    </div>
  </div>
);
```

---

### 3.2 Commercial

#### Layout

```
+----------+----------+----------+----------+
| Devis    | Commandes| Facture  | Taux     |
| emis     | signees  | ce mois  | Transfo  |
+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Pipeline commercial           |  CA par segment client         |
|  [Funnel / Stacked Bar]        |  [Pie Chart]                   |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Top 10 Clients CA             |  Evolution panier moyen        |
|  [Horizontal Bar]              |  [Line + Area]                 |
+--------------------------------+--------------------------------+

+--------------------------------------------------------------------+
|  Tableau clients actifs (DataTable sortable/filtrable)              |
+--------------------------------------------------------------------+
```

#### Charts recommandes

| Widget | Type | Config |
|--------|------|--------|
| Pipeline | `Bar` horizontal stacked | indexAxis: 'y', stacked: true |
| Segments | `Pie` | Couleurs par segment |
| Top clients | `Bar` horizontal | indexAxis: 'y', sorted |
| Panier moyen | `Line` | fill: true, tension: 0.4 |

#### Requete SQL - Top Clients

```sql
SELECT
    c.raison_sociale,
    a.ca_cumule,
    a.variation_ca_pct,
    a.taux_marge,
    a.segment_ca
FROM gold.agg_ca_client a
JOIN silver.dim_client c ON c.client_sk = a.client_sk
WHERE a.annee = EXTRACT(YEAR FROM CURRENT_DATE)
ORDER BY a.ca_cumule DESC
LIMIT 10;
```

---

### 3.3 Affaires / Projets

#### Layout

```
+----------+----------+----------+----------+----------+
| En cours | En retard| Depasst  | Marge    | Reste a  |
| (count)  | (alert)  | budget   | moyenne  | facturer |
+----------+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Affaires par etat             |  Risque affaires               |
|  [Doughnut / Pie]              |  [Stacked Bar ou Treemap]      |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Marge prevue vs reelle        |  Heures budget vs reel         |
|  [Scatter ou Bar compare]      |  [Bar grouped]                 |
+--------------------------------+--------------------------------+

+--------------------------------------------------------------------+
|  Tableau affaires (badges risque, progress avancement)              |
+--------------------------------------------------------------------+
```

#### Niveaux de risque

| Niveau | Couleur | Criteres |
|--------|---------|----------|
| CRITIQUE | `#EF4444` (rouge) | Retard + depassement budget |
| ELEVE | `#F97316` (orange) | Retard OU depassement > 20% |
| MOYEN | `#EAB308` (jaune) | Ecart < 20% |
| FAIBLE | `#22C55E` (vert) | Dans les clous |

#### Code exemple - Badge risque

```jsx
const RiskBadge = ({ level }) => {
  const config = {
    CRITIQUE: { bg: 'bg-red-100', text: 'text-red-800', dot: 'bg-red-500' },
    ELEVE: { bg: 'bg-orange-100', text: 'text-orange-800', dot: 'bg-orange-500' },
    MOYEN: { bg: 'bg-yellow-100', text: 'text-yellow-800', dot: 'bg-yellow-500' },
    FAIBLE: { bg: 'bg-green-100', text: 'text-green-800', dot: 'bg-green-500' },
  };
  const c = config[level];

  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${c.bg} ${c.text}`}>
      <span className={`w-2 h-2 rounded-full ${c.dot} mr-1.5`}></span>
      {level}
    </span>
  );
};
```

---

### 3.4 RH & Productivite

#### Layout

```
+----------+----------+----------+----------+
| Effectif | H. Prod  | Taux     | Cout/H   |
| moyen    | ce mois  | Occup.   | moyen    |
+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Heures par service            |  Evolution taux occupation     |
|  [Bar stacked]                 |  [Line Chart]                  |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Top productivite salaries     |  Cout MO par affaire           |
|  [Radar ou Bar]                |  [Bubble Chart]                |
+--------------------------------+--------------------------------+
```

#### Bubble Chart - Cout MO

```javascript
// Configuration Bubble Chart
{
  type: 'bubble',
  data: {
    datasets: [{
      label: 'Affaires',
      data: affaires.map(a => ({
        x: a.heures_realisees,      // Axe X: heures
        y: a.cout_mo_reel,          // Axe Y: cout
        r: Math.sqrt(a.marge_reelle) / 10  // Rayon: marge
      })),
      backgroundColor: 'rgba(37, 99, 235, 0.6)'
    }]
  },
  options: {
    scales: {
      x: { title: { display: true, text: 'Heures realisees' }},
      y: { title: { display: true, text: 'Cout MO (EUR)' }}
    }
  }
}
```

---

### 3.5 Tresorerie & Creances

#### Layout

```
+----------+----------+----------+----------+
| Treso    | BFR      | DSO      | Echu     |
| nette    |          | (jours)  | total    |
+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Balance agee consolidee       |  Evolution DSO                 |
|  [Stacked Bar: tranches]       |  [Line Chart]                  |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Top clients a risque          |  Recouvrement par tranche      |
|  [Horizontal Bar]              |  [Doughnut]                    |
+--------------------------------+--------------------------------+
```

#### Balance agee - Tranches

| Tranche | Couleur | Champ |
|---------|---------|-------|
| Non echu | `#22C55E` | `non_echu` |
| 0-30 jours | `#84CC16` | `echu_0_30j` |
| 31-60 jours | `#EAB308` | `echu_31_60j` |
| 61-90 jours | `#F97316` | `echu_61_90j` |
| > 90 jours | `#EF4444` | `echu_plus_90j` |

#### Requete SQL - Balance agee

```sql
SELECT
    c.raison_sociale,
    b.non_echu,
    b.echu_0_30j,
    b.echu_31_60j,
    b.echu_61_90j,
    b.echu_plus_90j,
    b.total_creances,
    b.dso_jours,
    b.score_risque_credit
FROM gold.agg_balance_agee_client b
JOIN silver.dim_client c ON c.client_sk = b.client_sk
WHERE b.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)
ORDER BY b.total_echu DESC
LIMIT 20;
```

---

### 3.6 Stocks

#### Layout

```
+----------+----------+----------+----------+
| Valeur   | Rotation | Alertes  | Alertes  |
| stock    | moyenne  | rupture  | surstock |
+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Alertes stock (tableau)       |  Stock par famille             |
|  [DataTable avec badges]       |  [Treemap ou Sunburst]         |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Evolution valeur stock        |  Top rotation / dormants       |
|  [Area Chart]                  |  [Bar bidirectionnel]          |
+--------------------------------+--------------------------------+
```

#### Types d'alertes

| Type | Icone | Condition |
|------|-------|-----------|
| RUPTURE IMMINENTE | AlertTriangle rouge | `stock_final < stock_minimum` |
| STOCK BAS | AlertTriangle orange | `couverture_jours < 15` |
| SURSTOCK | Package jaune | `est_surstock = true` |
| DORMANT | Moon gris | `rotation_stock < 1` |

---

### 3.7 Intelligence Client (ML)

#### Layout

```
+----------+----------+----------+----------+
| Clients  | Score    | Risque   | Potentiel|
| VIP      | RFM moy  | churn    | croiss.  |
+----------+----------+----------+----------+

+--------------------------------+--------------------------------+
|  Segmentation RFM              |  Distribution segments         |
|  [Scatter 3D ou Bubble]        |  [Polar Area]                  |
+--------------------------------+--------------------------------+

+--------------------------------+--------------------------------+
|  Clients a risque churn        |  Clients fort potentiel        |
|  [Table avec score]            |  [Table avec actions]          |
+--------------------------------+--------------------------------+

+--------------------------------------------------------------------+
|  Matrice valeur/comportement (heatmap)                              |
+--------------------------------------------------------------------+
```

#### Segments valeur

| Segment | Critere CA | Couleur |
|---------|------------|---------|
| VIP | Top 5% | `#7C3AED` (violet) |
| PREMIUM | Top 20% | `#2563EB` (bleu) |
| STANDARD | Middle 50% | `#06B6D4` (cyan) |
| PETIT | Bottom 30% | `#94A3B8` (gris) |

#### Requete SQL - Features ML

```sql
SELECT
    c.raison_sociale,
    m.ca_12m,
    m.tendance_ca,
    m.score_rfm,
    m.segment_valeur,
    m.segment_comportement,
    m.probabilite_churn,
    m.score_potentiel
FROM gold.ml_features_client m
JOIN silver.dim_client c ON c.client_sk = m.client_sk
WHERE m.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)
ORDER BY m.score_rfm DESC;
```

---

## 4. Recommandations UI/UX

### 4.1 Palette de couleurs

```css
:root {
  /* Couleurs primaires */
  --primary-50: #EFF6FF;
  --primary-100: #DBEAFE;
  --primary-500: #3B82F6;
  --primary-600: #2563EB;
  --primary-700: #1D4ED8;

  /* Couleurs secondaires */
  --secondary-500: #8B5CF6;
  --secondary-600: #7C3AED;

  /* Couleurs semantiques */
  --success-50: #F0FDF4;
  --success-500: #22C55E;
  --success-600: #16A34A;

  --warning-50: #FFFBEB;
  --warning-500: #F59E0B;
  --warning-600: #D97706;

  --danger-50: #FEF2F2;
  --danger-500: #EF4444;
  --danger-600: #DC2626;

  --info-50: #ECFEFF;
  --info-500: #06B6D4;
  --info-600: #0891B2;

  /* Neutres */
  --gray-50: #F8FAFC;
  --gray-100: #F1F5F9;
  --gray-200: #E2E8F0;
  --gray-300: #CBD5E1;
  --gray-400: #94A3B8;
  --gray-500: #64748B;
  --gray-600: #475569;
  --gray-700: #334155;
  --gray-800: #1E293B;
  --gray-900: #0F172A;
}
```

### 4.2 Palette Charts

```javascript
const chartColors = {
  primary: ['#2563EB', '#3B82F6', '#60A5FA', '#93C5FD'],
  secondary: ['#7C3AED', '#8B5CF6', '#A78BFA', '#C4B5FD'],
  success: ['#16A34A', '#22C55E', '#4ADE80', '#86EFAC'],
  warning: ['#D97706', '#F59E0B', '#FBBF24', '#FCD34D'],
  danger: ['#DC2626', '#EF4444', '#F87171', '#FCA5A5'],
  mixed: ['#2563EB', '#7C3AED', '#22C55E', '#F59E0B', '#EF4444', '#06B6D4'],
};
```

### 4.3 Typographie

```css
/* Font stack */
--font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', Consolas, monospace;

/* Tailles */
--text-xs: 0.75rem;    /* 12px - labels */
--text-sm: 0.875rem;   /* 14px - body small */
--text-base: 1rem;     /* 16px - body */
--text-lg: 1.125rem;   /* 18px - body large */
--text-xl: 1.25rem;    /* 20px - h4 */
--text-2xl: 1.5rem;    /* 24px - h3 */
--text-3xl: 1.875rem;  /* 30px - h2 */
--text-4xl: 2.25rem;   /* 36px - h1 */
--text-5xl: 3rem;      /* 48px - display */

/* Poids */
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

### 4.4 Composants cles

#### Card container

```jsx
const Card = ({ title, children, action }) => (
  <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    {title && (
      <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
        <h3 className="text-lg font-semibold text-gray-800">{title}</h3>
        {action}
      </div>
    )}
    <div className="p-6">
      {children}
    </div>
  </div>
);
```

#### Skeleton loader

```jsx
const Skeleton = ({ className }) => (
  <div className={`animate-pulse bg-gray-200 rounded ${className}`} />
);

// Usage
<Skeleton className="h-8 w-32" />
<Skeleton className="h-64 w-full mt-4" />
```

#### Tooltip

```jsx
const Tooltip = ({ children, content }) => (
  <div className="relative group">
    {children}
    <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-1.5
                    bg-gray-900 text-white text-xs rounded-lg opacity-0 invisible
                    group-hover:opacity-100 group-hover:visible transition-all
                    whitespace-nowrap z-50">
      {content}
      <div className="absolute top-full left-1/2 -translate-x-1/2
                      border-4 border-transparent border-t-gray-900" />
    </div>
  </div>
);
```

### 4.5 Responsive Design

| Breakpoint | Nom | Layout |
|------------|-----|--------|
| < 640px | Mobile | 1 colonne, bottom nav |
| 640-768px | Tablet portrait | 1-2 colonnes |
| 768-1024px | Tablet landscape | 2 colonnes, sidebar collapse |
| 1024-1280px | Desktop | 2-3 colonnes, sidebar |
| > 1280px | Desktop large | 3-4 colonnes, sidebar etendue |

```javascript
// Tailwind breakpoints
const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
};
```

### 4.6 Animations

```css
/* Transitions standard */
.transition-fast { transition: all 150ms ease; }
.transition-base { transition: all 200ms ease; }
.transition-slow { transition: all 300ms ease; }

/* Animation entree */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fadeIn {
  animation: fadeIn 300ms ease-out;
}

/* Animation compteur */
@keyframes countUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
```

---

## 5. Stack Technique

### 5.1 Architecture recommandee

```
Frontend/
├── src/
│   ├── components/
│   │   ├── charts/           # Composants Chart.js
│   │   │   ├── LineChart.tsx
│   │   │   ├── BarChart.tsx
│   │   │   ├── DoughnutChart.tsx
│   │   │   ├── BubbleChart.tsx
│   │   │   └── Sparkline.tsx
│   │   ├── ui/               # Composants UI
│   │   │   ├── Card.tsx
│   │   │   ├── KPICard.tsx
│   │   │   ├── Badge.tsx
│   │   │   ├── Table.tsx
│   │   │   └── Skeleton.tsx
│   │   └── layout/           # Layout
│   │       ├── Sidebar.tsx
│   │       ├── Header.tsx
│   │       └── MainLayout.tsx
│   ├── pages/                # Pages/Sections
│   │   ├── Dashboard.tsx
│   │   ├── Commercial.tsx
│   │   ├── Affaires.tsx
│   │   ├── RH.tsx
│   │   ├── Tresorerie.tsx
│   │   ├── Stocks.tsx
│   │   └── Intelligence.tsx
│   ├── hooks/                # Custom hooks
│   │   ├── useKPIs.ts
│   │   ├── useChartData.ts
│   │   └── useFilters.ts
│   ├── services/             # API calls
│   │   └── api.ts
│   ├── utils/                # Utilitaires
│   │   ├── formatters.ts
│   │   └── chartConfig.ts
│   └── types/                # TypeScript types
│       └── index.ts
├── public/
└── package.json
```

### 5.2 Dependencies principales

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "next": "^14.0.0",
    "chart.js": "^4.4.0",
    "react-chartjs-2": "^5.2.0",
    "chartjs-plugin-datalabels": "^2.2.0",
    "chartjs-chart-treemap": "^2.3.0",
    "chartjs-plugin-zoom": "^2.0.0",
    "@tanstack/react-table": "^8.10.0",
    "@tanstack/react-query": "^5.0.0",
    "tailwindcss": "^3.3.0",
    "lucide-react": "^0.290.0",
    "date-fns": "^2.30.0",
    "axios": "^1.6.0"
  }
}
```

### 5.3 Configuration Chart.js

```typescript
// chartConfig.ts
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  ChartDataLabels
);

// Defaults globaux
ChartJS.defaults.font.family = "'Inter', sans-serif";
ChartJS.defaults.color = '#64748B';
ChartJS.defaults.plugins.legend.position = 'bottom';
ChartJS.defaults.plugins.tooltip.backgroundColor = '#1E293B';
ChartJS.defaults.plugins.tooltip.titleFont = { weight: '600' };
ChartJS.defaults.plugins.tooltip.padding = 12;
ChartJS.defaults.plugins.tooltip.cornerRadius = 8;
```

### 5.4 API Endpoints suggerees

```typescript
// Endpoints API pour le dashboard
const API_ENDPOINTS = {
  // KPIs
  kpis: '/api/kpis',                        // GET ?societe_id=1&annee=2024
  kpisComparison: '/api/kpis/comparison',   // GET ?annee=2024

  // Commercial
  caPeriode: '/api/commercial/ca-periode',  // GET ?societe_id=1&annee=2024
  clients: '/api/commercial/clients',        // GET ?limit=10&sort=ca_cumule
  pipeline: '/api/commercial/pipeline',      // GET ?societe_id=1

  // Affaires
  affaires: '/api/affaires',                 // GET ?etat=EN_COURS&risque=ELEVE
  affaireDetail: '/api/affaires/:id',        // GET

  // RH
  productivite: '/api/rh/productivite',      // GET ?mois=11&annee=2024
  heuresSalarie: '/api/rh/heures',           // GET ?salarie_id=1

  // Tresorerie
  balanceAgee: '/api/tresorerie/balance-agee', // GET ?societe_id=1
  dsoEvolution: '/api/tresorerie/dso',         // GET ?periode=12m

  // Stocks
  alertesStock: '/api/stocks/alertes',       // GET ?type=rupture
  stockFamille: '/api/stocks/familles',      // GET

  // ML/Intelligence
  segmentsClients: '/api/ml/segments',       // GET
  risqueChurn: '/api/ml/churn-risk',         // GET ?seuil=0.7
};
```

---

## 6. Plan d'implementation

### 6.1 Phases

| Phase | Contenu | Priorite |
|-------|---------|----------|
| **Phase 1** | Setup projet + Vue d'ensemble | CRITIQUE |
| **Phase 2** | Commercial + Affaires | HAUTE |
| **Phase 3** | Tresorerie + Creances | HAUTE |
| **Phase 4** | RH + Productivite | MOYENNE |
| **Phase 5** | Stocks | MOYENNE |
| **Phase 6** | Intelligence ML | BASSE |
| **Phase 7** | Alertes + Notifications | BASSE |
| **Phase 8** | Polish + Optimisation | FINALE |

### 6.2 Phase 1 - Detail

```
Phase 1: Setup + Vue d'ensemble
├── Setup projet Next.js + Tailwind
├── Configuration Chart.js
├── Layout principal (Sidebar + Header)
├── Composants de base (Card, Badge, Skeleton)
├── KPI Cards avec sparklines
├── Chart CA Evolution (Line)
├── Chart Repartition societes (Doughnut)
├── Integration API KPIs
└── Tests + Responsive
```

### 6.3 Checklist qualite

- [ ] Performance: First Contentful Paint < 1.5s
- [ ] Accessibilite: Score Lighthouse > 90
- [ ] Responsive: Teste sur mobile, tablet, desktop
- [ ] Dark mode: Support optionnel
- [ ] Internationalisation: Formats dates/nombres FR
- [ ] Error handling: Etats vides et erreurs
- [ ] Loading states: Skeletons sur tous les composants
- [ ] Cache: React Query avec stale time configure
- [ ] Charts: Animations fluides, tooltips informatifs

---

## Annexes

### A. Requetes SQL utiles

```sql
-- Dashboard direction complet
SELECT * FROM gold.v_dashboard_direction
WHERE societe = 'DURET ELECTRICITE SAS';

-- Top 10 affaires par CA
SELECT * FROM gold.v_suivi_affaires
ORDER BY montant_commande DESC
LIMIT 10;

-- Alertes stock critiques
SELECT * FROM gold.v_alertes_stock
WHERE alerte = 'RUPTURE IMMINENTE';

-- Segmentation clients
SELECT
    segment_valeur,
    COUNT(*) as nb_clients,
    ROUND(AVG(ca_12m)::numeric, 2) as ca_moyen,
    ROUND(AVG(score_rfm)::numeric, 1) as rfm_moyen
FROM gold.ml_features_client
GROUP BY segment_valeur
ORDER BY ca_moyen DESC;
```

### B. Icones recommandees (Lucide)

| Section | Icone |
|---------|-------|
| Vue d'ensemble | `LayoutDashboard` |
| Commercial | `TrendingUp` |
| Affaires | `Briefcase` |
| RH | `Users` |
| Tresorerie | `Wallet` |
| Stocks | `Package` |
| Intelligence | `Brain` |
| Alertes | `AlertTriangle` |
| Parametres | `Settings` |

---

*Document genere pour le projet Groupe DURET - Dashboard DWH*

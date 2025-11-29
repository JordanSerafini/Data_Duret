# Rapport d'Audit - Dashboard Data-Driven & Anomaly Detection

**Date**: 29 novembre 2025
**Projet**: DWH Groupe DURET
**Version**: 1.0

---

## 1. DIAGNOSTIC DE L'ETAT ACTUEL

### 1.1 Etat des donnees Gold Layer

| Table | Lignes | Statut | Probleme |
|-------|--------|--------|----------|
| agg_ca_periode | 18 | OK | Donnees presentes |
| agg_ca_client | 40 | OK | Donnees presentes |
| agg_ca_affaire | 50 | OK | Donnees presentes |
| agg_tresorerie | 10 | PARTIEL | Donnees limitees |
| agg_heures_affaire | 200 | OK | Donnees presentes |
| agg_heures_salarie | 360 | OK | Donnees presentes |
| agg_stock_element | 993 | OK | Donnees presentes |
| **kpi_global** | 4 | **KO** | Toutes valeurs a 0.00 |
| **ml_features_client** | 158 | **KO** | ca_12m=0, tous DORMANT |
| ml_features_affaire | 50 | OK | Donnees presentes |
| anomalie_detectee | 126 | OK | Anomalies detectees |

### 1.2 Problemes critiques identifies

1. **kpi_global**: L'ETL Gold ne calcule pas correctement les KPIs
   - CA mensuel, cumul, marge: tout a 0.00
   - Cause: Jointures incorrectes ou dates non alignees

2. **ml_features_client**: Features ML vides
   - ca_12m = 0 pour tous les clients
   - Tous classifies comme "DORMANT" avec churn=80%
   - Cause: Les requetes de calcul ne trouvent pas les factures clients

3. **Anomalies detectees**: 126 anomalies de type ECART_MARGE_IMPORTANT
   - Taux marge reel = 100% (anormal)
   - Cause: Donnees de cout non chargees

---

## 2. BENCHMARK ML/ANOMALIE DETECTION - MEILLEURES PRATIQUES 2024-2025

### 2.1 Algorithmes recommandes par cas d'usage

#### Detection de fraude comptable
| Algorithme | Precision | Cas d'usage | Complexite |
|------------|-----------|-------------|------------|
| **Isolation Forest** | 85-92% | Transactions anormales | Faible |
| **Autoencoder** | 88-95% | Patterns d'ecritures | Moyenne |
| **Random Forest** | 90-95% | Classification supervisee | Faible |
| **LSTM** | 92-97% | Series temporelles | Haute |
| **XGBoost** | 91-96% | Scoring risque | Moyenne |

#### Segmentation clients (RFM+)
| Methode | Application |
|---------|-------------|
| K-Means clustering | Segmentation initiale |
| DBSCAN | Detection outliers |
| Hierarchical clustering | Analyse fine |
| RFM Score | Scoring comportemental |

### 2.2 KPIs data-driven recommandes

#### Finance / Tresorerie
- **DSO (Days Sales Outstanding)**: Delai moyen de paiement
- **DPO (Days Payable Outstanding)**: Delai paiement fournisseurs
- **BFR (Besoin en Fonds de Roulement)**: Tresorerie operationnelle
- **Score Z-Altman**: Risque de defaut
- **Ratio de liquidite**: Capacite a honorer dettes CT

#### Commercial / Clients
- **CLV (Customer Lifetime Value)**: Valeur client predite
- **Churn Probability**: Risque d'attrition (ML)
- **Score RFM**: Recence/Frequence/Montant
- **Elasticite prix**: Sensibilite aux variations
- **NPS predit**: Satisfaction estimee

#### Operations / Affaires
- **EVM (Earned Value Management)**: Avancement reel vs prevu
- **CPI (Cost Performance Index)**: Performance cout
- **SPI (Schedule Performance Index)**: Performance planning
- **Risk Score**: Score de risque depassement (ML)
- **Marge predite**: Marge finale estimee (ML)

#### RH / Productivite
- **Taux productif**: Heures productives / Total
- **Cout MO par affaire**: Ventilation analytique
- **Sous-occupation**: Detection temps non alloue
- **Competences critiques**: Gap analysis

### 2.3 Types d'anomalies a detecter

| Categorie | Type | Methode detection | Severite |
|-----------|------|-------------------|----------|
| **Comptabilite** | Ecritures anormales | Isolation Forest | CRITIQUE |
| | Doublons factures | Regles SQL | HAUTE |
| | Ecarts lettrage | Regles metier | MOYENNE |
| **Tresorerie** | Impaye > 90j | Seuil + Trend | CRITIQUE |
| | DSO anormal | Anomaly detection | HAUTE |
| | Variation brutale | CUSUM/EWMA | HAUTE |
| **Commercial** | Churn probable | Random Forest | CRITIQUE |
| | Baisse CA soudaine | Trend analysis | HAUTE |
| | Devis non convertis | Funnel analysis | MOYENNE |
| **Affaires** | Depassement budget | ML prediction | CRITIQUE |
| | Retard planning | EVM | HAUTE |
| | Marge negative | Seuil | CRITIQUE |
| **Stock** | Rupture imminente | Prevision ML | CRITIQUE |
| | Surstock | Rotation analysis | MOYENNE |
| | Obsolescence | Age + Rotation | HAUTE |

---

## 3. ARCHITECTURE CIBLE PROPOSEE

### 3.1 Couche ML dans le DWH

```
Silver Layer                    Gold Layer                      Presentation
(Faits/Dimensions)              (Features/Scores)               (API/Dashboard)
     |                               |                               |
     v                               v                               v
fact_document_commercial  -->  ml_features_client  ----------->  /api/ml/clients
     |                               |                               |
     |                         - ca_12m, ca_6m, ca_3m               |
     |                         - score_rfm                          |
     |                         - probabilite_churn                  |
     |                         - segment_valeur                     |
     |                               |                               |
fact_ecriture_compta     -->  ml_features_affaire  ----------->  /api/ml/affaires
     |                               |                               |
     |                         - risque_depassement_score           |
     |                         - marge_predite_pct                  |
     |                         - retard_predit_jours                |
     |                               |                               |
fact_suivi_mo            -->  anomalie_detectee  ------------->  /api/anomalies
                                     |                               |
                               - type_anomalie                       |
                               - severite                            |
                               - contexte JSON                       |
```

### 3.2 Dashboard data-driven

```
+------------------------------------------------------------------+
|                    DASHBOARD DIRECTION                            |
+------------------------------------------------------------------+
|  [ALERTE CRITIQUE: 5]    [ALERTE HAUTE: 12]    [MOYENNE: 23]     |
+------------------------------------------------------------------+
|                                                                   |
|  +------------------+  +------------------+  +------------------+ |
|  | CA & Marge       |  | Tresorerie       |  | Affaires        | |
|  | - CA mois: 450K  |  | - BFR: 125K      |  | - En cours: 42  | |
|  | - Marge: 23.5%   |  | - DSO: 45j       |  | - Retard: 8     | |
|  | - Trend: +5.2%   |  | - Risque: MOYEN  |  | - A risque: 5   | |
|  +------------------+  +------------------+  +------------------+ |
|                                                                   |
|  +--------------------------------------------------------------+|
|  | TOP ANOMALIES (Temps reel)                                    ||
|  |--------------------------------------------------------------|||
|  | CRITIQUE | Client DUPONT SA | Churn 87% | Action requise     ||
|  | CRITIQUE | AFF2025-042      | Depasse +35% budget            ||
|  | HAUTE    | Stock REF-A123   | Rupture dans 3 jours           ||
|  | HAUTE    | Client MARTIN    | Impaye 95 jours - 45K EUR      ||
|  +--------------------------------------------------------------+|
|                                                                   |
|  +-------------------------------+  +---------------------------+ |
|  | SEGMENTATION CLIENTS (ML)    |  | PREDICTION MARGE AFFAIRES | |
|  | [Pie chart: VIP/A/B/C/DORMANT]|  | [Scatter: predit vs reel] | |
|  +-------------------------------+  +---------------------------+ |
+------------------------------------------------------------------+
```

---

## 4. PLAN D'ACTION

### Phase 1: Correction donnees (1-2 jours)

#### 1.1 Corriger ETL kpi_global
```sql
-- Recalculer kpi_global avec jointures correctes
-- Le probleme est que les dates ne matchent pas
UPDATE gold.kpi_global k
SET
  kpi_ca_mensuel = (
    SELECT COALESCE(SUM(montant_facture), 0)
    FROM gold.agg_ca_periode p
    WHERE p.societe_sk = k.societe_sk
      AND p.annee = k.annee AND p.mois = k.mois
  ),
  ...
```

#### 1.2 Corriger ETL ml_features_client
```sql
-- Le probleme: ca_12m = 0 car jointure client_sk echoue
-- Solution: utiliser mde_code correctement
UPDATE gold.ml_features_client f
SET
  ca_12m = (
    SELECT COALESCE(SUM(dc.ca_total), 0)
    FROM gold.agg_ca_client dc
    JOIN silver.dim_client c ON dc.client_sk = c.client_sk
    WHERE c.client_sk = f.client_sk
  ),
  ...
```

### Phase 2: Implementation ML basique (3-5 jours)

#### 2.1 Score Churn client (SQL)
```sql
-- Calcul probabilite churn basee sur:
-- - Recence derniere commande
-- - Tendance CA (regression lineaire)
-- - Variation frequence commande
CREATE OR REPLACE FUNCTION gold.calculate_churn_score(
  recence_jours INT,
  tendance_ca DECIMAL,
  variation_freq DECIMAL
) RETURNS DECIMAL AS $$
BEGIN
  RETURN
    0.4 * LEAST(recence_jours / 365.0, 1.0) +  -- 40% poids recence
    0.3 * GREATEST(-tendance_ca / 100.0, 0) +   -- 30% poids tendance
    0.3 * GREATEST(-variation_freq, 0);          -- 30% poids frequence
END;
$$ LANGUAGE plpgsql;
```

#### 2.2 Score risque depassement affaire (SQL)
```sql
-- Calcul score risque basee sur:
-- - Avancement heures vs budget
-- - Historique affaires similaires
-- - Complexite affaire
CREATE OR REPLACE FUNCTION gold.calculate_risk_score(
  pct_heures_consomme DECIMAL,
  pct_avancement DECIMAL,
  marge_actuelle DECIMAL,
  marge_prevue DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
  ratio_avancement DECIMAL;
  ecart_marge DECIMAL;
BEGIN
  ratio_avancement := CASE WHEN pct_avancement > 0
    THEN pct_heures_consomme / pct_avancement
    ELSE 1.5 END;
  ecart_marge := GREATEST(marge_prevue - marge_actuelle, 0);

  RETURN LEAST(
    30 * GREATEST(ratio_avancement - 1, 0) +  -- Penalite heures
    40 * (ecart_marge / 10) +                   -- Penalite marge
    30 * CASE WHEN pct_heures_consomme > 80 AND pct_avancement < 60
           THEN 1 ELSE 0 END,                  -- Alerte critique
    100
  );
END;
$$ LANGUAGE plpgsql;
```

### Phase 3: Detection anomalies avancee (1 semaine)

#### 3.1 Regles de detection automatiques
```sql
-- Table des regles de detection
INSERT INTO audit.data_quality_rules (rule_name, rule_type, layer, severity, rule_query) VALUES
-- Anomalies comptables
('Ecriture montant anormal', 'ANOMALY', 'silver', 'HIGH',
 'SELECT * FROM silver.fact_ecriture_compta WHERE ABS(montant_credit - montant_debit) > (SELECT AVG(ABS(montant_credit)) * 3 FROM silver.fact_ecriture_compta)'),

-- Anomalies commerciales
('CA client chute brutale', 'TREND', 'gold', 'CRITICAL',
 'SELECT * FROM gold.ml_features_client WHERE tendance_ca = ''BAISSE_FORTE'' AND ca_12m > 50000'),

-- Anomalies tresorerie
('DSO anormal', 'THRESHOLD', 'gold', 'HIGH',
 'SELECT * FROM gold.agg_balance_agee_client WHERE dso_jours > 90'),

-- Anomalies RH
('Heures non affectees', 'RATIO', 'silver', 'MEDIUM',
 'SELECT * FROM silver.fact_suivi_mo WHERE affaire_sk IS NULL');
```

### Phase 4: Enrichissement frontend (1 semaine)

#### 4.1 Nouveaux composants dashboard
- **AlertBanner**: Barre d'alertes critiques temps reel
- **AnomalyTimeline**: Timeline des anomalies detectees
- **RiskHeatmap**: Carte de chaleur risque clients/affaires
- **PredictionChart**: Graphiques predictions ML
- **SegmentationView**: Visualisation segments clients

#### 4.2 API endpoints a creer/ameliorer
| Endpoint | Description | Priorite |
|----------|-------------|----------|
| GET /api/anomalies/realtime | Anomalies temps reel | P0 |
| GET /api/kpi/dashboard | KPIs consolides | P0 |
| GET /api/ml/predictions/summary | Resume predictions ML | P1 |
| GET /api/alerts/critical | Alertes critiques | P0 |
| POST /api/anomalies/:id/acknowledge | Acquitter anomalie | P1 |

---

## 5. METRIQUES DE SUCCES

### KPIs du projet
| Metrique | Actuel | Cible | Delai |
|----------|--------|-------|-------|
| Tables Gold avec donnees | 70% | 100% | J+2 |
| KPIs calcules correctement | 0% | 100% | J+3 |
| Features ML fonctionnelles | 30% | 100% | J+5 |
| Detection anomalies actives | 1 type | 8 types | J+10 |
| Dashboard alertes temps reel | Non | Oui | J+15 |

### KPIs metier attendus
- Detection anomalies dans l'heure vs J+1 actuellement
- Reduction impaye > 90j de 20%
- Prediction churn client a 80%+ de precision
- Detection depassement budget affaire a J+15 vs J+30

---

## 6. PROCHAINES ETAPES IMMEDIATES

1. **Aujourd'hui**:
   - [ ] Corriger ETL kpi_global (script 14)
   - [ ] Corriger ETL ml_features_client (script 14)
   - [ ] Tester recalcul complet

2. **Demain**:
   - [ ] Implementer score churn SQL
   - [ ] Implementer score risque affaire SQL
   - [ ] Ajouter regles detection anomalies

3. **Cette semaine**:
   - [ ] Ajouter composants alertes frontend
   - [ ] Creer vue dashboard consolidee
   - [ ] Tests end-to-end

---

**Auteur**: Claude AI
**Validation**: En attente

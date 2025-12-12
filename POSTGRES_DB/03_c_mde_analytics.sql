-- ============================================================================
-- MDE ERP - ANALYTICS & MATERIALIZED VIEWS
-- Objectif : Performance Dashboard & ML Features
-- ============================================================================

\c mde_erp;

CREATE SCHEMA IF NOT EXISTS analytics;

-- 1. ANALYSE RENTABILITE CHANTIER (TEMPS REEL)
-- ============================================================================
-- Vu que le calcul de marge des chantiers est complexe (MO + Fourniture + SST + Frais),
-- on materialise le resultat pour affichage instantane dashboard.

CREATE MATERIALIZED VIEW analytics.mvi_synthese_chantier_financier AS
WITH facturation AS (
    SELECT 
        chantier_id,
        SUM(montant_net_ht) as ca_facture,
        MAX(date_document) as derniere_facture
    FROM document.entete_document
    WHERE type_document = 'FACTURE'
    GROUP BY chantier_id
),
couts_mo AS (
    SELECT 
        chantier_id,
        SUM(heures_normales * 35.00) as cout_estime_mo -- Taux moyen fixe pour l'instant
    FROM chantier.suivi_mo
    GROUP BY chantier_id
),
couts_fournitures AS (
    SELECT 
        chantier_id,
        SUM(montant_total) as cout_materiel
    FROM stock.mouvement
    WHERE chantier_id IS NOT NULL 
    AND type_mvt = 'SORTIE'
    GROUP BY chantier_id
)
SELECT 
    c.id as chantier_id,
    c.code,
    c.intitule,
    c.etat,
    -- Revenus
    COALESCE(f.ca_facture, 0) as ca_facture,
    -- Coûts
    COALESCE(cm.cout_estime_mo, 0) as cout_mo,
    COALESCE(cf.cout_materiel, 0) as cout_fournitures,
    (COALESCE(cm.cout_estime_mo, 0) + COALESCE(cf.cout_materiel, 0)) as cout_total_estime,
    -- Marges
    (COALESCE(f.ca_facture, 0) - (COALESCE(cm.cout_estime_mo, 0) + COALESCE(cf.cout_materiel, 0))) as marge_estimee,
    CASE 
        WHEN COALESCE(f.ca_facture, 0) > 0 THEN 
            ROUND(((COALESCE(f.ca_facture, 0) - (COALESCE(cm.cout_estime_mo, 0) + COALESCE(cf.cout_materiel, 0))) / f.ca_facture * 100), 2)
        ELSE 0 
    END as taux_marge_pct,
    NOW() as derived_at
FROM chantier.chantier c
LEFT JOIN facturation f ON f.chantier_id = c.id
LEFT JOIN couts_mo cm ON cm.chantier_id = c.id
LEFT JOIN couts_fournitures cf ON cf.chantier_id = c.id
WHERE c.etat IN ('EN_COURS', 'TERMINE');

CREATE INDEX idx_mvi_chantier_marge ON analytics.mvi_synthese_chantier_financier(marge_estimee);


-- 2. RECOMMENDER SYSTEM : BASKET ANALYSIS (ML PREP)
-- ============================================================================
-- Analyse des co-occurrences d'articles dans les devis acceptes
-- Permet de dire: "Pour ce chantier, vous avez oublie les vis ?"

CREATE MATERIALIZED VIEW analytics.mvi_basket_analysis AS
WITH pairs AS (
    SELECT 
        t1.element_id as item_a,
        t2.element_id as item_b,
        COUNT(*) as frequency
    FROM document.ligne_document t1
    JOIN document.ligne_document t2 ON t1.entete_id = t2.entete_id AND t1.element_id < t2.element_id
    JOIN document.entete_document d ON t1.entete_id = d.id
    WHERE d.type_document = 'DEVIS' AND d.etat_id IN (SELECT id FROM ref.etat_document WHERE code = 'D_ACC')
    GROUP BY t1.element_id, t2.element_id
)
SELECT 
    p.item_a,
    ea.designation as designation_a,
    p.item_b,
    eb.designation as designation_b,
    p.frequency,
    RANK() OVER (PARTITION BY p.item_a ORDER BY p.frequency DESC) as rank_reco
FROM pairs p
JOIN ref.element ea ON p.item_a = ea.id
JOIN ref.element eb ON p.item_b = eb.id
WHERE p.frequency > 2; -- Filtre bruit

CREATE INDEX idx_mvi_basket_a ON analytics.mvi_basket_analysis(item_a);


-- 3. HISTORIQUE PRIX FOURNISSEURS (DATA INTELLIGENCE)
-- ============================================================================
-- Vue pour tracker l'inflation des materiaux
CREATE VIEW analytics.v_evolution_prix_materiaux AS
SELECT 
    e.id as element_id,
    e.code,
    e.designation,
    ld.prix_achat_snapshot,
    d.date_document,
    EXTRACT(YEAR FROM d.date_document) as annee,
    EXTRACT(MONTH FROM d.date_document) as mois
FROM document.ligne_document ld
JOIN document.entete_document d ON ld.entete_id = d.id
JOIN ref.element e ON ld.element_id = e.id
WHERE d.type_document = 'COMMANDE' -- Commandes fournisseurs
AND ld.prix_achat_snapshot > 0;


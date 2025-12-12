-- VERIFICATION SCRIPT
\c mde_erp;

-- 1. Check Addresses Migration
SELECT count(*) as adresses_migrated FROM tiers.adresse;

-- 2. Check Margin Snapshots
SELECT count(*) as items_with_snapshot 
FROM document.ligne_document 
WHERE prix_achat_snapshot > 0;

-- 3. Check Analytics View
REFRESH MATERIALIZED VIEW analytics.mvi_synthese_chantier_financier;
SELECT count(*) as chantiers_with_marge 
FROM analytics.mvi_synthese_chantier_financier;

-- 4. Check Data Content
SELECT * FROM analytics.mvi_synthese_chantier_financier LIMIT 5;

-- ============================================================================
-- FIX DATA WAREHOUSE INTEGRITY
-- Enforce missing Foreign Keys detected during Audit Phase 10
-- ============================================================================

-- \c mde_erp; -- Ensure we are in the right database

BEGIN;

-- 1. SILVER LAYER : Link Products to Suppliers
-- Risk: A product referencing a non-existent supplier triggers dataviz errors
\echo 'Adding FK: silver.dim_element(fournisseur_principal_sk) -> silver.dim_fournisseur'
ALTER TABLE silver.dim_element
    ADD CONSTRAINT fk_element_fournisseur
    FOREIGN KEY (fournisseur_principal_sk)
    REFERENCES silver.dim_fournisseur(fournisseur_sk);

-- 2. SILVER LAYER : Link Invoices to Quotes (Lineage)
-- Risk: Broken document chain analysis
\echo 'Adding FK: silver.fact_document_commercial(document_origine_sk) -> self'
ALTER TABLE silver.fact_document_commercial
    ADD CONSTRAINT fk_document_origine
    FOREIGN KEY (document_origine_sk)
    REFERENCES silver.fact_document_commercial(document_sk);

-- 3. GOLD LAYER : Link ML Features to Cloud Reference
-- Risk: ML model training on invalid geographic codes (e.g. '999')
\echo 'Adding FK: gold.ml_features_affaire(departement) -> silver.ref_departement'
ALTER TABLE gold.ml_features_affaire
    ADD CONSTRAINT fk_ml_affaire_departement
    FOREIGN KEY (departement)
    REFERENCES silver.ref_departement(code);

COMMIT;

\echo 'DWH Integrity Fixes applied successfully.'

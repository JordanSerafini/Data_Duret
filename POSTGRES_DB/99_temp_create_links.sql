-- ============================================================================
-- VERIFICATION DATA POPULATION (BRONZE LAYER)
-- ============================================================================

-- 1. Link Factures to Random Devis
UPDATE bronze.mde_document_entete
SET document_origine_id = (
    SELECT _source_id FROM bronze.mde_document_entete d2 
    WHERE d2.type_document = 'DEVIS' 
    ORDER BY RANDOM() LIMIT 1
)
WHERE type_document = 'FACTURE';

-- 2. Link Elements to Random Fournisseurs
-- Need to find supplier IDs from bronze.mde_fournisseur? 
-- Is there a bronze.mde_fournisseur? Yes likely.
-- Let's check if bronze.mde_fournisseur exists.
-- If not, we can't link easily.
-- Assuming bronze.mde_fournisseur exists (implied by load_dim_fournisseur).
-- Wait, load_dim_fournisseur reads from bronze.mde_fournisseur?
-- Let's check 09_dwh_etl_bronze_silver.sql for load_dim_fournisseur source.
-- It reads from bronze.mde_fournisseur.

UPDATE bronze.mde_element
SET fournisseur_principal_id = (
    SELECT _source_id FROM bronze.mde_fournisseur 
    ORDER BY RANDOM() LIMIT 1
);

-- 3. Check Counts
SELECT 'Linked Factures (Bronze)' as type, count(*) FROM bronze.mde_document_entete WHERE document_origine_id IS NOT NULL;
SELECT 'Linked Elements (Bronze)' as type, count(*) FROM bronze.mde_element WHERE fournisseur_principal_id IS NOT NULL;

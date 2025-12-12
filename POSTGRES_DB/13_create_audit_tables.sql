-- ============================================================================
-- AUDIT SCHEMA TABLES
-- Description: Creation des tables manquantes pour le module Audit/Qualite
-- ============================================================================

-- 1. Table des regles de qualite (Manquante)
CREATE TABLE IF NOT EXISTS audit.data_quality_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(100) NOT NULL,
    rule_description TEXT,
    layer VARCHAR(20) NOT NULL CHECK (layer IN ('BRONZE', 'SILVER', 'GOLD')),
    table_name VARCHAR(100) NOT NULL,
    check_type VARCHAR(50) NOT NULL, -- 'NULL_CHECK', 'FK_CHECK', 'RANGE_CHECK', 'PATTERN_CHECK'
    check_query TEXT NOT NULL,
    threshold_value NUMERIC(15,4),
    severity VARCHAR(20) DEFAULT 'WARNING' CHECK (severity IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Insertion de regles par defaut
INSERT INTO audit.data_quality_rules (rule_name, rule_description, layer, table_name, check_type, check_query, severity) VALUES
-- Regles BRONZE (Integrite brute)
('CHECK_CLIENT_SIRET', 'Verifier que le SIRET est present pour les clients', 'BRONZE', 'mde_client', 'NULL_CHECK', 'SELECT count(*) FROM bronze.mde_client WHERE siret IS NULL', 'WARNING'),
('CHECK_AFFAIRE_CLIENT', 'Verifier que chaque affaire a un client', 'BRONZE', 'mde_affaire', 'FK_CHECK', 'SELECT count(*) FROM bronze.mde_affaire WHERE client_id IS NULL', 'ERROR'),

-- Regles SILVER (Integrite referentielle et metier)
('CHECK_FACT_DOC_LINKS', 'Verifier que les factures sont liees a un devis', 'SILVER', 'fact_document_commercial', 'FK_CHECK', 'SELECT count(*) FROM silver.fact_document_commercial WHERE type_document = ''FACTURE'' AND document_origine_sk IS NULL', 'WARNING'),
('CHECK_ELEM_FOURNISSEUR', 'Verifier que les articles ont un fournisseur principal', 'SILVER', 'dim_element', 'FK_CHECK', 'SELECT count(*) FROM silver.dim_element WHERE fournisseur_principal_sk IS NULL', 'WARNING'),

-- Regles GOLD (Coherence analytique)
('CHECK_CA_POSITIF', 'Verifier que le CA est positif', 'GOLD', 'agg_ca_client', 'RANGE_CHECK', 'SELECT count(*) FROM gold.agg_ca_client WHERE montant_ht < 0', 'ERROR'),
('CHECK_ML_FEATURES', 'Verifier la presence de features ML', 'GOLD', 'ml_features_affaire', 'NULL_CHECK', 'SELECT count(*) FROM gold.ml_features_affaire WHERE marge_reelle_pct IS NULL', 'WARNING');

-- 3. Grant permissions (Si necessaire, depend de l'utilisateur qui lance)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit TO postgres;

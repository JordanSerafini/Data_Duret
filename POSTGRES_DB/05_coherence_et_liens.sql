-- ============================================================================
-- SCRIPTS DE COHERENCE INTER-BASES
-- Liens entre SAGE Comptabilite et MDE ERP
-- ============================================================================

-- Ce script cree des vues et fonctions pour assurer la coherence
-- entre les deux bases de donnees dans le cadre de la future integration

-- ============================================================================
-- 1. TABLES DE CORRESPONDANCE (dans sage_compta)
-- ============================================================================

\c sage_compta;

-- Table de mapping entre les tiers MDE et les comptes tiers SAGE
CREATE TABLE IF NOT EXISTS ref.mapping_tiers_mde (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    type_tiers VARCHAR(20) NOT NULL, -- CLIENT, FOURNISSEUR, SOUS_TRAITANT
    code_mde VARCHAR(20) NOT NULL,
    code_sage VARCHAR(17) NOT NULL,
    compte_collectif VARCHAR(13),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actif BOOLEAN DEFAULT TRUE,
    UNIQUE(societe_id, type_tiers, code_mde)
);

-- Table de mapping des affaires MDE vers codes analytiques SAGE
CREATE TABLE IF NOT EXISTS ref.mapping_affaire_analytique (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    code_affaire_mde VARCHAR(20) NOT NULL,
    code_analytique_sage VARCHAR(13) NOT NULL,
    axe_analytique INTEGER DEFAULT 1,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(societe_id, code_affaire_mde)
);

-- Journal des transferts comptables
CREATE TABLE IF NOT EXISTS compta.journal_transfert_mde (
    id BIGSERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    -- Source MDE
    type_document_mde VARCHAR(20) NOT NULL,
    numero_document_mde VARCHAR(20) NOT NULL,
    date_document_mde DATE NOT NULL,
    -- Destination SAGE
    journal_sage VARCHAR(6),
    piece_sage VARCHAR(20),
    date_piece_sage DATE,
    -- Montants
    montant_ht NUMERIC(15,2),
    montant_tva NUMERIC(15,2),
    montant_ttc NUMERIC(15,2),
    -- Statut
    statut VARCHAR(20) DEFAULT 'EN_ATTENTE', -- EN_ATTENTE, TRANSFERE, ERREUR, ANNULE
    message_erreur TEXT,
    -- Tracabilite
    date_transfert TIMESTAMP,
    utilisateur VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_journal_transfert_statut ON compta.journal_transfert_mde(statut);
CREATE INDEX idx_journal_transfert_date ON compta.journal_transfert_mde(date_document_mde);

-- ============================================================================
-- 2. FONCTIONS DE TRANSFERT
-- ============================================================================

-- Fonction pour generer les ecritures comptables a partir d'une facture MDE
CREATE OR REPLACE FUNCTION compta.generer_ecritures_facture_mde(
    p_societe_id INTEGER,
    p_type_document VARCHAR(20),
    p_numero_document VARCHAR(20),
    p_date_document DATE,
    p_code_tiers VARCHAR(20),
    p_type_tiers VARCHAR(20),
    p_montant_ht NUMERIC(15,2),
    p_montant_tva NUMERIC(15,2),
    p_code_affaire VARCHAR(20) DEFAULT NULL
) RETURNS INTEGER AS $$
DECLARE
    v_piece_id INTEGER;
    v_journal_id INTEGER;
    v_compte_tiers_id INTEGER;
    v_compte_vente_id INTEGER;
    v_compte_tva_id INTEGER;
    v_compte_tiers VARCHAR(13);
    v_code_analytique VARCHAR(13);
    v_exercice_id INTEGER;
    v_numero_piece VARCHAR(20);
BEGIN
    -- Determiner le journal
    SELECT id INTO v_journal_id
    FROM compta.journal
    WHERE societe_id = p_societe_id
      AND type_journal = CASE WHEN p_type_tiers = 'CLIENT' THEN 'VENTE' ELSE 'ACHAT' END
    LIMIT 1;

    -- Determiner l'exercice
    SELECT id INTO v_exercice_id
    FROM ref.exercice
    WHERE societe_id = p_societe_id
      AND p_date_document BETWEEN date_debut AND date_fin
      AND cloture = FALSE
    LIMIT 1;

    -- Recuperer le compte tiers
    SELECT code_sage INTO v_compte_tiers
    FROM ref.mapping_tiers_mde
    WHERE societe_id = p_societe_id
      AND type_tiers = p_type_tiers
      AND code_mde = p_code_tiers;

    -- Recuperer le code analytique si affaire fournie
    IF p_code_affaire IS NOT NULL THEN
        SELECT code_analytique_sage INTO v_code_analytique
        FROM ref.mapping_affaire_analytique
        WHERE societe_id = p_societe_id
          AND code_affaire_mde = p_code_affaire;
    END IF;

    -- Generer le numero de piece
    v_numero_piece := p_type_document || '-' || p_numero_document;

    -- Creer la piece
    INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, reference_origine)
    VALUES (p_societe_id, v_exercice_id, v_journal_id, v_numero_piece, p_date_document, 'Import MDE ' || p_type_document, 'BROUILLARD', 'MDE', p_numero_document)
    RETURNING id INTO v_piece_id;

    -- Recuperer les comptes
    SELECT id INTO v_compte_tiers_id FROM compta.compte_general WHERE societe_id = p_societe_id AND numero = '411000' LIMIT 1;
    SELECT id INTO v_compte_vente_id FROM compta.compte_general WHERE societe_id = p_societe_id AND numero = '704100' LIMIT 1;
    SELECT id INTO v_compte_tva_id FROM compta.compte_general WHERE societe_id = p_societe_id AND numero = '445710' LIMIT 1;

    IF p_type_tiers = 'CLIENT' THEN
        -- Ecriture client (debit)
        INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
        VALUES (v_piece_id, 1, p_date_document, v_compte_tiers_id, '411000', 'Facture ' || p_numero_document, p_numero_document, p_montant_ht + p_montant_tva, 0);

        -- Ecriture vente (credit)
        INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
        VALUES (v_piece_id, 2, p_date_document, v_compte_vente_id, '704100', 'Facture ' || p_numero_document, p_numero_document, 0, p_montant_ht);

        -- Ecriture TVA (credit)
        INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
        VALUES (v_piece_id, 3, p_date_document, v_compte_tva_id, '445710', 'TVA Facture ' || p_numero_document, p_numero_document, 0, p_montant_tva);
    END IF;

    -- Enregistrer dans le journal de transfert
    INSERT INTO compta.journal_transfert_mde (societe_id, type_document_mde, numero_document_mde, date_document_mde, journal_sage, piece_sage, date_piece_sage, montant_ht, montant_tva, montant_ttc, statut, date_transfert)
    VALUES (p_societe_id, p_type_document, p_numero_document, p_date_document, (SELECT code FROM compta.journal WHERE id = v_journal_id), v_numero_piece, p_date_document, p_montant_ht, p_montant_tva, p_montant_ht + p_montant_tva, 'TRANSFERE', CURRENT_TIMESTAMP);

    RETURN v_piece_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. VUES DE RECONCILIATION
-- ============================================================================

-- Vue des ecarts entre CA MDE et CA comptable
CREATE OR REPLACE VIEW compta.v_ecarts_ca_mde_compta AS
WITH ca_compta AS (
    SELECT
        EXTRACT(YEAR FROM p.date_piece) AS annee,
        EXTRACT(MONTH FROM p.date_piece) AS mois,
        SUM(CASE WHEN e.credit > 0 AND cg.numero LIKE '70%' THEN e.credit ELSE 0 END) AS ca_comptable
    FROM compta.ecriture e
    JOIN compta.piece p ON e.piece_id = p.id
    JOIN compta.compte_general cg ON e.compte_id = cg.id
    WHERE p.societe_id = 1
    GROUP BY EXTRACT(YEAR FROM p.date_piece), EXTRACT(MONTH FROM p.date_piece)
),
ca_mde AS (
    SELECT
        EXTRACT(YEAR FROM date_document_mde) AS annee,
        EXTRACT(MONTH FROM date_document_mde) AS mois,
        SUM(montant_ht) AS ca_mde
    FROM compta.journal_transfert_mde
    WHERE societe_id = 1 AND type_document_mde IN ('FACTURE', 'SITUATION')
    GROUP BY EXTRACT(YEAR FROM date_document_mde), EXTRACT(MONTH FROM date_document_mde)
)
SELECT
    COALESCE(cc.annee, cm.annee) AS annee,
    COALESCE(cc.mois, cm.mois) AS mois,
    COALESCE(cc.ca_comptable, 0) AS ca_comptable,
    COALESCE(cm.ca_mde, 0) AS ca_mde,
    COALESCE(cc.ca_comptable, 0) - COALESCE(cm.ca_mde, 0) AS ecart
FROM ca_compta cc
FULL OUTER JOIN ca_mde cm ON cc.annee = cm.annee AND cc.mois = cm.mois
ORDER BY annee, mois;

-- ============================================================================
-- 4. INSERTION DES MAPPINGS INITIAUX
-- ============================================================================

-- Mapping des clients (coherence avec MDE)
INSERT INTO ref.mapping_tiers_mde (societe_id, type_tiers, code_mde, code_sage, compte_collectif)
SELECT 1, 'CLIENT', 'C' || LPAD(ROW_NUMBER() OVER()::TEXT, 4, '0'), 'C' || LPAD(ROW_NUMBER() OVER()::TEXT, 4, '0'), '411000'
FROM generate_series(1, 150);

-- Mapping des fournisseurs
INSERT INTO ref.mapping_tiers_mde (societe_id, type_tiers, code_mde, code_sage, compte_collectif)
SELECT 1, 'FOURNISSEUR', 'F' || LPAD(ROW_NUMBER() OVER()::TEXT, 4, '0'), 'F' || LPAD(ROW_NUMBER() OVER()::TEXT, 4, '0'), '401000'
FROM generate_series(1, 80);

-- Mapping des affaires vers analytique
INSERT INTO ref.mapping_affaire_analytique (societe_id, code_affaire_mde, code_analytique_sage)
VALUES
(1, 'AFF2024-001', 'AFF2024001'),
(1, 'AFF2024-002', 'AFF2024002'),
(1, 'AFF2024-003', 'AFF2024003'),
(1, 'AFF2024-004', 'AFF2024004'),
(1, 'AFF2024-005', 'AFF2024005'),
(1, 'AFF2024-006', 'AFF2024006');

-- ============================================================================
-- 5. VUES CROSS-DATABASE (pour usage futur avec FDW)
-- ============================================================================

-- Note: Ces vues seraient utilisees avec postgres_fdw pour acceder a MDE depuis SAGE
-- CREATE EXTENSION IF NOT EXISTS postgres_fdw;
-- CREATE SERVER mde_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'mde_erp', port '5432');
-- CREATE USER MAPPING FOR current_user SERVER mde_server OPTIONS (user 'postgres', password 'xxx');

-- Vue consolidee des CA (structure pour future implementation)
CREATE OR REPLACE VIEW compta.v_ca_consolide AS
SELECT
    'SAGE' AS source,
    EXTRACT(YEAR FROM p.date_piece)::INTEGER AS annee,
    EXTRACT(MONTH FROM p.date_piece)::INTEGER AS mois,
    SUM(e.credit) AS montant
FROM compta.ecriture e
JOIN compta.piece p ON e.piece_id = p.id
JOIN compta.compte_general cg ON e.compte_id = cg.id
WHERE cg.numero LIKE '70%' AND e.credit > 0
GROUP BY EXTRACT(YEAR FROM p.date_piece), EXTRACT(MONTH FROM p.date_piece);

-- ============================================================================
-- 6. PROCEDURES DE CONTROLE
-- ============================================================================

-- Procedure de verification de coherence
CREATE OR REPLACE PROCEDURE compta.verifier_coherence_mde()
LANGUAGE plpgsql
AS $$
DECLARE
    v_nb_documents_non_transferes INTEGER;
    v_nb_ecarts INTEGER;
BEGIN
    -- Compter les documents en attente de transfert
    SELECT COUNT(*) INTO v_nb_documents_non_transferes
    FROM compta.journal_transfert_mde
    WHERE statut = 'EN_ATTENTE';

    IF v_nb_documents_non_transferes > 0 THEN
        RAISE NOTICE 'ATTENTION: % documents MDE en attente de transfert comptable', v_nb_documents_non_transferes;
    END IF;

    -- Verifier les ecarts CA
    SELECT COUNT(*) INTO v_nb_ecarts
    FROM compta.v_ecarts_ca_mde_compta
    WHERE ABS(ecart) > 0.01;

    IF v_nb_ecarts > 0 THEN
        RAISE NOTICE 'ATTENTION: % mois avec ecarts entre CA MDE et comptabilite', v_nb_ecarts;
    END IF;

    RAISE NOTICE 'Verification de coherence terminee';
END;
$$;

COMMENT ON PROCEDURE compta.verifier_coherence_mde IS 'Verifie la coherence entre les donnees MDE et la comptabilite SAGE';

-- ============================================================================
-- FIN DU SCRIPT DE COHERENCE
-- ============================================================================

\echo 'Scripts de coherence inter-bases installes avec succes'

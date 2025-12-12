-- ============================================================================
-- FIX SCHEMA ANOMALIES (AUDIT MDE)
-- Date: 12/12/2025
-- Description: Correctifs critiques d'integrité, structure et data-intelligence
-- ============================================================================

\c mde_erp;

-- 1. CORRECTION INTEGRITE REFERENTIELLE (MISSING FKs)
-- ============================================================================

-- Tiers: Lier Clients -> Charge d'affaires
ALTER TABLE tiers.client
    ADD CONSTRAINT fk_client_charge_affaire
    FOREIGN KEY (charge_affaire_id) REFERENCES tiers.charge_affaire(id);

-- Ref: Lier Bibliotheque -> Fournisseur
ALTER TABLE ref.bibliotheque
    ADD CONSTRAINT fk_biblio_fournisseur
    FOREIGN KEY (fournisseur_id) REFERENCES tiers.fournisseur(id);

-- Stock: Lier Mouvement -> Ligne Document (Tracabilite Vente)
ALTER TABLE stock.mouvement
    ADD CONSTRAINT fk_mvt_ligne_doc
    FOREIGN KEY (ligne_document_id) REFERENCES document.ligne_document(id);

-- Compta: Lier Transfert -> Ligne Document
ALTER TABLE compta.transfert_ligne
    ADD CONSTRAINT fk_transfert_ligne_doc
    FOREIGN KEY (ligne_document_id) REFERENCES document.ligne_document(id);


-- 2. DATA INTELLIGENCE & MARGES (SNAPSHOTS)
-- ============================================================================

-- Ajout du prix d'achat historique sur les lignes de vente
-- Indispensable pour calculer la marge reelle a une date T
ALTER TABLE document.ligne_document
    ADD COLUMN prix_achat_snapshot NUMERIC(15,4) DEFAULT 0,
    ADD COLUMN cout_revient_theorique NUMERIC(15,4) DEFAULT 0;

COMMENT ON COLUMN document.ligne_document.prix_achat_snapshot IS 'Prix achat unitaire au moment de la vente (fige)';

-- Mise a jour retroactive (Best Effort) pour les donnees existantes
-- On prend le PUMP actuel de l'article comme valeur par defaut
UPDATE document.ligne_document ld
SET prix_achat_snapshot = COALESCE(e.prix_achat, 0)
FROM ref.element e
WHERE ld.element_id = e.id;


-- 3. NORMALISATION ADRESSES (MULTI-SITES)
-- ============================================================================

CREATE TYPE tiers.type_adresse AS ENUM ('SIEGE', 'LIVRAISON', 'FACTURATION', 'CHANTIER', 'AUTRE');

CREATE TABLE tiers.adresse (
    id SERIAL PRIMARY KEY,
    societe_id INTEGER REFERENCES ref.societe(id),
    -- Liaison polymorphique (Client ou Fournisseur ou Autre)
    tiers_type ref.type_tiers NOT NULL,
    tiers_id INTEGER NOT NULL,
    
    type_adresse tiers.type_adresse DEFAULT 'AUTRE',
    libelle VARCHAR(100), -- Ex: "Depot Nord"
    
    adresse_ligne1 VARCHAR(100),
    adresse_ligne2 VARCHAR(100),
    code_postal VARCHAR(10),
    ville VARCHAR(50),
    pays_code VARCHAR(5) REFERENCES ref.pays(code),
    
    contact_nom VARCHAR(100),
    telephone VARCHAR(25),
    
    actif BOOLEAN DEFAULT TRUE,
    defaut BOOLEAN DEFAULT FALSE, -- Adresse par defaut pour ce type
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_adresse_tiers ON tiers.adresse(tiers_type, tiers_id);

-- Migration des adresses Clients existantes (Siège)
INSERT INTO tiers.adresse (societe_id, tiers_type, tiers_id, type_adresse, libelle, adresse_ligne1, adresse_ligne2, code_postal, ville, pays_code, telephone, defaut)
SELECT 
    societe_id, 
    'CLIENT', 
    id, 
    'SIEGE', 
    'Siege Social',
    adresse_ligne1, 
    adresse_ligne2, 
    code_postal, 
    ville, 
    pays_code, 
    telephone,
    TRUE
FROM tiers.client;

-- Migration des adresses Fournisseurs existantes
INSERT INTO tiers.adresse (societe_id, tiers_type, tiers_id, type_adresse, libelle, adresse_ligne1, adresse_ligne2, code_postal, ville, pays_code, telephone, defaut)
SELECT 
    societe_id, 
    'FOURNISSEUR', 
    id, 
    'SIEGE', 
    'Siege Social',
    adresse_ligne1, 
    adresse_ligne2, 
    code_postal, 
    ville, 
    pays_code, 
    telephone,
    TRUE
FROM tiers.fournisseur;

-- Note: On ne supprime pas encore les colonnes d'origine pour eviter de casser le code legacy immediatement,
-- mais on les marque comme DEPRECATED.
COMMENT ON COLUMN tiers.client.adresse_ligne1 IS 'DEPRECATED: Utiliser table tiers.adresse';


-- 4. OUVRAGES RECURSIFS (COMPOSITION)
-- ============================================================================

-- Permettre a une ligne de composition de pointer vers un autre Ouvrage
ALTER TABLE ref.ouvrage_composition
    ADD COLUMN composant_ouvrage_id INTEGER REFERENCES ref.ouvrage(id);

-- Contrainte: Soit un Element, soit un Ouvrage, pas les deux (XOR)
ALTER TABLE ref.ouvrage_composition
    ADD CONSTRAINT chk_composition_xor_type 
    CHECK (
        (element_id IS NOT NULL AND composant_ouvrage_id IS NULL) OR
        (element_id IS NULL AND composant_ouvrage_id IS NOT NULL)
    );

-- Mettre element_id en NULLABLE (etait implicitement nullable via create table standard sans not null, mais on s'assure)
ALTER TABLE ref.ouvrage_composition
    ALTER COLUMN element_id DROP NOT NULL;


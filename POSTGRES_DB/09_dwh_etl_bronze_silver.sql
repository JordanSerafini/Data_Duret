-- ============================================================================
-- ETL PROCEDURES : BRONZE -> SILVER
-- Transformation et chargement des donnees brutes vers les dimensions/faits
-- ============================================================================

-- \c dwh_groupe_duret;

-- ============================================================================
-- 1. PROCEDURES D'EXTRACTION BRONZE (depuis sources)
-- ============================================================================

-- Procedure generique pour enregistrer un job ETL
CREATE OR REPLACE FUNCTION etl.start_job(
    p_job_name VARCHAR(100),
    p_source_system VARCHAR(50),
    p_target_layer VARCHAR(20)
) RETURNS BIGINT AS $$
DECLARE
    v_job_id BIGINT;
BEGIN
    INSERT INTO etl.job_execution (job_name, source_system, target_layer, status)
    VALUES (p_job_name, p_source_system, p_target_layer, 'RUNNING')
    RETURNING id INTO v_job_id;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure pour terminer un job
CREATE OR REPLACE FUNCTION etl.end_job(
    p_job_id BIGINT,
    p_status VARCHAR(20),
    p_rows_inserted BIGINT DEFAULT 0,
    p_rows_updated BIGINT DEFAULT 0,
    p_error_message TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    UPDATE etl.job_execution
    SET end_time = CURRENT_TIMESTAMP,
        status = p_status,
        rows_inserted = p_rows_inserted,
        rows_updated = p_rows_updated,
        error_message = p_error_message
    WHERE id = p_job_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. ETL BRONZE -> SILVER : DIMENSIONS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 ETL Dimension Societe
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_societe()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_rows_updated INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_SOCIETE', 'SAGE_COMPTA', 'SILVER');

    -- Insertion des nouvelles societes
    INSERT INTO silver.dim_societe (
        societe_nk, source_system, source_id, code, raison_sociale,
        siret, adresse, code_postal, ville, departement, telephone,
        email, regime_tva, is_current, valid_from, row_hash
    )
    SELECT
        'SAGE:' || COALESCE(code, _source_id::TEXT),
        'SAGE_COMPTA',
        _source_id,
        code,
        raison_sociale,
        siret,
        adresse,
        code_postal,
        ville,
        silver.get_departement_from_cp(code_postal),
        telephone,
        email,
        regime_tva,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[code, raison_sociale, siret, adresse, code_postal, ville])
    FROM bronze.sage_societe b
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_societe s
        WHERE s.societe_nk = 'SAGE:' || COALESCE(b.code, b._source_id::TEXT)
        AND s.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- SCD Type 2 : Detection des changements
    WITH changed AS (
        SELECT
            s.societe_sk,
            b.*,
            silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse, b.code_postal, b.ville]) AS new_hash
        FROM bronze.sage_societe b
        JOIN silver.dim_societe s ON s.societe_nk = 'SAGE:' || COALESCE(b.code, b._source_id::TEXT)
        WHERE s.is_current = TRUE
        AND s.row_hash != silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse, b.code_postal, b.ville])
    )
    UPDATE silver.dim_societe s
    SET is_current = FALSE,
        valid_to = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP
    FROM changed c
    WHERE s.societe_sk = c.societe_sk;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    -- Inserer les nouvelles versions pour les changements
    INSERT INTO silver.dim_societe (
        societe_nk, source_system, source_id, code, raison_sociale,
        siret, adresse, code_postal, ville, departement, telephone,
        email, regime_tva, is_current, valid_from, row_hash
    )
    SELECT
        'SAGE:' || COALESCE(b.code, b._source_id::TEXT),
        'SAGE_COMPTA',
        b._source_id,
        b.code,
        b.raison_sociale,
        b.siret,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        b.telephone,
        b.email,
        b.regime_tva,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse, b.code_postal, b.ville])
    FROM bronze.sage_societe b
    JOIN silver.dim_societe s ON s.societe_nk = 'SAGE:' || COALESCE(b.code, b._source_id::TEXT)
    WHERE s.is_current = FALSE
    AND s.valid_to = CURRENT_TIMESTAMP
    AND s.row_hash != silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse, b.code_postal, b.ville]);

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, v_rows_updated);

    RAISE NOTICE 'LOAD_DIM_SOCIETE: % inserts, % updates', v_rows_inserted, v_rows_updated;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.2 ETL Dimension Client (fusion SAGE + MDE)
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_client()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
    v_rows_updated INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_CLIENT', 'ALL', 'SILVER');

    -- Insertion depuis SAGE
    INSERT INTO silver.dim_client (
        client_nk, source_system, source_id, societe_sk, code, raison_sociale,
        siret, tva_intracom, adresse, code_postal, ville, departement,
        telephone, email, mode_reglement, conditions_paiement, encours_max,
        sage_code, is_current, valid_from, row_hash
    )
    SELECT
        'SAGE:' || b.code,
        'SAGE_COMPTA',
        b._source_id,
        s.societe_sk,
        b.code,
        b.raison_sociale,
        b.siret,
        b.tva_intracom,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        b.telephone,
        b.email,
        b.mode_reglement,
        b.condition_reglement,
        b.encours_autorise,
        b.code,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse])
    FROM bronze.sage_client b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_client c
        WHERE c.client_nk = 'SAGE:' || b.code
        AND c.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Insertion depuis MDE (avec tentative de matching par SIRET)
    INSERT INTO silver.dim_client (
        client_nk, source_system, source_id, societe_sk, code, raison_sociale,
        type_client, siret, tva_intracom, adresse, code_postal, ville, departement,
        telephone, email, conditions_paiement, encours_max, taux_remise,
        mde_code, is_current, valid_from, row_hash
    )
    SELECT
        'MDE:' || b.code,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        b.code,
        b.raison_sociale,
        b.type_client,
        b.siret,
        b.tva_intracom,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        b.telephone,
        b.email,
        b.conditions_paiement,
        b.encours_max,
        b.taux_remise,
        b.code,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret, b.adresse])
    FROM bronze.mde_client b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_client c
        WHERE (c.client_nk = 'MDE:' || b.code OR (c.siret = b.siret AND b.siret IS NOT NULL))
        AND c.is_current = TRUE
    );

    v_rows_inserted := v_rows_inserted + (SELECT COUNT(*) FROM silver.dim_client WHERE source_system = 'MDE_ERP');

    -- Mise a jour des liens SAGE/MDE par SIRET
    UPDATE silver.dim_client mde
    SET sage_code = sage.code
    FROM silver.dim_client sage
    WHERE mde.source_system = 'MDE_ERP'
    AND sage.source_system = 'SAGE_COMPTA'
    AND mde.siret = sage.siret
    AND mde.siret IS NOT NULL
    AND mde.is_current = TRUE
    AND sage.is_current = TRUE;

    -- S'assurer que mde_code = code pour tous les clients (necessaire pour le join documents)
    UPDATE silver.dim_client
    SET mde_code = code
    WHERE mde_code IS NULL AND is_current = TRUE;

    -- Calcul du segment client
    UPDATE silver.dim_client
    SET segment_client = CASE
        WHEN encours_max >= 100000 THEN 'PREMIUM'
        WHEN encours_max >= 50000 THEN 'STANDARD'
        ELSE 'OCCASIONNEL'
    END
    WHERE is_current = TRUE AND segment_client IS NULL;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, v_rows_updated);

    RAISE NOTICE 'LOAD_DIM_CLIENT: % inserts, % updates', v_rows_inserted, v_rows_updated;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.3 ETL Dimension Fournisseur
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_fournisseur()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_FOURNISSEUR', 'ALL', 'SILVER');

    -- SAGE Fournisseurs
    INSERT INTO silver.dim_fournisseur (
        fournisseur_nk, source_system, source_id, societe_sk, code, raison_sociale,
        siret, adresse, code_postal, ville, departement, telephone, email,
        mode_reglement, conditions_paiement, sage_code, is_current, valid_from, row_hash
    )
    SELECT
        'SAGE:' || b.code,
        'SAGE_COMPTA',
        b._source_id,
        s.societe_sk,
        b.code,
        b.raison_sociale,
        b.siret,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        b.telephone,
        b.email,
        b.mode_reglement,
        b.condition_reglement,
        b.code,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret])
    FROM bronze.sage_fournisseur b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_fournisseur f
        WHERE f.fournisseur_nk = 'SAGE:' || b.code AND f.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- MDE Fournisseurs
    INSERT INTO silver.dim_fournisseur (
        fournisseur_nk, source_system, source_id, societe_sk, code, raison_sociale,
        type_fournisseur, siret, adresse, code_postal, ville, departement,
        telephone, email, conditions_paiement, delai_livraison,
        mde_code, is_current, valid_from, row_hash
    )
    SELECT
        'MDE:' || b.code,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        b.code,
        b.raison_sociale,
        b.type_fournisseur,
        b.siret,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        b.telephone,
        b.email,
        b.conditions_paiement,
        b.delai_livraison,
        b.code,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.raison_sociale, b.siret])
    FROM bronze.mde_fournisseur b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_fournisseur f
        WHERE (f.fournisseur_nk = 'MDE:' || b.code OR (f.siret = b.siret AND b.siret IS NOT NULL))
        AND f.is_current = TRUE
    );

    v_rows_inserted := v_rows_inserted + (SELECT COUNT(*) FROM silver.dim_fournisseur WHERE source_system = 'MDE_ERP');

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_FOURNISSEUR: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.4 ETL Dimension Salarie
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_salarie()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_SALARIE', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.dim_salarie (
        salarie_nk, source_system, source_id, societe_sk, matricule,
        nom, prenom, date_naissance, age, date_entree, date_sortie,
        anciennete_mois, poste, categorie_poste, qualification, coefficient,
        taux_horaire, cout_horaire_charge, est_actif, is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.matricule,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        b.matricule,
        b.nom,
        b.prenom,
        b.date_naissance,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, b.date_naissance))::INTEGER,
        b.date_entree,
        b.date_sortie,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, b.date_entree)) * 12 +
            EXTRACT(MONTH FROM AGE(CURRENT_DATE, b.date_entree))::INTEGER,
        b.poste,
        CASE
            WHEN b.qualification IN ('OQ', 'OS', 'OP') THEN 'OUVRIER'
            WHEN b.qualification IN ('ETAM', 'TECH') THEN 'ETAM'
            WHEN b.qualification = 'CADRE' THEN 'CADRE'
            ELSE 'AUTRE'
        END,
        b.qualification,
        b.coefficient,
        b.taux_horaire,
        b.cout_horaire_charge,
        b.actif,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.matricule, b.nom, b.prenom, b.poste, b.qualification])
    FROM bronze.mde_salarie b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_salarie sal
        WHERE sal.salarie_nk = b.societe_id || ':' || b.matricule
        AND sal.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Mise a jour des liens responsables
    UPDATE silver.dim_salarie s
    SET responsable_sk = r.salarie_sk
    FROM bronze.mde_salarie b
    JOIN silver.dim_salarie r ON r.source_id = b.responsable_id AND r.is_current = TRUE
    WHERE s.source_id = b._source_id
    AND s.is_current = TRUE
    AND b.responsable_id IS NOT NULL;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_SALARIE: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.5 ETL Dimension Element
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_element()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_ELEMENT', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.dim_element (
        element_nk, source_system, source_id, societe_sk, code, designation,
        type_element, famille, sous_famille, unite, prix_achat_standard,
        prix_vente_standard, marge_standard_pct, temps_unitaire_heures,
        fournisseur_principal_sk, -- [NEW]
        compte_achat, compte_vente, est_actif, is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.code,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        b.code,
        b.designation,
        b.type_element,
        b.famille,
        b.sous_famille,
        b.unite,
        b.prix_achat,
        b.prix_vente,
        CASE WHEN b.prix_achat > 0 THEN ((b.prix_vente - b.prix_achat) / b.prix_achat * 100) ELSE NULL END,
        b.temps_unitaire,
        f.fournisseur_sk, -- [NEW]
        b.compte_achat,
        b.compte_vente,
        b.actif,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.designation, b.type_element, b.prix_achat::TEXT, b.prix_vente::TEXT])
    FROM bronze.mde_element b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_fournisseur f ON f.source_id = b.fournisseur_principal_id AND f.is_current = TRUE -- [NEW]
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_element e
        WHERE e.element_nk = b.societe_id || ':' || b.code
        AND e.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_ELEMENT: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.6 ETL Dimension Compte
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_compte()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_COMPTE', 'SAGE_COMPTA', 'SILVER');

    INSERT INTO silver.dim_compte (
        compte_nk, source_system, source_id, societe_sk, numero, intitule,
        type_compte, classe, classe_libelle, nature, sens_solde,
        niveau_agregation, compte_parent, est_lettrable, est_rapprochable,
        est_actif, is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.numero,
        'SAGE_COMPTA',
        b._source_id,
        s.societe_sk,
        b.numero,
        b.intitule,
        b.type_compte,
        SUBSTRING(b.numero FROM 1 FOR 1),
        CASE SUBSTRING(b.numero FROM 1 FOR 1)
            WHEN '1' THEN 'Capitaux'
            WHEN '2' THEN 'Immobilisations'
            WHEN '3' THEN 'Stocks'
            WHEN '4' THEN 'Tiers'
            WHEN '5' THEN 'Financier'
            WHEN '6' THEN 'Charges'
            WHEN '7' THEN 'Produits'
            ELSE 'Autre'
        END,
        b.nature,
        b.sens_solde,
        LENGTH(RTRIM(b.numero, '0')),
        CASE WHEN LENGTH(b.numero) > 3 THEN SUBSTRING(b.numero FROM 1 FOR 3) ELSE NULL END,
        b.lettrable,
        b.rapprochable,
        b.actif,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.numero, b.intitule, b.type_compte])
    FROM bronze.sage_compte_general b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_compte c
        WHERE c.compte_nk = b.societe_id || ':' || b.numero
        AND c.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_COMPTE: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.7 ETL Dimension Affaire
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_affaire()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_AFFAIRE', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.dim_affaire (
        affaire_nk, source_system, source_id, societe_sk, client_sk,
        commercial_sk, responsable_sk, code, libelle, etat, etat_groupe,
        type_affaire, date_creation, date_debut_prevue, date_fin_prevue,
        date_debut_reelle, date_fin_reelle, duree_prevue_jours,
        adresse_chantier, code_postal_chantier, ville_chantier,
        departement_chantier, montant_devis, montant_commande, budget_heures,
        marge_prevue_pct, is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.code,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        c.client_sk,
        com.salarie_sk,
        resp.salarie_sk,
        b.code,
        b.libelle,
        b.etat,
        CASE
            WHEN b.etat IN ('PROSPECT', 'DEVIS') THEN 'PROSPECT'
            WHEN b.etat IN ('COMMANDE', 'EN_COURS') THEN 'EN_COURS'
            WHEN b.etat IN ('TERMINE', 'ARCHIVE') THEN 'TERMINE'
            ELSE 'ANNULE'
        END,
        b.type_affaire,
        b.date_creation,
        b.date_debut_prevue,
        b.date_fin_prevue,
        b.date_debut_reelle,
        b.date_fin_reelle,
        b.date_fin_prevue - b.date_debut_prevue,
        b.adresse_chantier,
        b.cp_chantier,
        b.ville_chantier,
        silver.get_departement_from_cp(b.cp_chantier),
        b.montant_devis,
        b.montant_commande,
        b.budget_heures,
        b.marge_prevue,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.libelle, b.etat, b.montant_commande::TEXT])
    FROM bronze.mde_affaire b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_client c ON c.source_id = b.client_id AND c.source_system = 'MDE_ERP' AND c.is_current = TRUE
    LEFT JOIN silver.dim_salarie com ON com.source_id = b.commercial_id AND com.is_current = TRUE
    LEFT JOIN silver.dim_salarie resp ON resp.source_id = b.responsable_id AND resp.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_affaire a
        WHERE a.affaire_nk = b.societe_id || ':' || b.code
        AND a.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_AFFAIRE: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.8 ETL Dimension Chantier
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_chantier()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_CHANTIER', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.dim_chantier (
        chantier_nk, source_system, source_id, societe_sk, affaire_sk,
        chef_chantier_sk, code, libelle, etat, date_debut, date_fin_prevue,
        date_fin_reelle, adresse, code_postal, ville, departement,
        is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.affaire_code || ':' || b.code,
        'MDE_ERP',
        b._source_id,
        s.societe_sk,
        a.affaire_sk,
        chef.salarie_sk,
        b.code,
        b.libelle,
        b.etat,
        b.date_debut,
        b.date_fin_prevue,
        b.date_fin_reelle,
        b.adresse,
        b.code_postal,
        b.ville,
        silver.get_departement_from_cp(b.code_postal),
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.libelle, b.etat])
    FROM bronze.mde_chantier b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_affaire a ON a.source_id = b.affaire_id AND a.is_current = TRUE
    LEFT JOIN silver.dim_salarie chef ON chef.source_id = b.chef_chantier_id AND chef.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_chantier ch
        WHERE ch.chantier_nk = b.societe_id || ':' || b.affaire_code || ':' || b.code
        AND ch.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_CHANTIER: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 2.9 ETL Dimension Journal
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_dim_journal()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_DIM_JOURNAL', 'SAGE_COMPTA', 'SILVER');

    INSERT INTO silver.dim_journal (
        journal_nk, source_system, source_id, societe_sk, code, libelle,
        type_journal, type_journal_groupe, compte_contrepartie, est_actif,
        is_current, valid_from, row_hash
    )
    SELECT
        b.societe_id || ':' || b.code,
        'SAGE_COMPTA',
        b._source_id,
        s.societe_sk,
        b.code,
        b.libelle,
        b.type_journal,
        CASE
            WHEN b.type_journal IN ('BANQUE', 'CAISSE') THEN 'TRESORERIE'
            WHEN b.type_journal IN ('ACHAT', 'VENTE') THEN 'OPERATION'
            WHEN b.type_journal IN ('OD', 'AN') THEN 'SITUATION'
            ELSE 'AUTRE'
        END,
        b.compte_contrepartie,
        b.actif,
        TRUE,
        CURRENT_TIMESTAMP,
        silver.compute_row_hash(ARRAY[b.code, b.libelle, b.type_journal])
    FROM bronze.sage_journal b
    LEFT JOIN silver.dim_societe s ON s.source_id = b.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.dim_journal j
        WHERE j.journal_nk = b.societe_id || ':' || b.code
        AND j.is_current = TRUE
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_DIM_JOURNAL: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 3. ETL BRONZE -> SILVER : FAITS
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 ETL Faits Ecritures Comptables
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_fact_ecriture_compta()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_FACT_ECRITURE', 'SAGE_COMPTA', 'SILVER');

    INSERT INTO silver.fact_ecriture_compta (
        source_system, source_id, date_sk, societe_sk, journal_sk, compte_sk,
        numero_piece, numero_ligne, libelle, reference, compte_numero,
        compte_tiers, montant_debit, montant_credit, code_lettrage,
        date_lettrage, est_lettre, date_echeance, etat_piece, origine
    )
    SELECT
        'SAGE_COMPTA',
        e._source_id,
        TO_CHAR(e.date_ecriture, 'YYYYMMDD')::INTEGER,
        s.societe_sk,
        j.journal_sk,
        c.compte_sk,
        p.numero_piece,
        e.ligne_numero,
        e.libelle,
        e.reference,
        e.compte_numero,
        e.compte_tiers,
        COALESCE(e.debit, 0),
        COALESCE(e.credit, 0),
        e.lettrage,
        e.date_lettrage,
        e.lettrage IS NOT NULL,
        e.date_echeance,
        p.etat,
        p.origine
    FROM bronze.sage_ecriture e
    JOIN bronze.sage_piece p ON p._source_id = e.piece_id
    LEFT JOIN silver.dim_societe s ON s.source_id = p.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_journal j ON j.source_id = p.journal_id AND j.is_current = TRUE
    LEFT JOIN silver.dim_compte c ON c.numero = e.compte_numero AND c.societe_sk = s.societe_sk AND c.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.fact_ecriture_compta f
        WHERE f.source_id = e._source_id
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- Mise a jour des liens clients/fournisseurs
    UPDATE silver.fact_ecriture_compta f
    SET client_sk = c.client_sk
    FROM silver.dim_client c
    WHERE f.compte_tiers IS NOT NULL
    AND c.sage_code = f.compte_tiers
    AND c.is_current = TRUE
    AND f.client_sk IS NULL;

    UPDATE silver.fact_ecriture_compta f
    SET fournisseur_sk = fo.fournisseur_sk
    FROM silver.dim_fournisseur fo
    WHERE f.compte_tiers IS NOT NULL
    AND fo.sage_code = f.compte_tiers
    AND fo.is_current = TRUE
    AND f.fournisseur_sk IS NULL;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_FACT_ECRITURE: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 3.2 ETL Faits Documents Commerciaux
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_fact_document_commercial()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_FACT_DOCUMENT', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.fact_document_commercial (
        source_system, source_id, date_sk, societe_sk, client_sk,
        affaire_sk, chantier_sk, type_document, numero, objet, statut,
        montant_ht, montant_tva, montant_ttc, taux_tva_moyen, nb_lignes,
        date_validation, document_origine_sk -- [NEW]
    )
    SELECT
        'MDE_ERP',
        d._source_id,
        TO_CHAR(d.date_document, 'YYYYMMDD')::INTEGER,
        s.societe_sk,
        c.client_sk,
        a.affaire_sk,
        ch.chantier_sk,
        d.type_document,
        d.numero,
        d.objet,
        d.statut,
        d.montant_ht,
        d.montant_tva,
        d.montant_ttc,
        d.taux_tva,
        (SELECT COUNT(*) FROM bronze.mde_document_ligne l WHERE l.entete_id = d._source_id),
        d.date_validation,
        doc_orig.document_sk -- [NEW]
    FROM bronze.mde_document_entete d
    LEFT JOIN silver.dim_societe s ON s.source_id = d.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_client c ON c.mde_code = d.tiers_code AND c.is_current = TRUE AND d.tiers_type = 'CLIENT'
    LEFT JOIN silver.dim_affaire a ON a.source_id = d.affaire_id AND a.is_current = TRUE
    LEFT JOIN silver.dim_chantier ch ON ch.source_id = d.chantier_id AND ch.is_current = TRUE
    LEFT JOIN silver.fact_document_commercial doc_orig ON doc_orig.source_id = d.document_origine_id -- [NEW]
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.fact_document_commercial f
        WHERE f.source_id = d._source_id
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_FACT_DOCUMENT: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 3.3 ETL Faits Lignes Documents
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_fact_ligne_document()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_FACT_LIGNE_DOC', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.fact_ligne_document (
        source_system, source_id, document_sk, element_sk, numero_ligne,
        designation, unite, quantite, prix_unitaire, remise_pct, montant_ht, taux_tva
    )
    SELECT
        'MDE_ERP',
        l._source_id,
        d.document_sk,
        e.element_sk,
        l.numero_ligne,
        l.designation,
        l.unite,
        l.quantite,
        l.prix_unitaire,
        l.remise_pct,
        l.montant_ht,
        l.taux_tva
    FROM bronze.mde_document_ligne l
    JOIN silver.fact_document_commercial d ON d.source_id = l.entete_id
    LEFT JOIN silver.dim_element e ON e.code = l.element_code AND e.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.fact_ligne_document f
        WHERE f.source_id = l._source_id
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_FACT_LIGNE_DOC: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 3.4 ETL Faits Suivi Main d'Oeuvre
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_fact_suivi_mo()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_FACT_SUIVI_MO', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.fact_suivi_mo (
        source_system, source_id, date_sk, societe_sk, salarie_sk,
        affaire_sk, chantier_sk, semaine_iso, heures_normales,
        heures_supp_25, heures_supp_50, heures_nuit, heures_dimanche,
        heures_deplacement, cout_heures_normales, cout_heures_supp,
        cout_total, indemnites_repas, indemnites_trajet
    )
    SELECT
        'MDE_ERP',
        m._source_id,
        TO_CHAR(m.date_debut_semaine, 'YYYYMMDD')::INTEGER,
        s.societe_sk,
        sal.salarie_sk,
        a.affaire_sk,
        ch.chantier_sk,
        m.semaine_iso,
        m.heures_normales,
        m.heures_supp_25,
        m.heures_supp_50,
        m.heures_nuit,
        m.heures_dimanche,
        m.heures_deplacement,
        m.heures_normales * COALESCE(sal.cout_horaire_charge, 45),
        (m.heures_supp_25 * 1.25 + m.heures_supp_50 * 1.5) * COALESCE(sal.cout_horaire_charge, 45),
        (m.heures_normales + m.heures_supp_25 * 1.25 + m.heures_supp_50 * 1.5 +
         m.heures_nuit * 1.25 + m.heures_dimanche * 2) * COALESCE(sal.cout_horaire_charge, 45),
        m.indemnites_repas,
        m.indemnites_trajet
    FROM bronze.mde_suivi_mo m
    LEFT JOIN silver.dim_societe s ON s.source_id = m.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_salarie sal ON sal.source_id = m.salarie_id AND sal.is_current = TRUE
    LEFT JOIN silver.dim_affaire a ON a.source_id = m.affaire_id AND a.is_current = TRUE
    LEFT JOIN silver.dim_chantier ch ON ch.source_id = m.chantier_id AND ch.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.fact_suivi_mo f
        WHERE f.source_id = m._source_id
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_FACT_SUIVI_MO: % inserts', v_rows_inserted;
END;
$$;

-- -----------------------------------------------------------------------------
-- 3.5 ETL Faits Mouvements Stock
-- -----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE etl.load_fact_mouvement_stock()
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_rows_inserted INTEGER := 0;
BEGIN
    v_job_id := etl.start_job('LOAD_FACT_MVT_STOCK', 'MDE_ERP', 'SILVER');

    INSERT INTO silver.fact_mouvement_stock (
        source_system, source_id, date_sk, societe_sk, element_sk,
        affaire_sk, depot_code, type_mouvement, reference,
        quantite_entree, quantite_sortie, prix_unitaire, valeur_mouvement
    )
    SELECT
        'MDE_ERP',
        m._source_id,
        TO_CHAR(m.date_mouvement, 'YYYYMMDD')::INTEGER,
        s.societe_sk,
        e.element_sk,
        a.affaire_sk,
        m.depot_code,
        m.type_mouvement,
        m.reference,
        CASE WHEN m.type_mouvement = 'ENTREE' THEN m.quantite ELSE 0 END,
        CASE WHEN m.type_mouvement = 'SORTIE' THEN m.quantite ELSE 0 END,
        m.prix_unitaire,
        m.quantite * COALESCE(m.prix_unitaire, 0)
    FROM bronze.mde_mouvement_stock m
    LEFT JOIN silver.dim_societe s ON s.source_id = m.societe_id AND s.source_system = 'SAGE_COMPTA' AND s.is_current = TRUE
    LEFT JOIN silver.dim_element e ON e.code = m.element_code AND e.is_current = TRUE
    LEFT JOIN silver.dim_affaire a ON a.source_id = m.affaire_id AND a.is_current = TRUE
    WHERE NOT EXISTS (
        SELECT 1 FROM silver.fact_mouvement_stock f
        WHERE f.source_id = m._source_id
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    PERFORM etl.end_job(v_job_id, 'SUCCESS', v_rows_inserted, 0);

    RAISE NOTICE 'LOAD_FACT_MVT_STOCK: % inserts', v_rows_inserted;
END;
$$;

-- ============================================================================
-- 4. PROCEDURE ORCHESTRATION BRONZE -> SILVER
-- ============================================================================

CREATE OR REPLACE PROCEDURE etl.run_bronze_to_silver()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Debut ETL Bronze -> Silver: %', CURRENT_TIMESTAMP;

    -- Dimensions (ordre de dependance)
    CALL etl.load_dim_societe();
    CALL etl.load_dim_client();
    CALL etl.load_dim_fournisseur();
    CALL etl.load_dim_salarie();
    CALL etl.load_dim_element();
    CALL etl.load_dim_compte();
    CALL etl.load_dim_journal();
    CALL etl.load_dim_affaire();
    CALL etl.load_dim_chantier();

    -- Faits
    CALL etl.load_fact_ecriture_compta();
    CALL etl.load_fact_document_commercial();
    CALL etl.load_fact_ligne_document();
    CALL etl.load_fact_suivi_mo();
    CALL etl.load_fact_mouvement_stock();

    RAISE NOTICE 'Fin ETL Bronze -> Silver: %', CURRENT_TIMESTAMP;
END;
$$;

-- ============================================================================
-- FIN ETL BRONZE -> SILVER
-- ============================================================================

\echo 'ETL Bronze -> Silver cree avec succes'

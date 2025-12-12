-- ============================================================================
-- DATA WAREHOUSE - SEED INITIAL
-- Chargement des donnees depuis les bases sources (SAGE + MDE)
-- ============================================================================

-- \c dwh_groupe_duret;

-- ============================================================================
-- 1. EXTRACTION BRONZE DEPUIS SAGE_COMPTA
-- ============================================================================

\echo 'Extraction Bronze depuis SAGE_COMPTA...'

-- Note: En production, ces requetes utiliseraient dblink ou postgres_fdw
-- Pour le seed initial, on simule avec des INSERT directs

-- Societes SAGE
INSERT INTO bronze.sage_societe (_source_id, code, raison_sociale, siret, adresse, code_postal, ville, telephone, email, regime_tva, actif)
VALUES
(1, 'DURETELEC', 'DURET ELECTRICITE SAS', '12345678901234', '15 Rue de l''Industrie', '44000', 'NANTES', '02 40 12 34 56', 'contact@duretelec.fr', 'NORMAL', TRUE),
(2, 'DURETENE', 'DURET ENERGIE SARL', '12345678901235', '15 Rue de l''Industrie', '44000', 'NANTES', '02 40 12 34 57', 'contact@duretene.fr', 'NORMAL', TRUE),
(3, 'DURETRES', 'DURET RESEAUX SAS', '12345678901236', '8 Avenue des Technologies', '44300', 'NANTES', '02 40 12 34 58', 'contact@duretres.fr', 'NORMAL', TRUE),
(4, 'DURETSER', 'DURET SERVICES SARL', '12345678901237', '8 Avenue des Technologies', '44300', 'NANTES', '02 40 12 34 59', 'contact@duretser.fr', 'NORMAL', TRUE);

-- Journaux SAGE
INSERT INTO bronze.sage_journal (_source_id, societe_id, code, libelle, type_journal, actif)
SELECT
    ROW_NUMBER() OVER(),
    s.id,
    j.code,
    j.libelle,
    j.type_journal,
    TRUE
FROM (VALUES (1), (2), (3), (4)) AS s(id)
CROSS JOIN (VALUES
    ('ACH', 'Journal des Achats', 'ACHAT'),
    ('VTE', 'Journal des Ventes', 'VENTE'),
    ('BQ1', 'Banque Principale', 'BANQUE'),
    ('BQ2', 'Banque Secondaire', 'BANQUE'),
    ('CAI', 'Caisse', 'CAISSE'),
    ('OD', 'Operations Diverses', 'OD'),
    ('AN', 'A Nouveaux', 'AN')
) AS j(code, libelle, type_journal);

-- Comptes generaux SAGE (PCG simplifie)
INSERT INTO bronze.sage_compte_general (_source_id, societe_id, numero, intitule, type_compte, nature, sens_solde, lettrable, rapprochable, actif)
SELECT
    ROW_NUMBER() OVER(),
    s.id,
    c.numero,
    c.intitule,
    c.type_compte,
    c.nature,
    c.sens_solde,
    c.lettrable,
    c.rapprochable,
    TRUE
FROM (VALUES (1), (2), (3), (4)) AS s(id)
CROSS JOIN (VALUES
    -- Classe 1 - Capitaux
    ('101000', 'Capital social', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('106000', 'Reserves', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('110000', 'Report a nouveau', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('120000', 'Resultat de l''exercice', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    -- Classe 2 - Immobilisations
    ('211000', 'Terrains', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    ('213000', 'Constructions', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    ('215000', 'Materiel industriel', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    ('218200', 'Materiel de transport', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    ('281500', 'Amort. materiel industriel', 'GENERAL', 'ACTIF', 'CREDIT', FALSE, FALSE),
    -- Classe 4 - Tiers
    ('401000', 'Fournisseurs', 'COLLECTIF', 'PASSIF', 'CREDIT', TRUE, FALSE),
    ('411000', 'Clients', 'COLLECTIF', 'ACTIF', 'DEBIT', TRUE, FALSE),
    ('421000', 'Personnel - Remunerations dues', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('431000', 'Securite sociale', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('445710', 'TVA collectee', 'GENERAL', 'PASSIF', 'CREDIT', FALSE, FALSE),
    ('445660', 'TVA deductible', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    -- Classe 5 - Financier
    ('512100', 'Banque CIC', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, TRUE),
    ('512200', 'Banque BNP', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, TRUE),
    ('530000', 'Caisse', 'GENERAL', 'ACTIF', 'DEBIT', FALSE, FALSE),
    -- Classe 6 - Charges
    ('601000', 'Achats matieres premieres', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('602000', 'Achats fournitures', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('604000', 'Achats etudes et prestations', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('606100', 'Fournitures non stockables', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('611000', 'Sous-traitance generale', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('613000', 'Locations', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('615000', 'Entretien et reparations', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('616000', 'Primes d''assurance', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('621000', 'Personnel exterieur', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('622000', 'Remunerations intermediaires', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('623000', 'Publicite', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('625000', 'Deplacements', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('626000', 'Frais postaux et telecom', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('627000', 'Services bancaires', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('641000', 'Remunerations du personnel', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('645000', 'Charges sociales', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    ('681000', 'Dotations amortissements', 'GENERAL', 'CHARGE', 'DEBIT', FALSE, FALSE),
    -- Classe 7 - Produits
    ('704100', 'Travaux', 'GENERAL', 'PRODUIT', 'CREDIT', FALSE, FALSE),
    ('704200', 'Prestations de services', 'GENERAL', 'PRODUIT', 'CREDIT', FALSE, FALSE),
    ('706000', 'Prestations diverses', 'GENERAL', 'PRODUIT', 'CREDIT', FALSE, FALSE),
    ('708000', 'Produits activites annexes', 'GENERAL', 'PRODUIT', 'CREDIT', FALSE, FALSE),
    ('791000', 'Transferts de charges', 'GENERAL', 'PRODUIT', 'CREDIT', FALSE, FALSE)
) AS c(numero, intitule, type_compte, nature, sens_solde, lettrable, rapprochable);

-- Clients SAGE (150 clients)
INSERT INTO bronze.sage_client (_source_id, societe_id, code, raison_sociale, compte_general, siret, adresse, code_postal, ville, telephone, email, mode_reglement, condition_reglement, encours_autorise, actif)
SELECT
    ROW_NUMBER() OVER(),
    1, -- Societe DURETELEC
    'C' || LPAD(n::TEXT, 4, '0'),
    'CLIENT ' || UPPER(
        (ARRAY['MARTIN', 'BERNARD', 'DUBOIS', 'THOMAS', 'ROBERT', 'RICHARD', 'PETIT', 'DURAND', 'LEROY', 'MOREAU',
               'SIMON', 'LAURENT', 'LEFEBVRE', 'MICHEL', 'GARCIA', 'DAVID', 'BERTRAND', 'ROUX', 'VINCENT', 'FOURNIER'])[((n-1) % 20) + 1]
    ) || ' ' ||
    (ARRAY['SARL', 'SAS', 'SA', 'EURL', 'SCI'])[((n-1) % 5) + 1],
    '411000',
    LPAD(((n * 12345) % 100000000000000)::TEXT, 14, '0'),
    n || ' Rue du Commerce',
    LPAD((44000 + (n % 100))::TEXT, 5, '0'),
    (ARRAY['NANTES', 'RENNES', 'ANGERS', 'LE MANS', 'SAINT-NAZAIRE', 'LAVAL', 'CHOLET', 'VANNES', 'LORIENT', 'QUIMPER'])[((n-1) % 10) + 1],
    '02 ' || LPAD((40 + (n % 10))::TEXT, 2, '0') || ' ' || LPAD((n % 100)::TEXT, 2, '0') || ' ' || LPAD(((n * 7) % 100)::TEXT, 2, '0') || ' ' || LPAD(((n * 3) % 100)::TEXT, 2, '0'),
    'client' || n || '@email.fr',
    (ARRAY['VIREMENT', 'CHEQUE', 'PRELEVEMENT', 'TRAITE', 'CB'])[((n-1) % 5) + 1],
    (ARRAY[30, 45, 60, 90])[((n-1) % 4) + 1],
    (ARRAY[10000, 25000, 50000, 100000, 200000])[((n-1) % 5) + 1]::NUMERIC,
    TRUE
FROM generate_series(1, 150) AS n;

-- Fournisseurs SAGE (80 fournisseurs)
INSERT INTO bronze.sage_fournisseur (_source_id, societe_id, code, raison_sociale, compte_general, siret, adresse, code_postal, ville, telephone, email, mode_reglement, condition_reglement, actif)
SELECT
    ROW_NUMBER() OVER(),
    1,
    'F' || LPAD(n::TEXT, 4, '0'),
    'FOURNISSEUR ' ||
    (ARRAY['LEGRAND', 'SCHNEIDER', 'HAGER', 'ABB', 'SIEMENS', 'REXEL', 'SONEPAR', 'YESSS', 'CGED', 'REXEL'])[((n-1) % 10) + 1] || ' ' || n,
    '401000',
    LPAD(((n * 54321) % 100000000000000)::TEXT, 14, '0'),
    n || ' Zone Industrielle',
    LPAD((44000 + (n % 200))::TEXT, 5, '0'),
    (ARRAY['NANTES', 'PARIS', 'LYON', 'MARSEILLE', 'LILLE', 'TOULOUSE', 'BORDEAUX', 'STRASBOURG'])[((n-1) % 8) + 1],
    '01 ' || LPAD((40 + (n % 10))::TEXT, 2, '0') || ' ' || LPAD((n % 100)::TEXT, 2, '0') || ' ' || LPAD(((n * 7) % 100)::TEXT, 2, '0') || ' ' || LPAD(((n * 3) % 100)::TEXT, 2, '0'),
    'fournisseur' || n || '@email.fr',
    'VIREMENT',
    (ARRAY[30, 45, 60])[((n-1) % 3) + 1],
    TRUE
FROM generate_series(1, 80) AS n;

-- Pieces et ecritures comptables (simulation 6 mois)
DO $$
DECLARE
    v_piece_id INTEGER := 1;
    v_ecriture_id INTEGER := 1;
    v_date DATE;
    v_montant_ht NUMERIC;
    v_montant_tva NUMERIC;
    v_client_code VARCHAR(10);
    v_fournisseur_code VARCHAR(10);
BEGIN
    FOR v_mois IN 1..6 LOOP
        FOR v_jour IN 1..28 LOOP
            v_date := DATE '2025-01-01' + ((v_mois - 1) * 30 + v_jour - 1) * INTERVAL '1 day';

            -- 3 factures ventes par jour
            FOR v_i IN 1..3 LOOP
                v_montant_ht := (1000 + RANDOM() * 50000)::NUMERIC(15,2);
                v_montant_tva := (v_montant_ht * 0.20)::NUMERIC(15,2);
                v_client_code := 'C' || LPAD((1 + (v_piece_id % 150))::TEXT, 4, '0');

                -- Piece
                INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
                VALUES (v_piece_id, 1, 1, 2, 'VTE-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date, 'Facture client ' || v_client_code, 'VALIDE', 'SAISIE', v_montant_ht + v_montant_tva, v_montant_ht + v_montant_tva);

                -- Ecritures
                INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
                VALUES
                (v_ecriture_id, v_piece_id, 1, v_date, '411000', v_client_code, 'Facture ' || v_client_code, 'FC-' || v_piece_id, v_montant_ht + v_montant_tva, 0, v_date + INTERVAL '30 days'),
                (v_ecriture_id + 1, v_piece_id, 2, v_date, '704100', NULL, 'Travaux ' || v_client_code, 'FC-' || v_piece_id, 0, v_montant_ht, NULL),
                (v_ecriture_id + 2, v_piece_id, 3, v_date, '445710', NULL, 'TVA collectee', 'FC-' || v_piece_id, 0, v_montant_tva, NULL);

                v_piece_id := v_piece_id + 1;
                v_ecriture_id := v_ecriture_id + 3;
            END LOOP;

            -- 2 factures achats par jour
            FOR v_i IN 1..2 LOOP
                v_montant_ht := (500 + RANDOM() * 20000)::NUMERIC(15,2);
                v_montant_tva := (v_montant_ht * 0.20)::NUMERIC(15,2);
                v_fournisseur_code := 'F' || LPAD((1 + (v_piece_id % 80))::TEXT, 4, '0');

                INSERT INTO bronze.sage_piece (_source_id, societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine, montant_debit, montant_credit)
                VALUES (v_piece_id, 1, 1, 1, 'ACH-' || LPAD(v_piece_id::TEXT, 6, '0'), v_date, 'Facture fournisseur ' || v_fournisseur_code, 'VALIDE', 'SAISIE', v_montant_ht + v_montant_tva, v_montant_ht + v_montant_tva);

                INSERT INTO bronze.sage_ecriture (_source_id, piece_id, ligne_numero, date_ecriture, compte_numero, compte_tiers, libelle, reference, debit, credit, date_echeance)
                VALUES
                (v_ecriture_id, v_piece_id, 1, v_date, '601000', NULL, 'Achat ' || v_fournisseur_code, 'FF-' || v_piece_id, v_montant_ht, 0, NULL),
                (v_ecriture_id + 1, v_piece_id, 2, v_date, '445660', NULL, 'TVA deductible', 'FF-' || v_piece_id, v_montant_tva, 0, NULL),
                (v_ecriture_id + 2, v_piece_id, 3, v_date, '401000', v_fournisseur_code, 'Facture ' || v_fournisseur_code, 'FF-' || v_piece_id, 0, v_montant_ht + v_montant_tva, v_date + INTERVAL '45 days');

                v_piece_id := v_piece_id + 1;
                v_ecriture_id := v_ecriture_id + 3;
            END LOOP;

        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 2. EXTRACTION BRONZE DEPUIS MDE_ERP
-- ============================================================================

\echo 'Extraction Bronze depuis MDE_ERP...'

-- Clients MDE (copie des clients SAGE + enrichissement)
INSERT INTO bronze.mde_client (_source_id, societe_id, code, raison_sociale, type_client, siret, adresse, code_postal, ville, telephone, email, commercial_id, conditions_paiement, taux_remise, encours_max, actif)
SELECT
    _source_id,
    societe_id,
    code,
    raison_sociale,
    (ARRAY['ENTREPRISE', 'COLLECTIVITE', 'PARTICULIER', 'PROMOTEUR', 'SYNDIC'])[(((_source_id - 1) % 5) + 1)],
    siret,
    adresse,
    code_postal,
    ville,
    telephone,
    email,
    ((_source_id - 1) % 10) + 1,
    condition_reglement,
    (ARRAY[0, 2, 5, 8, 10, 15])[(((_source_id - 1) % 6) + 1)],
    encours_autorise,
    actif
FROM bronze.sage_client;

-- Fournisseurs MDE
INSERT INTO bronze.mde_fournisseur (_source_id, societe_id, code, raison_sociale, type_fournisseur, siret, adresse, code_postal, ville, telephone, email, delai_livraison, conditions_paiement, actif)
SELECT
    _source_id,
    societe_id,
    code,
    raison_sociale,
    (ARRAY['MATERIEL', 'OUTILLAGE', 'EPI', 'LOCATION', 'SERVICES'])[(((_source_id - 1) % 5) + 1)],
    siret,
    adresse,
    code_postal,
    ville,
    telephone,
    email,
    (ARRAY[1, 2, 3, 5, 7, 10, 15])[(((_source_id - 1) % 7) + 1)],
    condition_reglement,
    actif
FROM bronze.sage_fournisseur;

-- Sous-traitants MDE
INSERT INTO bronze.mde_sous_traitant (_source_id, societe_id, code, raison_sociale, siret, adresse, code_postal, ville, telephone, email, corps_metier, qualification, taux_horaire, actif)
SELECT
    n,
    1,
    'ST' || LPAD(n::TEXT, 3, '0'),
    'SOUS-TRAITANT ' ||
    (ARRAY['ELEC PRO', 'CABLES SERVICES', 'RESEAUX OUEST', 'INSTALL PLUS', 'MAINTENANCE PRO'])[((n-1) % 5) + 1] || ' ' || n,
    LPAD(((n * 98765) % 100000000000000)::TEXT, 14, '0'),
    n || ' Rue des Artisans',
    LPAD((44000 + (n % 50))::TEXT, 5, '0'),
    (ARRAY['NANTES', 'RENNES', 'ANGERS', 'LE MANS', 'SAINT-NAZAIRE'])[((n-1) % 5) + 1],
    '02 ' || LPAD((40 + (n % 10))::TEXT, 2, '0') || ' 00 00 ' || LPAD(n::TEXT, 2, '0'),
    'soustraitant' || n || '@email.fr',
    (ARRAY['ELECTRICITE', 'PLOMBERIE', 'CVC', 'PEINTURE', 'MACONNERIE'])[((n-1) % 5) + 1],
    (ARRAY['QUALIBAT', 'QUALIFELEC', 'RGE', 'ISO9001'])[((n-1) % 4) + 1],
    -- Taux horaire realiste: 45-75€ selon qualification
    (45 + (n % 30))::NUMERIC(10,2),
    TRUE
FROM generate_series(1, 30) AS n;

-- Salaries MDE (100 salaries)
INSERT INTO bronze.mde_salarie (_source_id, societe_id, matricule, nom, prenom, date_naissance, date_entree, poste, qualification, coefficient, taux_horaire, cout_horaire_charge, responsable_id, actif)
SELECT
    n,
    1,
    'SAL' || LPAD(n::TEXT, 4, '0'),
    (ARRAY['MARTIN', 'BERNARD', 'DUBOIS', 'THOMAS', 'ROBERT', 'RICHARD', 'PETIT', 'DURAND', 'LEROY', 'MOREAU',
           'SIMON', 'LAURENT', 'LEFEBVRE', 'MICHEL', 'GARCIA', 'DAVID', 'BERTRAND', 'ROUX', 'VINCENT', 'FOURNIER'])[((n-1) % 20) + 1],
    (ARRAY['Jean', 'Pierre', 'Michel', 'Philippe', 'Alain', 'Patrick', 'Jacques', 'Christophe', 'Stephane', 'Nicolas',
           'Marie', 'Sophie', 'Nathalie', 'Isabelle', 'Catherine', 'Christine', 'Sandrine', 'Valerie', 'Anne', 'Claire'])[((n-1) % 20) + 1],
    -- Date naissance: entre 1960 et 1995 (30-65 ans en 2025)
    DATE '1960-01-01' + ((n * 127) % 12775) * INTERVAL '1 day',
    -- Date entree: entre 2015 et 2024 (max 10 ans d'anciennete)
    DATE '2015-01-01' + ((n * 47) % 3287) * INTERVAL '1 day',
    CASE
        WHEN n <= 5 THEN 'Directeur'
        WHEN n <= 10 THEN 'Chef de chantier'
        WHEN n <= 20 THEN 'Conducteur de travaux'
        WHEN n <= 40 THEN 'Chef d''equipe'
        ELSE 'Electricien'
    END,
    CASE
        WHEN n <= 10 THEN 'CADRE'
        WHEN n <= 30 THEN 'ETAM'
        ELSE 'OQ'
    END,
    CASE
        WHEN n <= 10 THEN 400 + (n * 10)
        WHEN n <= 30 THEN 250 + (n * 5)
        ELSE 150 + (n * 2)
    END,
    CASE
        WHEN n <= 10 THEN (35 + n)::NUMERIC
        WHEN n <= 30 THEN (20 + n/2)::NUMERIC
        ELSE (15 + n/10)::NUMERIC
    END,
    CASE
        WHEN n <= 10 THEN (35 + n) * 1.8
        WHEN n <= 30 THEN (20 + n/2) * 1.7
        ELSE (15 + n/10) * 1.6
    END::NUMERIC(10,2),
    CASE WHEN n > 10 THEN ((n-1) % 10) + 1 ELSE NULL END,
    TRUE
FROM generate_series(1, 100) AS n;

-- Elements catalogue MDE (800+ articles)
INSERT INTO bronze.mde_element (_source_id, societe_id, code, designation, type_element, famille, sous_famille, unite, prix_achat, prix_vente, coefficient_vente, temps_unitaire, compte_achat, compte_vente, actif)
-- Cables
SELECT
    n,
    1,
    'CAB' || LPAD(n::TEXT, 5, '0'),
    'Cable ' || (ARRAY['U1000R2V', 'H07VU', 'H07VR', 'FRN05VV', 'AR2V'])[((n-1) % 5) + 1] ||
    ' ' || (ARRAY['1.5', '2.5', '4', '6', '10', '16', '25', '35', '50'])[((n-1) % 9) + 1] || 'mm2 ' ||
    (ARRAY['2', '3', '4', '5', '7'])[((n-1) % 5) + 1] || 'G',
    'FOURNITURE',
    'CABLES',
    (ARRAY['RIGIDE', 'SOUPLE', 'ARME', 'INCENDIE', 'TELECOM'])[((n-1) % 5) + 1],
    'ML',
    (0.5 + RANDOM() * 20)::NUMERIC(15,4),
    ((0.5 + RANDOM() * 20) * 1.5)::NUMERIC(15,4),
    1.5,
    0.05,
    '601000',
    '704100',
    TRUE
FROM generate_series(1, 200) AS n
UNION ALL
-- Appareillage
SELECT
    200 + n,
    1,
    'APP' || LPAD(n::TEXT, 5, '0'),
    (ARRAY['Interrupteur', 'Prise', 'Va-et-vient', 'Poussoir', 'Variateur', 'Detecteur'])[((n-1) % 6) + 1] ||
    ' ' || (ARRAY['LEGRAND Mosaic', 'SCHNEIDER Odace', 'HAGER Systo', 'ABB Basic55', 'NIKO Pure'])[((n-1) % 5) + 1],
    'FOURNITURE',
    'APPAREILLAGE',
    (ARRAY['INTERRUPTEURS', 'PRISES', 'DETECTEURS', 'VARIATEURS', 'COMMANDES'])[((n-1) % 5) + 1],
    'U',
    (2 + RANDOM() * 50)::NUMERIC(15,4),
    ((2 + RANDOM() * 50) * 2)::NUMERIC(15,4),
    2.0,
    0.15,
    '601000',
    '704100',
    TRUE
FROM generate_series(1, 200) AS n
UNION ALL
-- Tableaux
SELECT
    400 + n,
    1,
    'TAB' || LPAD(n::TEXT, 5, '0'),
    'Tableau ' || (ARRAY['1 rangee', '2 rangees', '3 rangees', '4 rangees'])[((n-1) % 4) + 1] ||
    ' ' || (ARRAY['13 modules', '18 modules', '24 modules'])[((n-1) % 3) + 1] ||
    ' ' || (ARRAY['LEGRAND', 'SCHNEIDER', 'HAGER', 'ABB'])[((n-1) % 4) + 1],
    'FOURNITURE',
    'TABLEAUX',
    (ARRAY['DOMESTIQUE', 'TERTIAIRE', 'INDUSTRIEL', 'PRECABLE'])[((n-1) % 4) + 1],
    'U',
    (15 + RANDOM() * 200)::NUMERIC(15,4),
    ((15 + RANDOM() * 200) * 1.8)::NUMERIC(15,4),
    1.8,
    1,
    '601000',
    '704100',
    TRUE
FROM generate_series(1, 100) AS n
UNION ALL
-- Protection
SELECT
    500 + n,
    1,
    'PRO' || LPAD(n::TEXT, 5, '0'),
    (ARRAY['Disjoncteur', 'Differentiel', 'Interrupteur diff', 'Parafoudre', 'Telerupteur'])[((n-1) % 5) + 1] ||
    ' ' || (ARRAY['10A', '16A', '20A', '32A', '40A', '63A'])[((n-1) % 6) + 1] ||
    ' ' || (ARRAY['LEGRAND', 'SCHNEIDER', 'HAGER', 'ABB'])[((n-1) % 4) + 1],
    'FOURNITURE',
    'PROTECTION',
    (ARRAY['DISJONCTEURS', 'DIFFERENTIELS', 'MODULAIRE', 'PARAFOUDRES'])[((n-1) % 4) + 1],
    'U',
    (5 + RANDOM() * 150)::NUMERIC(15,4),
    ((5 + RANDOM() * 150) * 1.6)::NUMERIC(15,4),
    1.6,
    0.25,
    '601000',
    '704100',
    TRUE
FROM generate_series(1, 150) AS n
UNION ALL
-- Eclairage
SELECT
    650 + n,
    1,
    'ECL' || LPAD(n::TEXT, 5, '0'),
    (ARRAY['Spot LED', 'Dalle LED', 'Reglette LED', 'Projecteur LED', 'Hublot LED', 'Suspension'])[((n-1) % 6) + 1] ||
    ' ' || (ARRAY['600x600', '1200x300', 'Rond', 'Carre', 'Lineaire'])[((n-1) % 5) + 1] ||
    ' ' || (ARRAY['10W', '20W', '30W', '40W', '50W', '100W'])[((n-1) % 6) + 1],
    'FOURNITURE',
    'ECLAIRAGE',
    (ARRAY['LED', 'EXTERIEUR', 'SECOURS', 'DECORATIF', 'INDUSTRIEL'])[((n-1) % 5) + 1],
    'U',
    (10 + RANDOM() * 300)::NUMERIC(15,4),
    ((10 + RANDOM() * 300) * 1.7)::NUMERIC(15,4),
    1.7,
    0.5,
    '601000',
    '704100',
    TRUE
FROM generate_series(1, 100) AS n
UNION ALL
-- Main d'oeuvre
SELECT
    750 + n,
    1,
    'MO' || LPAD(n::TEXT, 4, '0'),
    'Main d''oeuvre ' || (ARRAY['Electricien N1', 'Electricien N2', 'Electricien N3', 'Chef equipe', 'Conducteur travaux'])[((n-1) % 5) + 1],
    'MAIN_OEUVRE',
    'MAIN_OEUVRE',
    (ARRAY['PRODUCTION', 'ENCADREMENT', 'ETUDES'])[((n-1) % 3) + 1],
    'H',
    0,
    (35 + n * 5)::NUMERIC(15,4),
    1,
    1,
    '641000',
    '704100',
    TRUE
FROM generate_series(1, 20) AS n;

-- Affaires MDE (50 affaires)
INSERT INTO bronze.mde_affaire (_source_id, societe_id, code, libelle, client_id, client_code, commercial_id, responsable_id, etat, type_affaire, date_creation, date_debut_prevue, date_fin_prevue, date_debut_reelle, adresse_chantier, cp_chantier, ville_chantier, montant_devis, montant_commande, montant_facture, marge_prevue, budget_heures, heures_realisees)
SELECT
    n,
    1,
    'AFF2025-' || LPAD(n::TEXT, 3, '0'),
    (ARRAY['Renovation electrique', 'Installation neuve', 'Mise aux normes', 'Extension reseau', 'Maintenance annuelle',
           'Eclairage LED', 'Domotique', 'Borne de recharge', 'Photovoltaique', 'Courants faibles'])[((n-1) % 10) + 1] ||
    ' ' || (ARRAY['Batiment A', 'Batiment B', 'Site principal', 'Annexe', 'Entrepot', 'Bureau', 'Atelier'])[((n-1) % 7) + 1],
    ((n-1) % 150) + 1,
    'C' || LPAD((((n-1) % 150) + 1)::TEXT, 4, '0'),
    ((n-1) % 10) + 1,
    ((n-1) % 5) + 11,
    (ARRAY['PROSPECT', 'DEVIS', 'COMMANDE', 'EN_COURS', 'EN_COURS', 'EN_COURS', 'TERMINE', 'TERMINE', 'ARCHIVE', 'ANNULE'])[((n-1) % 10) + 1],
    (ARRAY['RENOVATION', 'NEUF', 'MAINTENANCE', 'EXTENSION', 'DEPANNAGE'])[((n-1) % 5) + 1],
    DATE '2025-01-01' + (n * 3) * INTERVAL '1 day',
    DATE '2025-01-15' + (n * 5) * INTERVAL '1 day',
    DATE '2025-03-01' + (n * 7) * INTERVAL '1 day',
    CASE WHEN n <= 40 THEN DATE '2025-01-20' + (n * 5) * INTERVAL '1 day' ELSE NULL END,
    n || ' Rue du Chantier',
    LPAD((44000 + (n % 100))::TEXT, 5, '0'),
    (ARRAY['NANTES', 'RENNES', 'ANGERS', 'LE MANS', 'SAINT-NAZAIRE'])[((n-1) % 5) + 1],
    -- montant_devis: toujours genere
    (15000 + (n * 3719) % 200000)::NUMERIC(15,2),
    -- montant_commande: si en cours ou termine, doit exister si facture existe
    CASE
        WHEN n <= 30 THEN (15000 + (n * 3719) % 200000 * 0.95)::NUMERIC(15,2)  -- commande < devis
        WHEN n <= 40 THEN (15000 + (n * 2897) % 180000)::NUMERIC(15,2)
        ELSE 0
    END,
    -- montant_facture: ne peut pas depasser montant_commande
    CASE
        WHEN n <= 30 THEN LEAST(
            (10000 + (n * 2341) % 150000)::NUMERIC(15,2),
            (15000 + (n * 3719) % 200000 * 0.95)::NUMERIC(15,2)
        )
        ELSE 0
    END,
    -- marge_prevue: 15-30%
    (15 + (n % 15))::NUMERIC(5,2),
    -- budget_heures: sera recalcule par script 13
    (100 + (n * 23) % 1000)::NUMERIC(10,2),
    -- heures_realisees: sera recalcule par script 13
    CASE WHEN n <= 30 THEN (80 + (n * 17) % 800)::NUMERIC(10,2) ELSE 0 END
FROM generate_series(1, 50) AS n;

-- Chantiers MDE
INSERT INTO bronze.mde_chantier (_source_id, societe_id, affaire_id, affaire_code, code, libelle, etat, chef_chantier_id, date_debut, date_fin_prevue, adresse, code_postal, ville, avancement_pct)
SELECT
    n,
    1,
    ((n-1) / 2) + 1,
    'AFF2025-' || LPAD((((n-1) / 2) + 1)::TEXT, 3, '0'),
    'CH' || LPAD(n::TEXT, 4, '0'),
    'Chantier ' || (ARRAY['Phase 1', 'Phase 2', 'Lot elec', 'Lot CFO', 'Lot CFA'])[((n-1) % 5) + 1],
    (ARRAY['PREPARATION', 'EN_COURS', 'EN_COURS', 'TERMINE', 'CLOTURE'])[((n-1) % 5) + 1],
    ((n-1) % 20) + 11,
    DATE '2025-02-01' + (n * 3) * INTERVAL '1 day',
    DATE '2025-04-01' + (n * 5) * INTERVAL '1 day',
    n || ' Rue du Chantier',
    LPAD((44000 + (n % 50))::TEXT, 5, '0'),
    (ARRAY['NANTES', 'RENNES', 'ANGERS', 'LE MANS', 'SAINT-NAZAIRE'])[((n-1) % 5) + 1],
    -- Avancement coherent avec etat: PREPARATION=0-10%, EN_COURS=10-90%, TERMINE/CLOTURE=100%
    CASE
        WHEN ((n-1) % 5) = 0 THEN (n % 10)::NUMERIC(5,2)  -- PREPARATION: 0-10%
        WHEN ((n-1) % 5) IN (1, 2) THEN (20 + (n * 7) % 70)::NUMERIC(5,2)  -- EN_COURS: 20-90%
        ELSE 100.00  -- TERMINE/CLOTURE: 100%
    END
FROM generate_series(1, 100) AS n;

-- Documents commerciaux MDE
INSERT INTO bronze.mde_document_entete (_source_id, societe_id, type_document, numero, date_document, tiers_id, tiers_code, tiers_type, affaire_id, affaire_code, objet, montant_ht, montant_tva, montant_ttc, taux_tva, statut, date_validation)
-- Devis (montants coherents: HT puis TVA=HT*0.20 puis TTC=HT*1.20)
SELECT
    n,
    1,
    'DEVIS',
    'DEV2025-' || LPAD(n::TEXT, 5, '0'),
    DATE '2025-01-01' + (n * 2) * INTERVAL '1 day',
    ((n-1) % 150) + 1,
    'C' || LPAD((((n-1) % 150) + 1)::TEXT, 4, '0'),
    'CLIENT',
    ((n-1) % 50) + 1,
    'AFF2025-' || LPAD((((n-1) % 50) + 1)::TEXT, 3, '0'),
    'Devis travaux electriques',
    montant_ht,
    (montant_ht * 0.20)::NUMERIC(15,2),
    (montant_ht * 1.20)::NUMERIC(15,2),
    20.00,
    (ARRAY['BROUILLON', 'ENVOYE', 'ACCEPTE', 'REFUSE'])[((n-1) % 4) + 1],
    CASE WHEN n % 4 = 3 THEN DATE '2025-01-05' + (n * 2) * INTERVAL '1 day' ELSE NULL END
FROM (
    SELECT n, (5000 + (n * 997) % 100000)::NUMERIC(15,2) AS montant_ht
    FROM generate_series(1, 100) AS n
) sub
UNION ALL
-- Factures (montants coherents)
SELECT
    100 + n,
    1,
    'FACTURE',
    'FAC2025-' || LPAD(n::TEXT, 5, '0'),
    DATE '2025-02-01' + (n * 3) * INTERVAL '1 day',
    ((n-1) % 150) + 1,
    'C' || LPAD((((n-1) % 150) + 1)::TEXT, 4, '0'),
    'CLIENT',
    ((n-1) % 40) + 1,
    'AFF2025-' || LPAD((((n-1) % 40) + 1)::TEXT, 3, '0'),
    'Facture travaux',
    montant_ht,
    (montant_ht * 0.20)::NUMERIC(15,2),
    (montant_ht * 1.20)::NUMERIC(15,2),
    20.00,
    'VALIDEE',
    DATE '2025-02-05' + (n * 3) * INTERVAL '1 day'
FROM (
    SELECT n, (3000 + (n * 853) % 80000)::NUMERIC(15,2) AS montant_ht
    FROM generate_series(1, 80) AS n
) sub;

-- Lignes documents
INSERT INTO bronze.mde_document_ligne (_source_id, entete_id, numero_ligne, element_id, element_code, designation, quantite, unite, prix_unitaire, remise_pct, montant_ht, taux_tva)
SELECT
    (d._source_id - 1) * 5 + l,
    d._source_id,
    l,
    ((d._source_id + l) % 770) + 1,
    'CAB' || LPAD((((d._source_id + l) % 200) + 1)::TEXT, 5, '0'),
    'Article ligne ' || l,
    (1 + RANDOM() * 100)::NUMERIC(15,4),
    'U',
    (10 + RANDOM() * 500)::NUMERIC(15,4),
    0,
    ((1 + RANDOM() * 100) * (10 + RANDOM() * 500))::NUMERIC(15,2),
    20.00
FROM bronze.mde_document_entete d
CROSS JOIN generate_series(1, 5) AS l;

-- Suivi main d'oeuvre MDE (6 mois)
INSERT INTO bronze.mde_suivi_mo (_source_id, societe_id, salarie_id, salarie_matricule, affaire_id, affaire_code, chantier_id, semaine_iso, date_debut_semaine, heures_normales, heures_supp_25, heures_supp_50, heures_nuit, heures_dimanche, heures_deplacement, indemnites_repas, indemnites_trajet)
SELECT
    ROW_NUMBER() OVER(),
    1,
    s._source_id,
    s.matricule,
    a._source_id,
    a.code,
    ((s._source_id + a._source_id) % 100) + 1,
    TO_CHAR(d, 'IYYY') || '-W' || LPAD(EXTRACT(WEEK FROM d)::TEXT, 2, '0'),
    DATE_TRUNC('week', d)::DATE,
    (30 + RANDOM() * 9)::NUMERIC(6,2),
    (RANDOM() * 5)::NUMERIC(6,2),
    (RANDOM() * 3)::NUMERIC(6,2),
    0,
    0,
    (RANDOM() * 2)::NUMERIC(6,2),
    (5 * 12.50)::NUMERIC(8,2),
    (5 * 8.50)::NUMERIC(8,2)
FROM bronze.mde_salarie s
CROSS JOIN bronze.mde_affaire a
CROSS JOIN generate_series(DATE '2025-01-01', DATE '2025-06-30', INTERVAL '1 week') AS d
WHERE a.etat IN ('EN_COURS', 'TERMINE')
AND s._source_id <= 60
AND RANDOM() < 0.1; -- 10% des combinaisons

-- Mouvements stock MDE
INSERT INTO bronze.mde_mouvement_stock (_source_id, societe_id, depot_id, depot_code, element_id, element_code, type_mouvement, date_mouvement, quantite, prix_unitaire, affaire_id, reference)
SELECT
    n,
    1,
    1,
    'DEP01',
    ((n-1) % 650) + 1,
    CASE
        WHEN (n % 650) < 200 THEN 'CAB' || LPAD(((n % 200) + 1)::TEXT, 5, '0')
        WHEN (n % 650) < 400 THEN 'APP' || LPAD((((n-200) % 200) + 1)::TEXT, 5, '0')
        ELSE 'TAB' || LPAD((((n-400) % 100) + 1)::TEXT, 5, '0')
    END,
    (ARRAY['ENTREE', 'SORTIE', 'SORTIE', 'SORTIE'])[((n-1) % 4) + 1],
    DATE '2025-01-01' + (n % 180) * INTERVAL '1 day',
    (1 + RANDOM() * 50)::NUMERIC(15,4),
    (1 + RANDOM() * 100)::NUMERIC(15,4),
    CASE WHEN n % 4 != 1 THEN ((n-1) % 50) + 1 ELSE NULL END,
    'MVT-' || LPAD(n::TEXT, 6, '0')
FROM generate_series(1, 500) AS n;

-- ============================================================================
-- 3. EXECUTION ETL INITIAL
-- ============================================================================

\echo 'Execution ETL Bronze -> Silver...'
CALL etl.run_bronze_to_silver();

\echo 'Execution ETL Silver -> Gold...'
CALL etl.run_silver_to_gold();

-- ============================================================================
-- 4. VERIFICATION
-- ============================================================================

\echo 'Verification des donnees chargees...'

SELECT 'BRONZE' AS layer, table_name, row_count FROM bronze.v_ingestion_stats ORDER BY table_name;

SELECT 'SILVER DIMENSIONS' AS info,
    (SELECT COUNT(*) FROM silver.dim_societe WHERE is_current) AS societes,
    (SELECT COUNT(*) FROM silver.dim_client WHERE is_current) AS clients,
    (SELECT COUNT(*) FROM silver.dim_fournisseur WHERE is_current) AS fournisseurs,
    (SELECT COUNT(*) FROM silver.dim_salarie WHERE is_current) AS salaries,
    (SELECT COUNT(*) FROM silver.dim_element WHERE is_current) AS elements,
    (SELECT COUNT(*) FROM silver.dim_affaire WHERE is_current) AS affaires;

SELECT 'SILVER FAITS' AS info,
    (SELECT COUNT(*) FROM silver.fact_ecriture_compta) AS ecritures,
    (SELECT COUNT(*) FROM silver.fact_document_commercial) AS documents,
    (SELECT COUNT(*) FROM silver.fact_suivi_mo) AS suivi_mo,
    (SELECT COUNT(*) FROM silver.fact_mouvement_stock) AS mvt_stock;

SELECT 'GOLD KPIS' AS info, * FROM gold.kpi_global LIMIT 5;

-- ============================================================================
-- FIN SEED INITIAL
-- ============================================================================

\echo 'Seed initial du Data Warehouse termine avec succes!'

-- ============================================================
-- Script de complétion des données MDE ERP
-- Généré automatiquement pour atteindre les objectifs du README
-- ============================================================

BEGIN;

-- ============================================================
-- 1. COMPLETER ref.element (33 → 800+)
-- ============================================================

-- Fournitures électriques (nature_id=1)
INSERT INTO ref.element (societe_id, code, designation, nature_id, bibliotheque_id, famille, sous_famille, unite_mesure_code, prix_achat, prix_vente, taux_tva_id, gere_en_stock)
SELECT
    s.id,
    'FOU-' || LPAD(n::text, 4, '0'),
    CASE (n % 20)
        WHEN 0 THEN 'Câble électrique ' || (n % 10 + 1) || 'x' || ((n % 4 + 1) * 1.5) || 'mm²'
        WHEN 1 THEN 'Disjoncteur différentiel ' || ((n % 4 + 1) * 10) || 'A'
        WHEN 2 THEN 'Interrupteur ' || CASE WHEN n % 2 = 0 THEN 'simple' ELSE 'double' END
        WHEN 3 THEN 'Prise électrique ' || CASE WHEN n % 3 = 0 THEN '16A' ELSE '32A' END
        WHEN 4 THEN 'Tableau électrique ' || ((n % 3 + 1) * 12) || ' modules'
        WHEN 5 THEN 'Gaine ICTA ' || ((n % 4 + 1) * 16) || 'mm'
        WHEN 6 THEN 'Boîte de dérivation ' || CASE WHEN n % 2 = 0 THEN 'carrée' ELSE 'ronde' END
        WHEN 7 THEN 'Spot LED ' || ((n % 4 + 1) * 5) || 'W'
        WHEN 8 THEN 'Applique murale ' || CASE WHEN n % 2 = 0 THEN 'intérieure' ELSE 'extérieure' END
        WHEN 9 THEN 'Tube LED T8 ' || ((n % 3 + 1) * 60) || 'cm'
        WHEN 10 THEN 'Détecteur de mouvement ' || CASE WHEN n % 2 = 0 THEN 'intérieur' ELSE 'extérieur' END
        WHEN 11 THEN 'Variateur ' || CASE WHEN n % 2 = 0 THEN 'rotatif' ELSE 'tactile' END
        WHEN 12 THEN 'Bornier ' || ((n % 4 + 1) * 4) || ' bornes'
        WHEN 13 THEN 'Fusible ' || ((n % 5 + 1) * 2) || 'A'
        WHEN 14 THEN 'Parafoudre ' || CASE WHEN n % 2 = 0 THEN 'monophasé' ELSE 'triphasé' END
        WHEN 15 THEN 'Télérupteur ' || ((n % 3 + 1) * 10) || 'A'
        WHEN 16 THEN 'Contacteur ' || ((n % 4 + 1) * 16) || 'A'
        WHEN 17 THEN 'Minuterie ' || CASE WHEN n % 2 = 0 THEN 'mécanique' ELSE 'électronique' END
        WHEN 18 THEN 'Programmateur horaire ' || CASE WHEN n % 2 = 0 THEN 'journalier' ELSE 'hebdomadaire' END
        ELSE 'Accessoire électrique divers n°' || n
    END,
    1, -- nature_id = FOU
    (n % 5) + 1, -- bibliotheque_id
    CASE (n % 5)
        WHEN 0 THEN 'CABLES'
        WHEN 1 THEN 'PROTECTION'
        WHEN 2 THEN 'APPAREILLAGE'
        WHEN 3 THEN 'ECLAIRAGE'
        ELSE 'ACCESSOIRES'
    END,
    CASE (n % 3) WHEN 0 THEN 'STANDARD' WHEN 1 THEN 'PREMIUM' ELSE 'ECO' END,
    CASE (n % 4) WHEN 0 THEN 'ML' WHEN 1 THEN 'U' WHEN 2 THEN 'ENS' ELSE 'LOT' END,
    (5 + (n % 50))::numeric,
    ((5 + (n % 50)) * 1.8)::numeric,
    1, -- TVA 20%
    true
FROM ref.societe s
CROSS JOIN generate_series(1, 200) n
WHERE NOT EXISTS (SELECT 1 FROM ref.element WHERE code = 'FOU-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- Matériaux de construction (nature_id=3)
INSERT INTO ref.element (societe_id, code, designation, nature_id, famille, sous_famille, unite_mesure_code, prix_achat, prix_vente, taux_tva_id, gere_en_stock)
SELECT
    s.id,
    'MAT-' || LPAD(n::text, 4, '0'),
    CASE (n % 15)
        WHEN 0 THEN 'Ciment CEM II ' || ((n % 3 + 1) * 25) || 'kg'
        WHEN 1 THEN 'Sable ' || CASE WHEN n % 2 = 0 THEN '0/4' ELSE '0/2' END || ' big bag'
        WHEN 2 THEN 'Gravier ' || ((n % 3 + 1) * 4) || '/' || ((n % 3 + 2) * 4)
        WHEN 3 THEN 'Parpaing ' || ((n % 3 + 1) * 10) || 'x20x50'
        WHEN 4 THEN 'Brique ' || CASE WHEN n % 2 = 0 THEN 'plâtrière' ELSE 'rouge' END
        WHEN 5 THEN 'Plaque BA' || ((n % 2 + 1) * 13)
        WHEN 6 THEN 'Rail métallique ' || ((n % 3 + 1) * 48) || 'mm'
        WHEN 7 THEN 'Montant métallique ' || ((n % 3 + 1) * 48) || 'mm'
        WHEN 8 THEN 'Vis à placo ' || ((n % 3 + 1) * 25) || 'mm'
        WHEN 9 THEN 'Enduit ' || CASE WHEN n % 3 = 0 THEN 'de rebouchage' WHEN n % 3 = 1 THEN 'de lissage' ELSE 'projeté' END
        WHEN 10 THEN 'Isolant laine ' || CASE WHEN n % 2 = 0 THEN 'de verre' ELSE 'de roche' END || ' ' || ((n % 4 + 1) * 50) || 'mm'
        WHEN 11 THEN 'Polystyrène ' || ((n % 6 + 1) * 20) || 'mm'
        WHEN 12 THEN 'Mortier-colle ' || CASE WHEN n % 2 = 0 THEN 'standard' ELSE 'flex' END
        WHEN 13 THEN 'Joint carrelage ' || CASE WHEN n % 3 = 0 THEN 'blanc' WHEN n % 3 = 1 THEN 'gris' ELSE 'beige' END
        ELSE 'Matériau construction n°' || n
    END,
    3, -- nature_id = MAT
    CASE (n % 4) WHEN 0 THEN 'GROS_OEUVRE' WHEN 1 THEN 'PLATRERIE' WHEN 2 THEN 'ISOLATION' ELSE 'CARRELAGE' END,
    'STANDARD',
    CASE (n % 5) WHEN 0 THEN 'U' WHEN 1 THEN 'M3' WHEN 2 THEN 'M2' WHEN 3 THEN 'KG' ELSE 'LOT' END,
    (10 + (n % 100))::numeric,
    ((10 + (n % 100)) * 1.5)::numeric,
    1,
    true
FROM ref.societe s
CROSS JOIN generate_series(1, 150) n
WHERE NOT EXISTS (SELECT 1 FROM ref.element WHERE code = 'MAT-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- Main d'oeuvre (nature_id=2)
INSERT INTO ref.element (societe_id, code, designation, nature_id, famille, unite_mesure_code, prix_achat, prix_vente, taux_tva_id, gere_en_stock)
SELECT
    s.id,
    'MO-' || LPAD(n::text, 4, '0'),
    CASE (n % 10)
        WHEN 0 THEN 'Heure électricien N' || ((n % 4) + 1)
        WHEN 1 THEN 'Heure maçon N' || ((n % 4) + 1)
        WHEN 2 THEN 'Heure plaquiste N' || ((n % 4) + 1)
        WHEN 3 THEN 'Heure carreleur N' || ((n % 4) + 1)
        WHEN 4 THEN 'Heure plombier N' || ((n % 4) + 1)
        WHEN 5 THEN 'Heure peintre N' || ((n % 4) + 1)
        WHEN 6 THEN 'Heure chef équipe'
        WHEN 7 THEN 'Heure conducteur travaux'
        WHEN 8 THEN 'Heure apprenti'
        ELSE 'Heure main d''oeuvre diverse'
    END,
    2, -- nature_id = MO
    'MAIN_OEUVRE',
    'H',
    (25 + (n % 30))::numeric,
    ((25 + (n % 30)) * 2.2)::numeric,
    1,
    false
FROM ref.societe s
CROSS JOIN generate_series(1, 50) n
WHERE NOT EXISTS (SELECT 1 FROM ref.element WHERE code = 'MO-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- Ouvrages composés (nature_id=6)
INSERT INTO ref.element (societe_id, code, designation, nature_id, famille, unite_mesure_code, prix_achat, prix_vente, taux_tva_id, gere_en_stock)
SELECT
    s.id,
    'OUV-' || LPAD(n::text, 4, '0'),
    CASE (n % 12)
        WHEN 0 THEN 'Installation tableau électrique ' || ((n % 3 + 1) * 12) || ' modules complet'
        WHEN 1 THEN 'Pose circuit éclairage complet pièce'
        WHEN 2 THEN 'Pose circuit prises pièce ' || ((n % 4 + 1) * 2) || ' prises'
        WHEN 3 THEN 'Installation VMC ' || CASE WHEN n % 2 = 0 THEN 'simple flux' ELSE 'double flux' END
        WHEN 4 THEN 'Rénovation installation électrique appartement T' || ((n % 4) + 1)
        WHEN 5 THEN 'Mise aux normes tableau principal'
        WHEN 6 THEN 'Pose cloison placo ' || ((n % 4 + 1) * 72) || 'mm'
        WHEN 7 THEN 'Chape béton ' || ((n % 3 + 1) * 5) || 'cm'
        WHEN 8 THEN 'Pose carrelage sol ' || CASE WHEN n % 2 = 0 THEN 'standard' ELSE 'grand format' END
        WHEN 9 THEN 'Création ouverture mur porteur'
        WHEN 10 THEN 'Isolation combles ' || ((n % 4 + 1) * 100) || 'mm'
        ELSE 'Ouvrage complet n°' || n
    END,
    6, -- nature_id = OUV
    CASE (n % 4) WHEN 0 THEN 'ELECTRICITE' WHEN 1 THEN 'PLATRERIE' WHEN 2 THEN 'MACONNERIE' ELSE 'ISOLATION' END,
    CASE (n % 3) WHEN 0 THEN 'U' WHEN 1 THEN 'M2' ELSE 'ENS' END,
    (150 + (n % 500))::numeric,
    ((150 + (n % 500)) * 1.6)::numeric,
    1,
    false
FROM ref.societe s
CROSS JOIN generate_series(1, 100) n
WHERE NOT EXISTS (SELECT 1 FROM ref.element WHERE code = 'OUV-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- ============================================================
-- 2. COMPLETER tiers.client (128 → 150+)
-- ============================================================

INSERT INTO tiers.client (societe_id, code, intitule, siret, adresse_ligne1, code_postal, ville, pays_code, telephone, email, mode_reglement_code, devise_code)
SELECT
    s.id,
    'CLI' || LPAD((128 + n)::text, 4, '0'),
    CASE (n % 10)
        WHEN 0 THEN 'SARL ' || chr(65 + (n % 26)) || chr(65 + ((n + 5) % 26)) || ' Construction'
        WHEN 1 THEN 'SCI ' || chr(65 + (n % 26)) || chr(65 + ((n + 3) % 26)) || chr(65 + ((n + 7) % 26))
        WHEN 2 THEN 'Résidence ' || CASE WHEN n % 5 = 0 THEN 'Les Chênes' WHEN n % 5 = 1 THEN 'Le Parc' WHEN n % 5 = 2 THEN 'Les Jardins' WHEN n % 5 = 3 THEN 'Bel Air' ELSE 'Les Terrasses' END
        WHEN 3 THEN 'M. ' || chr(65 + (n % 26)) || '. DUPONT'
        WHEN 4 THEN 'Mme ' || chr(65 + (n % 26)) || '. MARTIN'
        WHEN 5 THEN 'Copropriété ' || CASE WHEN n % 4 = 0 THEN 'Bellevue' WHEN n % 4 = 1 THEN 'Panorama' WHEN n % 4 = 2 THEN 'Les Oliviers' ELSE 'Le Clos' END
        WHEN 6 THEN 'SAS ' || chr(65 + (n % 26)) || chr(65 + ((n + 2) % 26)) || ' Immobilier'
        WHEN 7 THEN 'Mairie de ' || CASE WHEN n % 6 = 0 THEN 'Villefranche' WHEN n % 6 = 1 THEN 'Saint-Martin' WHEN n % 6 = 2 THEN 'Beaumont' WHEN n % 6 = 3 THEN 'Montclair' WHEN n % 6 = 4 THEN 'Clairvaux' ELSE 'Belfort' END
        WHEN 8 THEN 'Lycée ' || CASE WHEN n % 3 = 0 THEN 'Jean Moulin' WHEN n % 3 = 1 THEN 'Victor Hugo' ELSE 'Marie Curie' END
        ELSE 'Entreprise ' || chr(65 + (n % 26)) || chr(65 + ((n + 4) % 26)) || chr(65 + ((n + 8) % 26))
    END,
    LPAD((100000000 + n * 12345)::text, 14, '0'),
    (n % 200 + 1)::text || ' rue ' || CASE WHEN n % 5 = 0 THEN 'de la Paix' WHEN n % 5 = 1 THEN 'Jean Jaurès' WHEN n % 5 = 2 THEN 'Victor Hugo' WHEN n % 5 = 3 THEN 'de la Liberté' ELSE 'du Commerce' END,
    LPAD((10000 + (n * 137) % 89999)::text, 5, '0'),
    CASE (n % 10) WHEN 0 THEN 'Lyon' WHEN 1 THEN 'Marseille' WHEN 2 THEN 'Paris' WHEN 3 THEN 'Toulouse' WHEN 4 THEN 'Bordeaux' WHEN 5 THEN 'Nantes' WHEN 6 THEN 'Lille' WHEN 7 THEN 'Nice' WHEN 8 THEN 'Strasbourg' ELSE 'Montpellier' END,
    'FR',
    '0' || (n % 5 + 1)::text || ' ' || LPAD((10000000 + n * 7654)::text, 8, '0'),
    'contact' || (128 + n)::text || '@client.fr',
    CASE (n % 4) WHEN 0 THEN '30J' WHEN 1 THEN '30FM' WHEN 2 THEN '45FM' ELSE '60FM' END,
    'EUR'
FROM ref.societe s
CROSS JOIN generate_series(1, 30) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM tiers.client WHERE code = 'CLI' || LPAD((128 + n)::text, 4, '0') AND societe_id = s.id);

-- ============================================================
-- 3. COMPLETER tiers.fournisseur (26 → 80+)
-- ============================================================

INSERT INTO tiers.fournisseur (societe_id, code, intitule, siret, adresse_ligne1, code_postal, ville, pays_code, telephone, email, mode_reglement_code, devise_code, delai_livraison)
SELECT
    s.id,
    'FRN' || LPAD((26 + n)::text, 4, '0'),
    CASE (n % 12)
        WHEN 0 THEN 'REXEL Distribution ' || chr(65 + (n % 26))
        WHEN 1 THEN 'SONEPAR Agence ' || (n % 50 + 1)::text
        WHEN 2 THEN 'POINT P Matériaux ' || chr(65 + (n % 26))
        WHEN 3 THEN 'CEDEO Sanitaire Pro'
        WHEN 4 THEN 'Legrand Distribution'
        WHEN 5 THEN 'SCHNEIDER Electric Pro'
        WHEN 6 THEN 'BigMat ' || CASE WHEN n % 3 = 0 THEN 'Nord' WHEN n % 3 = 1 THEN 'Sud' ELSE 'Est' END
        WHEN 7 THEN 'ISOVER France'
        WHEN 8 THEN 'KNAUF Isolation'
        WHEN 9 THEN 'LAFARGE Ciments'
        WHEN 10 THEN 'SAINT-GOBAIN Distribution'
        ELSE 'Fournisseur BTP ' || chr(65 + (n % 26)) || (n % 100)::text
    END,
    LPAD((200000000 + n * 54321)::text, 14, '0'),
    'ZI ' || CASE WHEN n % 4 = 0 THEN 'Nord' WHEN n % 4 = 1 THEN 'Sud' WHEN n % 4 = 2 THEN 'Est' ELSE 'Ouest' END || ' - Rue ' || (n % 100 + 1)::text,
    LPAD((10000 + (n * 251) % 89999)::text, 5, '0'),
    CASE (n % 8) WHEN 0 THEN 'Lyon' WHEN 1 THEN 'Paris' WHEN 2 THEN 'Marseille' WHEN 3 THEN 'Bordeaux' WHEN 4 THEN 'Lille' WHEN 5 THEN 'Nantes' WHEN 6 THEN 'Toulouse' ELSE 'Strasbourg' END,
    'FR',
    '0' || ((n % 5) + 1)::text || ' ' || LPAD((20000000 + n * 8765)::text, 8, '0'),
    'pro' || (26 + n)::text || '@fournisseur.fr',
    CASE (n % 3) WHEN 0 THEN '30FM' WHEN 1 THEN '45FM' ELSE '60FM' END,
    'EUR',
    (n % 15 + 1)
FROM ref.societe s
CROSS JOIN generate_series(1, 60) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM tiers.fournisseur WHERE code = 'FRN' || LPAD((26 + n)::text, 4, '0') AND societe_id = s.id);

-- ============================================================
-- 4. COMPLETER tiers.salarie (79 → 100)
-- ============================================================

INSERT INTO tiers.salarie (societe_id, code, matricule, nom, prenom, adresse, code_postal, ville, telephone, portable, email, fonction, service, date_entree, type_contrat, qualification, cout_horaire, cout_journalier, actif, conducteur_travaux, chef_equipe)
SELECT
    s.id,
    'SAL' || LPAD((79 + n)::text, 4, '0'),
    'M' || LPAD((79 + n)::text, 5, '0'),
    CASE (n % 10) WHEN 0 THEN 'BERNARD' WHEN 1 THEN 'THOMAS' WHEN 2 THEN 'PETIT' WHEN 3 THEN 'ROBERT' WHEN 4 THEN 'RICHARD' WHEN 5 THEN 'DURAND' WHEN 6 THEN 'MOREAU' WHEN 7 THEN 'SIMON' WHEN 8 THEN 'LAURENT' ELSE 'LEROY' END,
    CASE (n % 8) WHEN 0 THEN 'Pierre' WHEN 1 THEN 'Jean' WHEN 2 THEN 'Michel' WHEN 3 THEN 'Philippe' WHEN 4 THEN 'François' WHEN 5 THEN 'Jacques' WHEN 6 THEN 'André' ELSE 'Alain' END,
    (n % 150 + 1)::text || ' rue ' || CASE WHEN n % 4 = 0 THEN 'de la République' WHEN n % 4 = 1 THEN 'Jean Jaurès' WHEN n % 4 = 2 THEN 'Pasteur' ELSE 'Gambetta' END,
    LPAD((10000 + (n * 173) % 89999)::text, 5, '0'),
    CASE (n % 6) WHEN 0 THEN 'Lyon' WHEN 1 THEN 'Villeurbanne' WHEN 2 THEN 'Vénissieux' WHEN 3 THEN 'Bron' WHEN 4 THEN 'Caluire' ELSE 'Saint-Priest' END,
    '04 ' || LPAD((70000000 + n * 1234)::text, 8, ' '),
    '06 ' || LPAD((10000000 + n * 5678)::text, 8, ' '),
    'salarie' || (79 + n)::text || '@duret.fr',
    CASE (n % 6) WHEN 0 THEN 'Électricien' WHEN 1 THEN 'Maçon' WHEN 2 THEN 'Plaquiste' WHEN 3 THEN 'Plombier' WHEN 4 THEN 'Peintre' ELSE 'Manœuvre' END,
    CASE (n % 3) WHEN 0 THEN 'PRODUCTION' WHEN 1 THEN 'TECHNIQUE' ELSE 'CHANTIER' END,
    ('2023-01-01'::date + (n * 30)::integer),
    CASE (n % 4) WHEN 0 THEN 'CDI' WHEN 1 THEN 'CDD' WHEN 2 THEN 'INTERIM' ELSE 'APPRENTI' END,
    'N' || ((n % 4) + 1)::text,
    (25 + (n % 20))::numeric,
    ((25 + (n % 20)) * 7.5)::numeric,
    true,
    false,
    (n % 10 = 0)
FROM ref.societe s
CROSS JOIN generate_series(1, 25) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM tiers.salarie WHERE code = 'SAL' || LPAD((79 + n)::text, 4, '0') AND societe_id = s.id);

-- ============================================================
-- 5. COMPLETER chantier.chantier (12 → 75)
-- ============================================================

INSERT INTO chantier.chantier (societe_id, affaire_id, code, intitule, client_id, adresse, code_postal, ville, nature_travaux_id, conducteur_travaux_id, chef_equipe_id, etat, date_debut_prevue, date_fin_prevue, montant_ht, pct_avancement)
SELECT
    s.id,
    (SELECT id FROM affaire.affaire WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    'CHT' || LPAD((12 + n)::text, 4, '0'),
    CASE (n % 10)
        WHEN 0 THEN 'Rénovation appartement T' || ((n % 4) + 1) || ' ' || CASE WHEN n % 3 = 0 THEN 'Lyon' WHEN n % 3 = 1 THEN 'Villeurbanne' ELSE 'Bron' END
        WHEN 1 THEN 'Construction maison individuelle ' || CASE WHEN n % 4 = 0 THEN 'plain-pied' WHEN n % 4 = 1 THEN 'R+1' WHEN n % 4 = 2 THEN 'contemporaine' ELSE 'traditionnelle' END
        WHEN 2 THEN 'Extension ' || ((n % 3 + 1) * 20)::text || 'm² ' || CASE WHEN n % 2 = 0 THEN 'garage' ELSE 'véranda' END
        WHEN 3 THEN 'Mise aux normes électriques ' || CASE WHEN n % 2 = 0 THEN 'local commercial' ELSE 'immeuble' END
        WHEN 4 THEN 'Isolation thermique ' || CASE WHEN n % 3 = 0 THEN 'combles' WHEN n % 3 = 1 THEN 'murs' ELSE 'toiture' END
        WHEN 5 THEN 'Création local ' || CASE WHEN n % 3 = 0 THEN 'commercial' WHEN n % 3 = 1 THEN 'professionnel' ELSE 'artisanal' END
        WHEN 6 THEN 'Aménagement ' || ((n % 3 + 1) * 50)::text || 'm² bureaux'
        WHEN 7 THEN 'Réhabilitation ' || CASE WHEN n % 2 = 0 THEN 'entrepôt' ELSE 'atelier' END
        WHEN 8 THEN 'Surélévation immeuble ' || ((n % 2) + 1)::text || ' niveau(x)'
        ELSE 'Travaux divers chantier n°' || n
    END,
    (SELECT id FROM tiers.client WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (n % 200 + 1)::text || ' ' || CASE WHEN n % 5 = 0 THEN 'avenue' WHEN n % 5 = 1 THEN 'rue' WHEN n % 5 = 2 THEN 'boulevard' WHEN n % 5 = 3 THEN 'place' ELSE 'chemin' END || ' ' || CASE WHEN n % 4 = 0 THEN 'de la Gare' WHEN n % 4 = 1 THEN 'du Général de Gaulle' WHEN n % 4 = 2 THEN 'des Lilas' ELSE 'Jean Moulin' END,
    LPAD((69000 + (n % 10))::text, 5, '0'),
    CASE (n % 8) WHEN 0 THEN 'Lyon' WHEN 1 THEN 'Villeurbanne' WHEN 2 THEN 'Vénissieux' WHEN 3 THEN 'Bron' WHEN 4 THEN 'Caluire' WHEN 5 THEN 'Saint-Priest' WHEN 6 THEN 'Oullins' ELSE 'Écully' END,
    (n % 13) + 1,
    (SELECT id FROM tiers.salarie WHERE societe_id = s.id AND conducteur_travaux = true ORDER BY random() LIMIT 1),
    (SELECT id FROM tiers.salarie WHERE societe_id = s.id AND chef_equipe = true ORDER BY random() LIMIT 1),
    CASE (n % 5)
        WHEN 0 THEN 'A_PLANIFIER'::ref.etat_chantier
        WHEN 1 THEN 'PLANIFIE'::ref.etat_chantier
        WHEN 2 THEN 'EN_COURS'::ref.etat_chantier
        WHEN 3 THEN 'TERMINE'::ref.etat_chantier
        ELSE 'EN_COURS'::ref.etat_chantier
    END,
    ('2025-01-01'::date + (n * 5)::integer),
    ('2025-01-01'::date + (n * 5 + 30 + (n % 60))::integer),
    (10000 + (n * 3000) % 150000)::numeric,
    CASE (n % 5)
        WHEN 3 THEN 100
        WHEN 4 THEN 100
        ELSE (n * 17 % 100)::numeric
    END
FROM ref.societe s
CROSS JOIN generate_series(1, 65) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM chantier.chantier WHERE code = 'CHT' || LPAD((12 + n)::text, 4, '0') AND societe_id = s.id);

-- ============================================================
-- 6. COMPLETER document.entete_document (40 → 200)
-- ============================================================

-- Devis
INSERT INTO document.entete_document (societe_id, type_document, numero, date_document, date_validite, tiers_type, tiers_id, affaire_id, chantier_id, redacteur_id, mode_reglement_code, devise_code, montant_ht, montant_tva, montant_ttc, etat_id)
SELECT
    s.id,
    'DEVIS'::ref.type_document,
    'DEV' || TO_CHAR('2025-01-01'::date + (n)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0'),
    '2025-01-01'::date + (n)::integer,
    '2025-01-01'::date + (n + 30)::integer,
    'CLIENT'::ref.type_tiers,
    (SELECT id FROM tiers.client WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM affaire.affaire WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    NULL,
    (SELECT id FROM tiers.salarie WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    '30J',
    'EUR',
    (5000 + (n * 1500) % 50000)::numeric,
    ((5000 + (n * 1500) % 50000) * 0.2)::numeric,
    ((5000 + (n * 1500) % 50000) * 1.2)::numeric,
    (n % 4) + 1
FROM ref.societe s
CROSS JOIN generate_series(1, 60) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM document.entete_document WHERE numero = 'DEV' || TO_CHAR('2025-01-01'::date + (n)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- Factures
INSERT INTO document.entete_document (societe_id, type_document, numero, date_document, tiers_type, tiers_id, affaire_id, chantier_id, redacteur_id, mode_reglement_code, devise_code, montant_ht, montant_tva, montant_ttc, etat_id)
SELECT
    s.id,
    'FACTURE'::ref.type_document,
    'FAC' || TO_CHAR('2025-01-01'::date + (n * 3)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0'),
    '2025-01-01'::date + (n * 3)::integer,
    'CLIENT'::ref.type_tiers,
    (SELECT id FROM tiers.client WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM affaire.affaire WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM chantier.chantier WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM tiers.salarie WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    '30FM',
    'EUR',
    (8000 + (n * 2500) % 80000)::numeric,
    ((8000 + (n * 2500) % 80000) * 0.2)::numeric,
    ((8000 + (n * 2500) % 80000) * 1.2)::numeric,
    3 -- Validé
FROM ref.societe s
CROSS JOIN generate_series(1, 50) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM document.entete_document WHERE numero = 'FAC' || TO_CHAR('2025-01-01'::date + (n * 3)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

-- Commandes fournisseurs
INSERT INTO document.entete_document (societe_id, type_document, numero, date_document, date_livraison, tiers_type, tiers_id, affaire_id, chantier_id, redacteur_id, mode_reglement_code, devise_code, montant_ht, montant_tva, montant_ttc, etat_id)
SELECT
    s.id,
    'COMMANDE'::ref.type_document,
    'CDE' || TO_CHAR('2025-01-01'::date + (n * 2)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0'),
    '2025-01-01'::date + (n * 2)::integer,
    '2025-01-01'::date + (n * 2 + 15)::integer,
    'FOURNISSEUR'::ref.type_tiers,
    (SELECT id FROM tiers.fournisseur WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM affaire.affaire WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM chantier.chantier WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    (SELECT id FROM tiers.salarie WHERE societe_id = s.id ORDER BY random() LIMIT 1),
    '45FM',
    'EUR',
    (2000 + (n * 800) % 25000)::numeric,
    ((2000 + (n * 800) % 25000) * 0.2)::numeric,
    ((2000 + (n * 800) % 25000) * 1.2)::numeric,
    3
FROM ref.societe s
CROSS JOIN generate_series(1, 55) n
WHERE s.id = 1
AND NOT EXISTS (SELECT 1 FROM document.entete_document WHERE numero = 'CDE' || TO_CHAR('2025-01-01'::date + (n * 2)::integer, 'YYMM') || '-' || LPAD(n::text, 4, '0') AND societe_id = s.id);

COMMIT;

-- Afficher les statistiques finales
SELECT 'ref.element' as table_name, COUNT(*) as total FROM ref.element
UNION ALL SELECT 'tiers.client', COUNT(*) FROM tiers.client
UNION ALL SELECT 'tiers.fournisseur', COUNT(*) FROM tiers.fournisseur
UNION ALL SELECT 'tiers.salarie', COUNT(*) FROM tiers.salarie
UNION ALL SELECT 'chantier.chantier', COUNT(*) FROM chantier.chantier
UNION ALL SELECT 'document.entete_document', COUNT(*) FROM document.entete_document
ORDER BY table_name;

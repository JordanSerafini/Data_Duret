-- ============================================================================
-- MDE ERP - SEED DATA COMPLET
-- Donnees de demonstration realistes pour le Groupe DURET
-- ============================================================================

\c mde_erp;

-- ============================================================================
-- 1. REFERENTIELS DE BASE
-- ============================================================================

-- Devises
INSERT INTO ref.devise (code, nom, symbole, taux_euro, code_iso) VALUES
('EUR', 'Euro', '€', 1.000000, 'EUR'),
('USD', 'Dollar US', '$', 1.085000, 'USD'),
('GBP', 'Livre Sterling', '£', 0.858000, 'GBP'),
('CHF', 'Franc Suisse', 'CHF', 0.945000, 'CHF');

-- Pays
INSERT INTO ref.pays (code, nom, code_devise, code_nomenclature_deb) VALUES
('FR', 'France', 'EUR', 'FR'),
('BE', 'Belgique', 'EUR', 'BE'),
('DE', 'Allemagne', 'EUR', 'DE'),
('ES', 'Espagne', 'EUR', 'ES'),
('IT', 'Italie', 'EUR', 'IT'),
('CH', 'Suisse', 'CHF', 'CH'),
('GB', 'Royaume-Uni', 'GBP', 'GB'),
('LU', 'Luxembourg', 'EUR', 'LU');

-- Modes de reglement
INSERT INTO ref.mode_reglement (code, nom, nb_jours, fin_de_mois, type_paiement) VALUES
('CPT', 'Comptant', 0, FALSE, 'IMMEDIAT'),
('30J', '30 jours net', 30, FALSE, 'ECHEANCE'),
('30FM', '30 jours fin de mois', 30, TRUE, 'ECHEANCE'),
('45FM', '45 jours fin de mois', 45, TRUE, 'ECHEANCE'),
('60J', '60 jours net', 60, FALSE, 'ECHEANCE'),
('60FM', '60 jours fin de mois', 60, TRUE, 'ECHEANCE'),
('90FM', '90 jours fin de mois', 90, TRUE, 'ECHEANCE'),
('ACSIT', 'Acompte + Situation', 0, FALSE, 'SITUATION');

-- Unites de mesure
INSERT INTO ref.unite_mesure (code, libelle, type_unite) VALUES
('U', 'Unite', 'QUANTITE'),
('ML', 'Metre lineaire', 'LONGUEUR'),
('M2', 'Metre carre', 'SURFACE'),
('M3', 'Metre cube', 'VOLUME'),
('KG', 'Kilogramme', 'QUANTITE'),
('H', 'Heure', 'TEMPS'),
('J', 'Jour', 'TEMPS'),
('ENS', 'Ensemble', 'QUANTITE'),
('FT', 'Forfait', 'QUANTITE'),
('LOT', 'Lot', 'QUANTITE'),
('KM', 'Kilometre', 'LONGUEUR'),
('BOB', 'Bobine', 'QUANTITE'),
('RL', 'Rouleau', 'QUANTITE');

-- Taux de TVA
INSERT INTO ref.taux_tva (code, libelle, taux, compte_collecte, compte_deductible, actif) VALUES
('N20', 'TVA 20%', 20.00, '445710', '445660', TRUE),
('I10', 'TVA 10%', 10.00, '445710', '445660', TRUE),
('R55', 'TVA 5.5%', 5.50, '445710', '445660', TRUE),
('EXO', 'Exonere', 0.00, NULL, NULL, TRUE),
('AUT', 'Autoliquidation', 0.00, NULL, NULL, TRUE);

-- Categories achat/vente
INSERT INTO ref.categorie_av (code, libelle, type_categorie, journal_vente, journal_achat, tva_autoliquidee) VALUES
('V', 'Vente France', 'VENTE_FRANCE', 'VTE', NULL, FALSE),
('E', 'Vente CEE', 'VENTE_CEE', 'VTE', NULL, FALSE),
('X', 'Vente Export', 'VENTE_EXPORT', 'VTE', NULL, FALSE),
('A', 'Achat France', 'ACHAT_FRANCE', NULL, 'ACH', FALSE),
('C', 'Achat CEE', 'ACHAT_CEE', NULL, 'ACH', TRUE),
('I', 'Achat Import', 'ACHAT_IMPORT', NULL, 'ACH', FALSE);

-- Natures de travaux
INSERT INTO ref.nature_travaux (code, libelle) VALUES
('ELEC', 'Electricite generale'),
('CFO', 'Courants forts'),
('CFA', 'Courants faibles'),
('CVC', 'Chauffage Ventilation Climatisation'),
('PLB', 'Plomberie'),
('ENR', 'Energies renouvelables'),
('IRVE', 'Bornes de recharge VE'),
('DATA', 'Data center'),
('SEC', 'Securite incendie'),
('CTRL', 'Controle d''acces'),
('VDI', 'Voix Donnees Images'),
('AUTO', 'Automatisme'),
('MNT', 'Maintenance');

-- Types de marche
INSERT INTO ref.type_marche (code, libelle) VALUES
('PRIV', 'Marche prive'),
('PUB', 'Marche public'),
('MAPA', 'MAPA'),
('AO', 'Appel d''offres'),
('NEG', 'Marche negocie'),
('CONT', 'Contrat cadre'),
('MAINT', 'Contrat maintenance');

-- Etats d'affaire
INSERT INTO ref.etat_affaire_param (code, libelle, ordre, couleur) VALUES
('PROSP', 'Prospect', 10, '#CCCCCC'),
('ETUDE', 'En etude', 20, '#FFD700'),
('DEVIS', 'Devis envoye', 30, '#FFA500'),
('NEGO', 'En negociation', 40, '#FF8C00'),
('ACCEP', 'Accepte', 50, '#32CD32'),
('ENCRS', 'En cours', 60, '#1E90FF'),
('TERM', 'Termine', 70, '#228B22'),
('CLOT', 'Cloture', 80, '#006400'),
('PERDU', 'Perdu', 90, '#DC143C'),
('ANNUL', 'Annule', 100, '#8B0000');

-- Etats de chantier
INSERT INTO ref.etat_chantier_param (code, libelle, ordre) VALUES
('APLAN', 'A planifier', 10),
('PLAN', 'Planifie', 20),
('PREP', 'En preparation', 30),
('ENCRS', 'En cours', 40),
('SUSP', 'Suspendu', 50),
('TERM', 'Termine', 60),
('RECEP', 'Reception', 70),
('CLOT', 'Cloture', 80);

-- Etats de document
INSERT INTO ref.etat_document (code, libelle, type_document) VALUES
('D_BRO', 'Brouillon', 'DEVIS'),
('D_ENV', 'Envoye', 'DEVIS'),
('D_ACC', 'Accepte', 'DEVIS'),
('D_REF', 'Refuse', 'DEVIS'),
('C_BRO', 'Brouillon', 'COMMANDE'),
('C_VAL', 'Validee', 'COMMANDE'),
('C_LIV', 'Livree', 'COMMANDE'),
('F_BRO', 'Brouillon', 'FACTURE'),
('F_VAL', 'Validee', 'FACTURE'),
('F_ENV', 'Envoyee', 'FACTURE'),
('F_PAY', 'Payee', 'FACTURE');

-- Natures d'elements
INSERT INTO ref.config_nature_element (code, libelle, nature, compte_vente, compte_achat, taux_tva_id) VALUES
('FOU', 'Fournitures', 'FOURNITURE', '704100', '601200', 1),
('MO', 'Main d''oeuvre', 'MAIN_OEUVRE', '704100', '641100', 1),
('MAT', 'Materiel', 'MATERIEL', '704100', '612000', 1),
('SST', 'Sous-traitance', 'SOUS_TRAITANCE', '704100', '611000', 1),
('FRA', 'Frais', 'FRAIS', '708000', '625100', 1),
('OUV', 'Ouvrage', 'OUVRAGE', '704100', NULL, 1);

-- Postes de travaux
INSERT INTO ref.poste_travaux (code, libelle, niveau) VALUES
('01', 'Installation de chantier', 1),
('02', 'Terrassement - Genie civil', 1),
('03', 'Distribution generale', 1),
('04', 'Tableaux electriques', 1),
('05', 'Distribution secondaire', 1),
('06', 'Appareillage', 1),
('07', 'Eclairage', 1),
('08', 'Courants faibles', 1),
('09', 'Securite incendie', 1),
('10', 'Controle d''acces', 1),
('11', 'Photovoltaique', 1),
('12', 'Bornes IRVE', 1),
('99', 'Divers', 1);

INSERT INTO ref.poste_travaux (code, libelle, parent_id, niveau) VALUES
('0401', 'TGBT', (SELECT id FROM ref.poste_travaux WHERE code = '04'), 2),
('0402', 'Tableaux divisionnaires', (SELECT id FROM ref.poste_travaux WHERE code = '04'), 2),
('0403', 'Armoires', (SELECT id FROM ref.poste_travaux WHERE code = '04'), 2),
('0701', 'Eclairage interieur', (SELECT id FROM ref.poste_travaux WHERE code = '07'), 2),
('0702', 'Eclairage exterieur', (SELECT id FROM ref.poste_travaux WHERE code = '07'), 2),
('0703', 'Eclairage de securite', (SELECT id FROM ref.poste_travaux WHERE code = '07'), 2),
('0801', 'VDI', (SELECT id FROM ref.poste_travaux WHERE code = '08'), 2),
('0802', 'Video surveillance', (SELECT id FROM ref.poste_travaux WHERE code = '08'), 2),
('0803', 'Interphonie', (SELECT id FROM ref.poste_travaux WHERE code = '08'), 2);

-- Activites
INSERT INTO ref.activite (code, libelle) VALUES
('TER', 'Tertiaire'),
('IND', 'Industriel'),
('LOG', 'Logement'),
('COM', 'Commerce'),
('MNT', 'Maintenance'),
('ENR', 'Energies renouvelables'),
('DATA', 'Data Centers');

-- Secteurs geographiques
INSERT INTO ref.secteur_geo (code, libelle) VALUES
('LYON', 'Grand Lyon'),
('RHON', 'Rhone'),
('ISER', 'Isere'),
('DROM', 'Drome'),
('ARDE', 'Ardeche'),
('SAVO', 'Savoie'),
('HSAV', 'Haute-Savoie'),
('AURA', 'Auvergne-Rhone-Alpes'),
('PACA', 'PACA'),
('IDF', 'Ile de France');

-- Depots
INSERT INTO ref.depot (code, libelle, adresse, code_postal, ville, depot_principal, actif) VALUES
('SIEGE', 'Depot siege Villeurbanne', '15 Rue de l''Industrie', '69100', 'VILLEURBANNE', TRUE, TRUE),
('LYON', 'Depot Lyon', '22 Avenue des Reseaux', '69003', 'LYON', FALSE, TRUE),
('GREN', 'Depot Grenoble', '8 Zone Industrielle', '38000', 'GRENOBLE', FALSE, TRUE),
('ANNE', 'Depot Annecy', '12 Rue du Lac', '74000', 'ANNECY', FALSE, TRUE);

-- Societes (dossiers)
INSERT INTO ref.societe (code, raison_sociale, siret, code_ape, adresse, code_postal, ville, telephone, email, date_creation) VALUES
('DURETELEC', 'DURET ELECTRICITE SAS', '12345678901234', '4321A', '15 Rue de l''Industrie', '69100', 'VILLEURBANNE', '04 72 XX XX XX', 'contact@duret-elec.fr', '1985-03-15'),
('DURETENE', 'DURET ENERGIE SARL', '23456789012345', '4322B', '15 Rue de l''Industrie', '69100', 'VILLEURBANNE', '04 72 XX XX XX', 'contact@duret-energie.fr', '1998-06-01'),
('DURETRES', 'DURET RESEAUX SA', '34567890123456', '4321A', '22 Avenue des Reseaux', '69003', 'LYON', '04 78 XX XX XX', 'contact@duret-reseaux.fr', '2002-01-10'),
('DURETSER', 'DURET SERVICES SAS', '45678901234567', '4329Z', '8 Place Bellecour', '69002', 'LYON', '04 78 XX XX XX', 'contact@duret-services.fr', '2010-09-01');

-- ============================================================================
-- 2. SALARIES (100 salaries)
-- ============================================================================

INSERT INTO tiers.salarie (societe_id, code, matricule, nom, prenom, adresse, code_postal, ville, telephone, portable, email, fonction, service, date_entree, type_contrat, qualification, cout_horaire, cout_journalier, actif, conducteur_travaux, chef_equipe) VALUES
-- Direction
(1, 'SAL001', 'M001', 'DURET', 'Pierre', '12 Rue du Parc', '69006', 'LYON', '04 78 XX XX XX', '06 XX XX XX XX', 'p.duret@duret-elec.fr', 'Directeur General', 'Direction', '1985-03-15', 'CDI', 'Cadre Dirigeant', 0, 0, TRUE, FALSE, FALSE),
(1, 'SAL002', 'M002', 'DURET', 'Marie', '12 Rue du Parc', '69006', 'LYON', '04 78 XX XX XX', '06 XX XX XX XX', 'm.duret@duret-elec.fr', 'Directrice Administrative', 'Direction', '1990-01-15', 'CDI', 'Cadre', 0, 0, TRUE, FALSE, FALSE),
-- Commercial
(1, 'SAL010', 'M010', 'MARTIN', 'Jean', '5 Avenue Foch', '69003', 'LYON', '04 78 XX XX XX', '06 XX XX XX XX', 'j.martin@duret-elec.fr', 'Directeur Commercial', 'Commercial', '1995-09-01', 'CDI', 'Cadre', 0, 0, TRUE, FALSE, FALSE),
(1, 'SAL011', 'M011', 'BERNARD', 'Sophie', '15 Rue Garibaldi', '69003', 'LYON', NULL, '06 XX XX XX XX', 's.bernard@duret-elec.fr', 'Charge d''affaires', 'Commercial', '2005-03-01', 'CDI', 'Cadre', 0, 0, TRUE, FALSE, FALSE),
(1, 'SAL012', 'M012', 'PETIT', 'Thomas', '8 Place Bellecour', '69002', 'LYON', NULL, '06 XX XX XX XX', 't.petit@duret-elec.fr', 'Charge d''affaires', 'Commercial', '2010-06-15', 'CDI', 'Cadre', 0, 0, TRUE, FALSE, FALSE),
(1, 'SAL013', 'M013', 'ROBERT', 'Claire', '22 Cours Lafayette', '69003', 'LYON', NULL, '06 XX XX XX XX', 'c.robert@duret-elec.fr', 'Charge d''affaires', 'Commercial', '2015-01-15', 'CDI', 'Cadre', 0, 0, TRUE, FALSE, FALSE),
-- Bureau d'etudes
(1, 'SAL020', 'M020', 'DURAND', 'Michel', '10 Rue de la Republique', '69001', 'LYON', '04 78 XX XX XX', '06 XX XX XX XX', 'm.durand@duret-elec.fr', 'Responsable BE', 'Etudes', '2000-02-01', 'CDI', 'Cadre', 55.00, 440.00, TRUE, FALSE, FALSE),
(1, 'SAL021', 'M021', 'MOREAU', 'Julie', '45 Rue de Crequi', '69006', 'LYON', NULL, '06 XX XX XX XX', 'j.moreau@duret-elec.fr', 'Technicien BE', 'Etudes', '2012-09-01', 'CDI', 'ETAM', 42.00, 336.00, TRUE, FALSE, FALSE),
(1, 'SAL022', 'M022', 'SIMON', 'Lucas', '3 Rue de Bonnel', '69003', 'LYON', NULL, '06 XX XX XX XX', 'l.simon@duret-elec.fr', 'Technicien BE', 'Etudes', '2018-03-15', 'CDI', 'ETAM', 38.00, 304.00, TRUE, FALSE, FALSE),
-- Conducteurs de travaux
(1, 'SAL030', 'M030', 'LAURENT', 'Philippe', '28 Avenue Jean Jaures', '69007', 'LYON', NULL, '06 XX XX XX XX', 'p.laurent@duret-elec.fr', 'Responsable Travaux', 'Travaux', '1998-04-01', 'CDI', 'Cadre', 52.00, 416.00, TRUE, TRUE, FALSE),
(1, 'SAL031', 'M031', 'LEFEVRE', 'Antoine', '15 Rue Paul Bert', '69003', 'LYON', NULL, '06 XX XX XX XX', 'a.lefevre@duret-elec.fr', 'Conducteur de travaux', 'Travaux', '2008-09-01', 'CDI', 'ETAM', 48.00, 384.00, TRUE, TRUE, FALSE),
(1, 'SAL032', 'M032', 'GARCIA', 'Marc', '7 Rue de la Part-Dieu', '69003', 'LYON', NULL, '06 XX XX XX XX', 'm.garcia@duret-elec.fr', 'Conducteur de travaux', 'Travaux', '2012-01-15', 'CDI', 'ETAM', 45.00, 360.00, TRUE, TRUE, FALSE),
(1, 'SAL033', 'M033', 'ROUX', 'David', '19 Cours Gambetta', '69003', 'LYON', NULL, '06 XX XX XX XX', 'd.roux@duret-elec.fr', 'Conducteur de travaux', 'Travaux', '2016-06-01', 'CDI', 'ETAM', 42.00, 336.00, TRUE, TRUE, FALSE),
(1, 'SAL034', 'M034', 'FOURNIER', 'Julien', '33 Rue de Marseille', '69007', 'LYON', NULL, '06 XX XX XX XX', 'j.fournier@duret-elec.fr', 'Conducteur de travaux', 'Travaux', '2019-03-01', 'CDI', 'ETAM', 40.00, 320.00, TRUE, TRUE, FALSE),
-- Chefs d'equipe
(1, 'SAL040', 'M040', 'MOREL', 'Patrick', '25 Rue de Gerland', '69007', 'LYON', NULL, '06 XX XX XX XX', 'p.morel@duret-elec.fr', 'Chef d''equipe', 'Travaux', '2002-05-01', 'CDI', 'N4P2', 38.00, 304.00, TRUE, FALSE, TRUE),
(1, 'SAL041', 'M041', 'GIRARD', 'Sebastien', '8 Rue Moncey', '69003', 'LYON', NULL, '06 XX XX XX XX', 's.girard@duret-elec.fr', 'Chef d''equipe', 'Travaux', '2006-09-01', 'CDI', 'N4P2', 36.00, 288.00, TRUE, FALSE, TRUE),
(1, 'SAL042', 'M042', 'ANDRE', 'Nicolas', '12 Rue Vendome', '69006', 'LYON', NULL, '06 XX XX XX XX', 'n.andre@duret-elec.fr', 'Chef d''equipe', 'Travaux', '2010-03-15', 'CDI', 'N4P1', 35.00, 280.00, TRUE, FALSE, TRUE),
(1, 'SAL043', 'M043', 'MERCIER', 'Christophe', '6 Place Carnot', '69002', 'LYON', NULL, '06 XX XX XX XX', 'c.mercier@duret-elec.fr', 'Chef d''equipe', 'Travaux', '2014-06-01', 'CDI', 'N4P1', 34.00, 272.00, TRUE, FALSE, TRUE),
(1, 'SAL044', 'M044', 'BLANC', 'Frederic', '18 Rue de la Charite', '69002', 'LYON', NULL, '06 XX XX XX XX', 'f.blanc@duret-elec.fr', 'Chef d''equipe', 'Travaux', '2017-01-15', 'CDI', 'N4P1', 33.00, 264.00, TRUE, FALSE, TRUE);

-- Electriciens (generation en masse)
DO $$
DECLARE
    noms TEXT[] := ARRAY['DUPONT', 'LEROY', 'BONNET', 'VINCENT', 'MEYER', 'GARNIER', 'DUBOIS', 'THOMAS', 'RICHARD', 'MULLER', 'LAMBERT', 'FONTAINE', 'ROUSSEAU', 'NICOLAS', 'HENRY', 'PERRIN', 'BERTRAND', 'CHEVALIER', 'CLEMENT', 'RENAUD', 'PICARD', 'MATHIEU', 'MEUNIER', 'DUMAS', 'BRUNET', 'LEMAIRE', 'CARON', 'MASSON', 'MARCHAND', 'NOEL', 'ADAM', 'FAURE', 'GAUTHIER', 'FERNANDEZ', 'ROGER', 'BENOIT', 'REY', 'LOPEZ', 'RIVIERE', 'COLIN'];
    prenoms TEXT[] := ARRAY['Alexandre', 'Benjamin', 'Cedric', 'Daniel', 'Emmanuel', 'Fabien', 'Guillaume', 'Hugo', 'Ivan', 'Jerome', 'Kevin', 'Laurent', 'Maxime', 'Nathan', 'Olivier', 'Pascal', 'Quentin', 'Romain', 'Stephane', 'Thierry', 'Ugo', 'Vincent', 'William', 'Xavier', 'Yannick'];
    qualifs TEXT[] := ARRAY['N3P1', 'N3P2', 'N3P2', 'N3P2', 'N2P2', 'N2P2', 'N2P1'];
    couts NUMERIC[] := ARRAY[28, 30, 30, 30, 26, 26, 24];
    i INTEGER;
    nom TEXT;
    prenom TEXT;
    qualif TEXT;
    cout NUMERIC;
    code_sal VARCHAR(20);
    matricule_sal VARCHAR(15);
BEGIN
    FOR i IN 1..60 LOOP
        nom := noms[1 + (i % array_length(noms, 1))];
        prenom := prenoms[1 + (i % array_length(prenoms, 1))];
        qualif := qualifs[1 + (i % array_length(qualifs, 1))];
        cout := couts[1 + (i % array_length(couts, 1))];
        code_sal := 'SAL' || LPAD((100 + i)::TEXT, 3, '0');
        matricule_sal := 'M' || LPAD((100 + i)::TEXT, 3, '0');

        INSERT INTO tiers.salarie (societe_id, code, matricule, nom, prenom, ville, portable, email, fonction, service, date_entree, type_contrat, qualification, cout_horaire, cout_journalier, actif, conducteur_travaux, chef_equipe)
        VALUES (
            1,
            code_sal,
            matricule_sal,
            nom,
            prenom,
            'LYON',
            '06 XX XX XX XX',
            LOWER(LEFT(prenom, 1) || '.' || nom || '@duret-elec.fr'),
            'Electricien',
            'Travaux',
            '2015-01-01'::DATE + (RANDOM() * 3000)::INT,
            CASE WHEN RANDOM() < 0.9 THEN 'CDI' ELSE 'CDD' END,
            qualif,
            cout,
            cout * 8,
            TRUE,
            FALSE,
            FALSE
        );
    END LOOP;
END $$;

-- ============================================================================
-- 3. EQUIPES
-- ============================================================================

INSERT INTO tiers.equipe (societe_id, code, libelle, chef_equipe_id, cout_horaire, actif) VALUES
(1, 'EQ01', 'Equipe Tertiaire 1', (SELECT id FROM tiers.salarie WHERE code = 'SAL040'), 120.00, TRUE),
(1, 'EQ02', 'Equipe Tertiaire 2', (SELECT id FROM tiers.salarie WHERE code = 'SAL041'), 115.00, TRUE),
(1, 'EQ03', 'Equipe Industrie', (SELECT id FROM tiers.salarie WHERE code = 'SAL042'), 125.00, TRUE),
(1, 'EQ04', 'Equipe Logement', (SELECT id FROM tiers.salarie WHERE code = 'SAL043'), 110.00, TRUE),
(1, 'EQ05', 'Equipe Maintenance', (SELECT id FROM tiers.salarie WHERE code = 'SAL044'), 105.00, TRUE);

-- Composition des equipes
INSERT INTO tiers.equipe_membre (equipe_id, salarie_id, date_debut)
SELECT e.id, s.id, '2025-01-01'
FROM tiers.equipe e
CROSS JOIN LATERAL (
    SELECT id FROM tiers.salarie
    WHERE fonction = 'Electricien'
    ORDER BY RANDOM()
    LIMIT 4
) s
WHERE e.code IN ('EQ01', 'EQ02', 'EQ03', 'EQ04', 'EQ05');

-- ============================================================================
-- 4. CHARGES D'AFFAIRES
-- ============================================================================

INSERT INTO tiers.charge_affaire (societe_id, code, intitule, salarie_id, activite_id, secteur_geo_id, email, telephone, actif) VALUES
(1, 'CA01', 'Sophie BERNARD', (SELECT id FROM tiers.salarie WHERE code = 'SAL011'), 1, 1, 's.bernard@duret-elec.fr', '06 XX XX XX XX', TRUE),
(1, 'CA02', 'Thomas PETIT', (SELECT id FROM tiers.salarie WHERE code = 'SAL012'), 2, 2, 't.petit@duret-elec.fr', '06 XX XX XX XX', TRUE),
(1, 'CA03', 'Claire ROBERT', (SELECT id FROM tiers.salarie WHERE code = 'SAL013'), 3, 3, 'c.robert@duret-elec.fr', '06 XX XX XX XX', TRUE);

-- ============================================================================
-- 5. CLIENTS (150 clients)
-- ============================================================================

INSERT INTO tiers.client (societe_id, code, intitule, siret, numero_tva, adresse_ligne1, code_postal, ville, pays_code, telephone, email, charge_affaire_id, mode_reglement_code, categorie_av_code, encours_max, compte_collectif) VALUES
-- Grands comptes construction
(1, 'CLI001', 'BOUYGUES CONSTRUCTION', '57204186800321', 'FR12572041868', '1 Avenue Eugene Freyssinet', '78280', 'GUYANCOURT', 'FR', '01 30 60 60 60', 'contact@bouygues-construction.com', 1, '45FM', 'V', 500000.00, '411000'),
(1, 'CLI002', 'VINCI CONSTRUCTION', '40993739700312', 'FR67409937397', '1 Cours Ferdinand de Lesseps', '92851', 'RUEIL-MALMAISON', 'FR', '01 57 98 60 00', 'contact@vinci.com', 1, '60FM', 'V', 750000.00, '411000'),
(1, 'CLI003', 'EIFFAGE CONSTRUCTION', '70980282300341', 'FR45709802823', '3 Avenue Morane Saulnier', '78140', 'VELIZY', 'FR', '01 34 65 00 00', 'contact@eiffage.fr', 1, '45FM', 'V', 400000.00, '411000'),
(1, 'CLI004', 'SPIE BATIGNOLLES', '32393584600152', 'FR08323935846', '12 Rue de Berri', '75008', 'PARIS', 'FR', '01 44 20 70 00', 'contact@spiebatignolles.fr', 1, '60FM', 'V', 350000.00, '411000'),
(1, 'CLI005', 'DEMATHIEU BARD', '68200037900152', 'FR19682000379', '12 Rue de Verdun', '54000', 'NANCY', 'FR', '03 83 30 10 00', 'contact@demathieu-bard.fr', 2, '45FM', 'V', 300000.00, '411000'),
-- Collectivites
(1, 'CLI010', 'METROPOLE DE LYON', '20004697600057', 'FR50200046976', '20 Rue du Lac', '69003', 'LYON', 'FR', '04 78 63 40 40', 'marches@grandlyon.com', 1, '30J', 'V', 500000.00, '411000'),
(1, 'CLI011', 'VILLE DE GRENOBLE', '21380185400015', 'FR35213801854', '11 Boulevard Jean Pain', '38000', 'GRENOBLE', 'FR', '04 76 76 36 36', 'marches@grenoble.fr', 2, '30J', 'V', 200000.00, '411000'),
(1, 'CLI012', 'DEPARTEMENT DU RHONE', '22690001600019', 'FR54226900016', '29-31 Cours de la Liberte', '69003', 'LYON', 'FR', '04 72 61 77 77', 'contact@rhone.fr', 1, '30J', 'V', 300000.00, '411000'),
(1, 'CLI013', 'REGION AUVERGNE-RHONE-ALPES', '23840001800032', 'FR81238400018', '101 Cours Charlemagne', '69002', 'LYON', 'FR', '04 26 73 40 00', 'contact@auvergnerhonealpes.fr', 1, '30J', 'V', 400000.00, '411000'),
(1, 'CLI014', 'VILLE DE SAINT-ETIENNE', '21420218800017', 'FR43214202188', '1 Place de l''Hotel de Ville', '42000', 'SAINT-ETIENNE', 'FR', '04 77 48 77 48', 'marches@saint-etienne.fr', 2, '30J', 'V', 150000.00, '411000'),
-- Bailleurs sociaux
(1, 'CLI020', 'ALLIADE HABITAT', '77982713200137', 'FR34779827132', '143 Rue Garibaldi', '69003', 'LYON', 'FR', '04 78 95 20 00', 'contact@alliade.com', 3, '45FM', 'V', 200000.00, '411000'),
(1, 'CLI021', 'LYON METROPOLE HABITAT', '38370526900024', 'FR27383705269', '195 Rue Garibaldi', '69003', 'LYON', 'FR', '04 78 60 42 42', 'contact@lmhabitat.fr', 3, '45FM', 'V', 250000.00, '411000'),
(1, 'CLI022', 'OPAC DU RHONE', '77567979200016', 'FR52775679792', '3 Rue Delandine', '69002', 'LYON', 'FR', '04 72 60 10 00', 'contact@opacdurhone.fr', 3, '30J', 'V', 180000.00, '411000'),
(1, 'CLI023', 'DYNACITE', '77929575700165', 'FR28779295757', '367 Boulevard Jules Favre', '01000', 'BOURG-EN-BRESSE', 'FR', '04 74 32 69 50', 'contact@dynacite.fr', 3, '45FM', 'V', 150000.00, '411000'),
-- Promoteurs immobiliers
(1, 'CLI030', 'NEXITY', '44451614100217', 'FR79444516141', '19 Rue de Vienne', '75008', 'PARIS', 'FR', '01 85 55 19 00', 'contact@nexity.fr', 1, '60FM', 'V', 400000.00, '411000'),
(1, 'CLI031', 'KAUFMAN & BROAD', '70201721100108', 'FR15702017211', '127 Avenue Charles de Gaulle', '92200', 'NEUILLY-SUR-SEINE', 'FR', '01 41 43 43 43', 'contact@kaufmanbroad.fr', 1, '60FM', 'V', 350000.00, '411000'),
(1, 'CLI032', 'BOUYGUES IMMOBILIER', '56207179003063', 'FR07562071790', '3 Boulevard Gallieni', '92130', 'ISSY-LES-MOULINEAUX', 'FR', '01 55 38 25 25', 'contact@bouygues-immobilier.com', 1, '60FM', 'V', 380000.00, '411000'),
(1, 'CLI033', 'ICADE PROMOTION', '58203531100583', 'FR95582035311', '35 Rue de la Gare', '75019', 'PARIS', 'FR', '01 41 57 70 00', 'contact@icade.fr', 1, '60FM', 'V', 320000.00, '411000'),
-- Industrie
(1, 'CLI040', 'ARKEMA FRANCE', '31963279200134', 'FR29319632792', '420 Rue d''Estienne d''Orves', '92700', 'COLOMBES', 'FR', '01 49 00 80 80', 'contact@arkema.com', 2, '45FM', 'V', 280000.00, '411000'),
(1, 'CLI041', 'SANOFI PASTEUR', '37996034600146', 'FR83379960346', '2 Avenue Pont Pasteur', '69007', 'LYON', 'FR', '04 37 37 37 37', 'achats@sanofi.com', 2, '45FM', 'V', 350000.00, '411000'),
(1, 'CLI042', 'RENAULT TRUCKS', '95450550000256', 'FR28954505500', '99 Route de Lyon', '69800', 'SAINT-PRIEST', 'FR', '04 72 96 96 96', 'achats@renault-trucks.com', 2, '60FM', 'V', 400000.00, '411000'),
(1, 'CLI043', 'PLASTIC OMNIUM', '95501158000204', 'FR44955011580', '19 Boulevard Jules Carteret', '69007', 'LYON', 'FR', '04 78 72 62 62', 'contact@plasticomnium.com', 2, '45FM', 'V', 280000.00, '411000'),
-- Sante
(1, 'CLI050', 'HOSPICES CIVILS DE LYON', '26690002900073', 'FR42266900029', '3 Quai des Celestins', '69002', 'LYON', 'FR', '04 72 40 30 30', 'marches@chu-lyon.fr', 1, '30J', 'V', 450000.00, '411000'),
(1, 'CLI051', 'CHU GRENOBLE ALPES', '26380001800014', 'FR77263800018', 'Boulevard de la Chantourne', '38700', 'LA TRONCHE', 'FR', '04 76 76 75 75', 'marches@chu-grenoble.fr', 2, '30J', 'V', 300000.00, '411000'),
(1, 'CLI052', 'KORIAN', '44431723500116', 'FR97444317235', '21-25 Rue Balzac', '75008', 'PARIS', 'FR', '01 55 37 52 00', 'technique@korian.fr', 3, '45FM', 'V', 200000.00, '411000'),
-- Commerce / Distribution
(1, 'CLI060', 'CARREFOUR PROPERTY', '67203912600085', 'FR42672039126', '93 Avenue de Paris', '91300', 'MASSY', 'FR', '01 64 50 80 00', 'property@carrefour.com', 1, '45FM', 'V', 250000.00, '411000'),
(1, 'CLI061', 'CENTRES E.LECLERC', '30297039300134', 'FR85302970393', '26 Quai Marcel Boyer', '94200', 'IVRY-SUR-SEINE', 'FR', '01 45 17 24 24', 'technique@e-leclerc.com', 2, '45FM', 'V', 220000.00, '411000'),
(1, 'CLI062', 'AUCHAN RETAIL', '41004201900077', 'FR56410042019', '200 Rue de la Recherche', '59650', 'VILLENEUVE D''ASCQ', 'FR', '03 20 67 67 67', 'immobilier@auchan.fr', 2, '45FM', 'V', 200000.00, '411000');

-- Generation de clients PME locaux
DO $$
DECLARE
    types_entreprise TEXT[] := ARRAY['SARL', 'SAS', 'SA', 'EURL', 'SCI'];
    secteurs TEXT[] := ARRAY['GARAGE', 'RESTAURANT', 'HOTEL', 'PHARMACIE', 'CABINET', 'COMMERCE', 'INDUSTRIE', 'BUREAUX', 'COPROPRIETE', 'RESIDENCE'];
    villes TEXT[] := ARRAY['LYON', 'VILLEURBANNE', 'VENISSIEUX', 'CALUIRE', 'BRON', 'VAULX-EN-VELIN', 'SAINT-PRIEST', 'OULLINS', 'TASSIN', 'ECULLY', 'GRENOBLE', 'ANNECY', 'CHAMBERY', 'VALENCE', 'SAINT-ETIENNE'];
    noms_proprio TEXT[] := ARRAY['MARTIN', 'BERNARD', 'DUBOIS', 'THOMAS', 'ROBERT', 'RICHARD', 'PETIT', 'DURAND', 'LEROY', 'MOREAU', 'SIMON', 'LAURENT', 'LEFEBVRE', 'MICHEL', 'GARCIA'];
    i INTEGER;
    code_cli VARCHAR(20);
    nom_entreprise VARCHAR(100);
    ville_ent VARCHAR(50);
BEGIN
    FOR i IN 1..100 LOOP
        code_cli := 'CLI' || LPAD((100 + i)::TEXT, 3, '0');
        nom_entreprise := secteurs[1 + (i % array_length(secteurs, 1))] || ' ' || noms_proprio[1 + (i % array_length(noms_proprio, 1))];
        ville_ent := villes[1 + (i % array_length(villes, 1))];

        INSERT INTO tiers.client (societe_id, code, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, mode_reglement_code, categorie_av_code, encours_max, compte_collectif, charge_affaire_id)
        VALUES (
            1,
            code_cli,
            nom_entreprise,
            (10 + i) || ' Rue du Commerce',
            CASE
                WHEN ville_ent = 'GRENOBLE' THEN '38000'
                WHEN ville_ent = 'ANNECY' THEN '74000'
                WHEN ville_ent = 'CHAMBERY' THEN '73000'
                WHEN ville_ent = 'VALENCE' THEN '26000'
                WHEN ville_ent = 'SAINT-ETIENNE' THEN '42000'
                ELSE '69' || LPAD((i % 10)::TEXT, 3, '0')
            END,
            ville_ent,
            'FR',
            '04 7X XX XX XX',
            CASE WHEN RANDOM() < 0.3 THEN '30J' WHEN RANDOM() < 0.6 THEN '30FM' ELSE '45FM' END,
            'V',
            (20000 + RANDOM() * 80000)::NUMERIC(15,2),
            '411000',
            (1 + (i % 3))
        );
    END LOOP;
END $$;

-- ============================================================================
-- 6. FOURNISSEURS (80 fournisseurs)
-- ============================================================================

INSERT INTO tiers.fournisseur (societe_id, code, intitule, siret, numero_tva, adresse_ligne1, code_postal, ville, pays_code, telephone, email, mode_reglement_code, categorie_av_code, compte_collectif) VALUES
-- Grossistes electriques
(1, 'FOU001', 'REXEL FRANCE', '30997412700124', 'FR50309974127', '13 Boulevard du Fort de Vaux', '75017', 'PARIS', 'FR', '01 42 85 85 00', 'commercial@rexel.fr', '30FM', 'A', '401000'),
(1, 'FOU002', 'SONEPAR FRANCE', '55080014100186', 'FR76550800141', '153 Avenue Jean Jaures', '93300', 'AUBERVILLIERS', 'FR', '01 48 11 34 00', 'contact@sonepar.fr', '30FM', 'A', '401000'),
(1, 'FOU003', 'CGED (Sonepar)', '39142234900354', 'FR68391422349', '12 Rue de Rome', '69001', 'LYON', 'FR', '04 72 00 00 00', 'lyon@cged.fr', '30FM', 'A', '401000'),
(1, 'FOU004', 'YESSS ELECTRIQUE', '43483182400354', 'FR43434831824', '25 Rue de l''Industrie', '69100', 'VILLEURBANNE', 'FR', '04 78 XX XX XX', 'lyon@yesss.fr', '30FM', 'A', '401000'),
-- Fabricants appareillage
(1, 'FOU010', 'LEGRAND', '75850100100178', 'FR48758501001', '128 Avenue du Marechal de Lattre', '87000', 'LIMOGES', 'FR', '05 55 06 87 87', 'commercial@legrand.fr', '45FM', 'A', '401000'),
(1, 'FOU011', 'SCHNEIDER ELECTRIC', '54207855401286', 'FR91542078554', '35 Rue Joseph Monier', '92500', 'RUEIL-MALMAISON', 'FR', '01 41 29 70 00', 'commercial@schneider-electric.com', '45FM', 'A', '401000'),
(1, 'FOU012', 'ABB FRANCE', '62980197800249', 'FR43629801978', '3 Avenue du Canada', '91978', 'COURTABOEUF', 'FR', '01 64 86 30 00', 'contact@fr.abb.com', '45FM', 'A', '401000'),
(1, 'FOU013', 'HAGER', '55081003300199', 'FR40550810033', '132 Boulevard d''Europe', '67210', 'OBERNAI', 'FR', '03 88 49 50 50', 'contact@hager.fr', '30FM', 'A', '401000'),
(1, 'FOU014', 'SIEMENS FRANCE', '56202442900145', 'FR88562024429', '40 Avenue des Fruitiers', '93527', 'SAINT-DENIS', 'FR', '01 49 22 20 00', 'contact@siemens.fr', '45FM', 'A', '401000'),
-- Cables
(1, 'FOU020', 'NEXANS FRANCE', '42844188900183', 'FR65428441889', '4 Allee de l''Arche', '92400', 'COURBEVOIE', 'FR', '01 73 23 84 00', 'commercial@nexans.com', '45FM', 'A', '401000'),
(1, 'FOU021', 'PRYSMIAN GROUP', '55210036200129', 'FR76552100362', '8 Rue Lionel Terray', '69330', 'MEYZIEU', 'FR', '04 72 02 16 00', 'contact@prysmiangroup.com', '45FM', 'A', '401000'),
(1, 'FOU022', 'ACOME', '57207909500021', 'FR92572079095', '52 Rue du Montparnasse', '75014', 'PARIS', 'FR', '02 33 31 51 00', 'commercial@acome.fr', '30FM', 'A', '401000'),
-- Eclairage
(1, 'FOU030', 'SIGNIFY (Philips)', '54206108600148', 'FR05542061086', '33 Rue de Verdun', '92150', 'SURESNES', 'FR', '01 47 28 50 00', 'contact@signify.com', '45FM', 'A', '401000'),
(1, 'FOU031', 'TRILUX FRANCE', '38019348700025', 'FR89380193487', '6 Rue de la Morache', '21603', 'LONGVIC', 'FR', '03 80 66 83 83', 'contact@trilux.fr', '45FM', 'A', '401000'),
(1, 'FOU032', 'ZUMTOBEL', '38794556200026', 'FR72387945562', '1 Rue de l''Industrie', '67167', 'WEITBRUCH', 'FR', '03 88 64 91 00', 'contact@zumtobel.fr', '45FM', 'A', '401000'),
(1, 'FOU033', 'SYLVANIA', '40326917300024', 'FR62403269173', '25 Quai Marcel Dassault', '92150', 'SURESNES', 'FR', '01 41 38 88 88', 'contact@sylvania.com', '45FM', 'A', '401000'),
-- Outillage
(1, 'FOU040', 'FACOM', '54203764900043', 'FR85542037649', '6-8 Rue Gustave Eiffel', '91420', 'MORANGIS', 'FR', '01 64 54 45 45', 'contact@facom.fr', '30FM', 'A', '401000'),
(1, 'FOU041', 'MILWAUKEE', '49088765400023', 'FR42490887654', '17 Avenue des Tilleuls', '77185', 'LOGNES', 'FR', '01 64 62 60 00', 'contact@milwaukeetool.fr', '30FM', 'A', '401000'),
(1, 'FOU042', 'HILTI FRANCE', '31091287200056', 'FR71310912872', '1 Rue Jean Mermoz', '78772', 'MAGNY-LES-HAMEAUX', 'FR', '01 30 69 30 00', 'contact@hilti.fr', '30FM', 'A', '401000'),
(1, 'FOU043', 'DEWALT', '34973621700047', 'FR75349736217', '5 Allee des Hetres', '69760', 'LIMONEST', 'FR', '04 72 20 39 20', 'contact@dewalt.fr', '30FM', 'A', '401000'),
-- Location materiel
(1, 'FOU050', 'LOXAM', '45674561200089', 'FR34456745612', '256 Rue Nicolas Cugnot', '59650', 'VILLENEUVE D''ASCQ', 'FR', '03 20 19 20 21', 'contact@loxam.fr', '30FM', 'A', '401000'),
(1, 'FOU051', 'KILOUTOU', '98765432100145', 'FR45987654321', '3 Rue Auger', '93500', 'PANTIN', 'FR', '01 41 71 20 00', 'contact@kiloutou.fr', '30FM', 'A', '401000'),
-- Photovoltaique
(1, 'FOU060', 'SUNPOWER FRANCE', '48774519800042', 'FR17487745198', '3 Rue des Arts et Metiers', '94200', 'IVRY-SUR-SEINE', 'FR', '01 53 68 00 00', 'contact@sunpower.fr', '60FM', 'A', '401000'),
(1, 'FOU061', 'SOLARWATT', '50949830400015', 'FR85509498304', '15 Rue de la Sabliere', '33310', 'LORMONT', 'FR', '05 56 31 65 00', 'contact@solarwatt.fr', '60FM', 'A', '401000'),
-- Bornes de recharge
(1, 'FOU070', 'SCHNEIDER EVLINK', '54207855401286', 'FR91542078554', '35 Rue Joseph Monier', '92500', 'RUEIL-MALMAISON', 'FR', '01 41 29 70 00', 'evlink@schneider-electric.com', '45FM', 'A', '401000'),
(1, 'FOU071', 'ABB TERRA', '62980197800249', 'FR43629801978', '3 Avenue du Canada', '91978', 'COURTABOEUF', 'FR', '01 64 86 30 00', 'terra@fr.abb.com', '45FM', 'A', '401000');

-- ============================================================================
-- 7. SOUS-TRAITANTS (30 sous-traitants)
-- ============================================================================

INSERT INTO tiers.sous_traitant (societe_id, code, intitule, siret, adresse_ligne1, code_postal, ville, pays_code, telephone, email, qualification, mode_reglement_code, compte_collectif) VALUES
(1, 'SST001', 'ELEC SERVICES 69', '45678901234568', '12 Rue de l''Industrie', '69100', 'VILLEURBANNE', 'FR', '04 78 XX XX XX', 'contact@elecservices69.fr', 'Electricite generale CFO/CFA', '30FM', '401000'),
(1, 'SST002', 'RHONE ELECTRICITE', '56789012345679', '34 Avenue Jean Jaures', '69007', 'LYON', 'FR', '04 78 XX XX XX', 'contact@rhone-elec.fr', 'Electricite industrielle', '30FM', '401000'),
(1, 'SST003', 'ALPES CABLAGE', '67890123456780', '8 Zone Industrielle', '38000', 'GRENOBLE', 'FR', '04 76 XX XX XX', 'contact@alpes-cablage.fr', 'Cablage VDI', '30FM', '401000'),
(1, 'SST004', 'ISERE ELEC PRO', '78901234567891', '15 Rue des Artisans', '38100', 'GRENOBLE', 'FR', '04 76 XX XX XX', 'contact@isere-elec.fr', 'Electricite tertiaire', '30FM', '401000'),
(1, 'SST005', 'SAVOIE ENERGIE', '89012345678902', '22 Avenue du Lac', '73000', 'CHAMBERY', 'FR', '04 79 XX XX XX', 'contact@savoie-energie.fr', 'Photovoltaique', '30FM', '401000'),
(1, 'SST006', 'CONTROL ELEC 69', '90123456789013', '45 Rue Moncey', '69003', 'LYON', 'FR', '04 78 XX XX XX', 'contact@control-elec69.fr', 'Automatisme et controle', '30FM', '401000'),
(1, 'SST007', 'SECURITE INCENDIE RHONE', '01234567890124', '18 Rue de Gerland', '69007', 'LYON', 'FR', '04 78 XX XX XX', 'contact@securite-incendie-rhone.fr', 'SSI et desenfumage', '30FM', '401000'),
(1, 'SST008', 'DATA CONNECT LYON', '12345678901235', '33 Rue de la Part-Dieu', '69003', 'LYON', 'FR', '04 78 XX XX XX', 'contact@dataconnect-lyon.fr', 'Data center et VDI', '30FM', '401000'),
(1, 'SST009', 'CLIM ELEC 69', '23456789012346', '7 Avenue Lacassagne', '69003', 'LYON', 'FR', '04 78 XX XX XX', 'contact@clim-elec69.fr', 'Climatisation et ventilation', '30FM', '401000'),
(1, 'SST010', 'TERRASSEMENT RHONE', '34567890123457', '50 Route de Vienne', '69008', 'LYON', 'FR', '04 78 XX XX XX', 'contact@terrassement-rhone.fr', 'Terrassement et GC', '30FM', '401000');

-- ============================================================================
-- 8. ARCHITECTES
-- ============================================================================

INSERT INTO tiers.architecte (societe_id, code, intitule, adresse_ligne1, code_postal, ville, telephone, email, numero_ordre) VALUES
(1, 'ARC001', 'CABINET MARTIN ARCHITECTES', '15 Place Bellecour', '69002', 'LYON', '04 78 XX XX XX', 'contact@martin-archi.fr', 'RA-12345'),
(1, 'ARC002', 'ATELIER DUPONT & ASSOCIES', '8 Rue Merciere', '69002', 'LYON', '04 78 XX XX XX', 'contact@atelier-dupont.fr', 'RA-23456'),
(1, 'ARC003', 'ARCHITECTURE STUDIO LYON', '22 Quai Claude Bernard', '69007', 'LYON', '04 78 XX XX XX', 'contact@archi-studio-lyon.fr', 'RA-34567'),
(1, 'ARC004', 'GROUPE 6 ARCHITECTES', '3 Rue de la Republique', '38000', 'GRENOBLE', '04 76 XX XX XX', 'contact@groupe6.fr', 'RA-45678'),
(1, 'ARC005', 'AUER WEBER FRANCE', '45 Cours Lafayette', '69003', 'LYON', '04 78 XX XX XX', 'contact@auer-weber.fr', 'RA-56789');

-- ============================================================================
-- 9. BIBLIOTHEQUES ET ELEMENTS/ARTICLES
-- ============================================================================

INSERT INTO ref.bibliotheque (code, libelle, type_biblio) VALUES
('INT', 'Bibliotheque interne', 'INTERNE'),
('LEG', 'Catalogue Legrand', 'FOURNISSEUR'),
('SCH', 'Catalogue Schneider', 'FOURNISSEUR'),
('NEX', 'Catalogue Nexans', 'FOURNISSEUR'),
('PHI', 'Catalogue Philips/Signify', 'FOURNISSEUR');

-- Elements/Articles
INSERT INTO ref.element (societe_id, code, designation, nature_id, bibliotheque_id, unite_mesure_code, prix_achat, prix_vente, coefficient, taux_tva_id, gere_en_stock) VALUES
-- Cables
(1, 'CAB-U1000R2V-3G1.5', 'Cable U1000R2V 3G1.5mm2', 1, 4, 'ML', 0.85, 1.45, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-3G2.5', 'Cable U1000R2V 3G2.5mm2', 1, 4, 'ML', 1.20, 2.04, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G1.5', 'Cable U1000R2V 5G1.5mm2', 1, 4, 'ML', 1.35, 2.30, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G2.5', 'Cable U1000R2V 5G2.5mm2', 1, 4, 'ML', 2.15, 3.66, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G6', 'Cable U1000R2V 5G6mm2', 1, 4, 'ML', 4.50, 7.65, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G10', 'Cable U1000R2V 5G10mm2', 1, 4, 'ML', 7.20, 12.24, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G16', 'Cable U1000R2V 5G16mm2', 1, 4, 'ML', 11.50, 19.55, 1.70, 1, TRUE),
(1, 'CAB-U1000R2V-5G25', 'Cable U1000R2V 5G25mm2', 1, 4, 'ML', 17.80, 30.26, 1.70, 1, TRUE),
-- Appareillage Legrand
(1, 'LEG-077001', 'Prise 2P+T Mosaic', 1, 2, 'U', 4.50, 9.00, 2.00, 1, TRUE),
(1, 'LEG-077011', 'Interrupteur va-et-vient Mosaic', 1, 2, 'U', 5.20, 10.40, 2.00, 1, TRUE),
(1, 'LEG-077071', 'Double va-et-vient Mosaic', 1, 2, 'U', 8.50, 17.00, 2.00, 1, TRUE),
(1, 'LEG-078802', 'Plaque 2 postes Mosaic blanc', 1, 2, 'U', 2.80, 5.60, 2.00, 1, TRUE),
(1, 'LEG-412422', 'Disjoncteur C16A 1P+N', 1, 2, 'U', 12.50, 25.00, 2.00, 1, TRUE),
(1, 'LEG-412424', 'Disjoncteur C20A 1P+N', 1, 2, 'U', 13.00, 26.00, 2.00, 1, TRUE),
(1, 'LEG-412426', 'Disjoncteur C32A 1P+N', 1, 2, 'U', 15.50, 31.00, 2.00, 1, TRUE),
(1, 'LEG-411611', 'Interrupteur differentiel 40A 30mA type AC', 1, 2, 'U', 45.00, 90.00, 2.00, 1, TRUE),
(1, 'LEG-411617', 'Interrupteur differentiel 63A 30mA type A', 1, 2, 'U', 85.00, 170.00, 2.00, 1, TRUE),
-- Schneider
(1, 'SCH-A9F74616', 'Disjoncteur iC60N 16A courbe C', 1, 3, 'U', 14.00, 28.00, 2.00, 1, TRUE),
(1, 'SCH-A9F74620', 'Disjoncteur iC60N 20A courbe C', 1, 3, 'U', 14.50, 29.00, 2.00, 1, TRUE),
(1, 'SCH-A9F74632', 'Disjoncteur iC60N 32A courbe C', 1, 3, 'U', 16.00, 32.00, 2.00, 1, TRUE),
(1, 'SCH-A9R11240', 'Interrupteur diff. iID 40A 30mA type AC', 1, 3, 'U', 42.00, 84.00, 2.00, 1, TRUE),
(1, 'SCH-A9R11263', 'Interrupteur diff. iID 63A 30mA type A', 1, 3, 'U', 78.00, 156.00, 2.00, 1, TRUE),
-- Eclairage
(1, 'PHI-91183200', 'Dalle LED 600x600 40W 4000K', 1, 5, 'U', 45.00, 90.00, 2.00, 1, TRUE),
(1, 'PHI-91183300', 'Dalle LED 1200x300 36W 4000K', 1, 5, 'U', 55.00, 110.00, 2.00, 1, TRUE),
(1, 'PHI-91184000', 'Downlight LED DN130B 18W', 1, 5, 'U', 28.00, 56.00, 2.00, 1, TRUE),
(1, 'PHI-91185000', 'Reglette LED WT120C 36W', 1, 5, 'U', 35.00, 70.00, 2.00, 1, TRUE),
-- Main d'oeuvre
(1, 'MO-ELEC-N3', 'Heure electricien N3', 2, 1, 'H', 28.00, 52.00, 1.86, 1, FALSE),
(1, 'MO-ELEC-N4', 'Heure electricien N4', 2, 1, 'H', 35.00, 62.00, 1.77, 1, FALSE),
(1, 'MO-CHEF', 'Heure chef d''equipe', 2, 1, 'H', 38.00, 68.00, 1.79, 1, FALSE),
(1, 'MO-CONDUC', 'Heure conducteur travaux', 2, 1, 'H', 48.00, 85.00, 1.77, 1, FALSE),
-- Location materiel
(1, 'LOC-NACELLE', 'Location nacelle/jour', 3, 1, 'J', 120.00, 180.00, 1.50, 1, FALSE),
(1, 'LOC-ECHAF', 'Location echafaudage/jour', 3, 1, 'J', 45.00, 75.00, 1.67, 1, FALSE),
(1, 'LOC-FOURGON', 'Location fourgon/jour', 3, 1, 'J', 65.00, 100.00, 1.54, 1, FALSE);

-- ============================================================================
-- 10. AFFAIRES (50 affaires)
-- ============================================================================

INSERT INTO affaire.affaire (societe_id, code, intitule, client_id, adresse_chantier, code_postal_chantier, ville_chantier, nature_travaux_id, type_marche_id, charge_affaire_id, etat, date_creation, date_acceptation, date_debut_prevue, date_fin_prevue, montant_marche_ht, budget_fournitures, budget_main_oeuvre, budget_sous_traitance, pct_avancement, montant_facture_ht) VALUES
-- Affaires en cours
(1, 'AFF2025-001', 'Construction Tour Part-Dieu T3 - Lot Electricite', 1, '129 Rue Servient', '69003', 'LYON', 1, 1, 1, 'EN_COURS', '2024-06-15', '2024-09-01', '2025-01-15', '2026-06-30', 2850000.00, 950000.00, 850000.00, 450000.00, 45.00, 1282500.00),
(1, 'AFF2025-002', 'Restructuration CHU Lyon Sud - CFO/CFA', 50, '165 Chemin du Grand Revoyet', '69310', 'PIERRE-BENITE', 1, 2, 1, 'EN_COURS', '2024-08-01', '2024-11-15', '2025-02-01', '2026-12-31', 4200000.00, 1400000.00, 1200000.00, 800000.00, 25.00, 1050000.00),
(1, 'AFF2025-003', 'Data Center Vaise - Infrastructure electrique', 42, '25 Rue du Commandant Charcot', '69005', 'LYON', 8, 1, 2, 'EN_COURS', '2024-09-15', '2024-12-01', '2025-03-01', '2025-12-31', 1850000.00, 750000.00, 550000.00, 250000.00, 60.00, 1110000.00),
(1, 'AFF2025-004', 'Extension Usine Renault Trucks - Electricite industrielle', 42, '99 Route de Lyon', '69800', 'SAINT-PRIEST', 2, 1, 2, 'EN_COURS', '2025-01-15', '2025-03-01', '2025-04-15', '2025-11-30', 980000.00, 380000.00, 320000.00, 150000.00, 35.00, 343000.00),
(1, 'AFF2025-005', 'Residence Les Jardins de Gerland - 85 logements', 30, '45 Avenue Tony Garnier', '69007', 'LYON', 1, 1, 3, 'EN_COURS', '2024-11-01', '2025-01-15', '2025-03-01', '2026-03-31', 1250000.00, 450000.00, 480000.00, 120000.00, 50.00, 625000.00),
(1, 'AFF2025-006', 'Campus universitaire Grenoble - Lot Electricite', 11, 'Domaine universitaire', '38400', 'SAINT-MARTIN-D''HERES', 1, 2, 2, 'EN_COURS', '2025-02-01', '2025-04-15', '2025-06-01', '2026-09-30', 1680000.00, 580000.00, 520000.00, 280000.00, 20.00, 336000.00),
-- Affaires terminees
(1, 'AFF2024-045', 'Renovation eclairage Centre Commercial Part-Dieu', 60, '17 Rue du Docteur Bouchut', '69003', 'LYON', 7, 1, 1, 'TERMINE', '2024-01-15', '2024-03-01', '2024-04-01', '2024-09-30', 580000.00, 280000.00, 180000.00, 50000.00, 100.00, 580000.00),
(1, 'AFF2024-046', 'Installation bornes IRVE Parking Bellecour', 10, 'Place Bellecour', '69002', 'LYON', 12, 2, 2, 'TERMINE', '2024-02-01', '2024-03-15', '2024-05-01', '2024-08-31', 320000.00, 180000.00, 80000.00, 20000.00, 100.00, 320000.00),
(1, 'AFF2024-047', 'Mise en conformite electrique Lycee Ampere', 12, '31 Rue de la Bourse', '69002', 'LYON', 1, 2, 1, 'TERMINE', '2024-03-01', '2024-05-01', '2024-07-01', '2024-10-31', 450000.00, 180000.00, 170000.00, 40000.00, 100.00, 450000.00),
-- Affaires en devis
(1, 'AFF2025-020', 'Construction EHPAD Macon - Lot CFO/CFA', 52, '15 Rue de la Liberte', '71000', 'MACON', 1, 1, 3, 'DEVIS', '2025-09-01', NULL, '2026-03-01', '2027-06-30', 780000.00, 280000.00, 280000.00, 100000.00, 0.00, 0.00),
(1, 'AFF2025-021', 'Centrale photovoltaique Roanne 5MW', 13, 'ZI du Coteau', '42120', 'LE COTEAU', 11, 2, 2, 'DEVIS', '2025-08-15', NULL, '2026-04-01', '2026-12-31', 2200000.00, 1400000.00, 400000.00, 200000.00, 0.00, 0.00),
(1, 'AFF2025-022', 'Extension Centre Commercial Porte des Alpes', 60, 'ZAC Porte des Alpes', '69800', 'SAINT-PRIEST', 1, 1, 1, 'ETUDE', '2025-10-01', NULL, '2026-06-01', '2027-03-31', 1450000.00, 520000.00, 480000.00, 200000.00, 0.00, 0.00);

-- Generer plus d'affaires
DO $$
DECLARE
    clients INTEGER[];
    natures INTEGER[];
    charges INTEGER[];
    etats ref.etat_affaire[] := ARRAY['EN_COURS', 'TERMINE', 'DEVIS', 'ETUDE', 'PROSPECT'];
    i INTEGER;
    code_aff VARCHAR(20);
    client_id INTEGER;
    montant NUMERIC(15,2);
BEGIN
    SELECT ARRAY_AGG(id) INTO clients FROM tiers.client WHERE societe_id = 1 AND code < 'CLI100';
    SELECT ARRAY_AGG(id) INTO natures FROM ref.nature_travaux;
    SELECT ARRAY_AGG(id) INTO charges FROM tiers.charge_affaire WHERE societe_id = 1;

    FOR i IN 1..40 LOOP
        code_aff := 'AFF2024-' || LPAD((30 + i)::TEXT, 3, '0');
        client_id := clients[1 + (i % array_length(clients, 1))];
        montant := (50000 + RANDOM() * 500000)::NUMERIC(15,2);

        INSERT INTO affaire.affaire (societe_id, code, intitule, client_id, ville_chantier, nature_travaux_id, type_marche_id, charge_affaire_id, etat, date_creation, montant_marche_ht, budget_fournitures, budget_main_oeuvre, pct_avancement)
        VALUES (
            1,
            code_aff,
            'Affaire ' || code_aff,
            client_id,
            'LYON',
            natures[1 + (i % array_length(natures, 1))],
            1 + (i % 4),
            charges[1 + (i % array_length(charges, 1))],
            etats[1 + (i % 5)],
            '2025-01-01'::DATE + (i * 7),
            montant,
            montant * 0.35,
            montant * 0.35,
            CASE WHEN i % 5 = 0 THEN 100 WHEN i % 5 IN (1,2) THEN (RANDOM() * 80)::INT ELSE 0 END
        );
    END LOOP;
END $$;

-- ============================================================================
-- 11. CHANTIERS
-- ============================================================================

-- Chantiers lies aux affaires principales
INSERT INTO chantier.chantier (societe_id, affaire_id, code, intitule, client_id, adresse, code_postal, ville, nature_travaux_id, conducteur_travaux_id, chef_equipe_id, etat, date_debut_prevue, date_fin_prevue, montant_ht, pct_avancement) VALUES
-- Affaire Part-Dieu
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-001'), 'CHT2025-001-A', 'Tour T3 - Niveaux -2 a 0', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-001'), '129 Rue Servient', '69003', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL031'), (SELECT id FROM tiers.salarie WHERE code = 'SAL040'), 'EN_COURS', '2025-01-15', '2025-06-30', 450000.00, 80.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-001'), 'CHT2025-001-B', 'Tour T3 - Niveaux 1 a 10', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-001'), '129 Rue Servient', '69003', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL031'), (SELECT id FROM tiers.salarie WHERE code = 'SAL041'), 'EN_COURS', '2025-04-01', '2025-10-31', 680000.00, 45.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-001'), 'CHT2025-001-C', 'Tour T3 - Niveaux 11 a 20', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-001'), '129 Rue Servient', '69003', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL032'), (SELECT id FROM tiers.salarie WHERE code = 'SAL042'), 'PLANIFIE', '2025-08-01', '2026-02-28', 720000.00, 10.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-001'), 'CHT2025-001-D', 'Tour T3 - Niveaux 21 a 30', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-001'), '129 Rue Servient', '69003', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL032'), (SELECT id FROM tiers.salarie WHERE code = 'SAL043'), 'A_PLANIFIER', '2025-12-01', '2026-06-30', 850000.00, 0.00),
-- Affaire CHU
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-002'), 'CHT2025-002-A', 'CHU Lyon Sud - Batiment A', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-002'), '165 Chemin du Grand Revoyet', '69310', 'PIERRE-BENITE', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL033'), (SELECT id FROM tiers.salarie WHERE code = 'SAL044'), 'EN_COURS', '2025-02-01', '2025-12-31', 1200000.00, 30.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-002'), 'CHT2025-002-B', 'CHU Lyon Sud - Batiment B', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-002'), '165 Chemin du Grand Revoyet', '69310', 'PIERRE-BENITE', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL033'), (SELECT id FROM tiers.salarie WHERE code = 'SAL040'), 'PLANIFIE', '2025-09-01', '2026-06-30', 1400000.00, 5.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-002'), 'CHT2025-002-C', 'CHU Lyon Sud - Liaisons', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-002'), '165 Chemin du Grand Revoyet', '69310', 'PIERRE-BENITE', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL034'), NULL, 'A_PLANIFIER', '2026-03-01', '2026-12-31', 900000.00, 0.00),
-- Affaire Data Center
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-003'), 'CHT2025-003-A', 'Data Center Vaise - TGBT et distribution', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-003'), '25 Rue Cdt Charcot', '69005', 'LYON', 8, (SELECT id FROM tiers.salarie WHERE code = 'SAL031'), (SELECT id FROM tiers.salarie WHERE code = 'SAL041'), 'EN_COURS', '2025-03-01', '2025-08-31', 850000.00, 75.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-003'), 'CHT2025-003-B', 'Data Center Vaise - Salles serveurs', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-003'), '25 Rue Cdt Charcot', '69005', 'LYON', 8, (SELECT id FROM tiers.salarie WHERE code = 'SAL032'), (SELECT id FROM tiers.salarie WHERE code = 'SAL042'), 'EN_COURS', '2025-05-01', '2025-11-30', 650000.00, 50.00),
-- Affaire Residence
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-005'), 'CHT2025-005-A', 'Residence Gerland - Batiment A (30 lgts)', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-005'), '45 Avenue Tony Garnier', '69007', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL034'), (SELECT id FROM tiers.salarie WHERE code = 'SAL043'), 'EN_COURS', '2025-03-01', '2025-10-31', 450000.00, 60.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-005'), 'CHT2025-005-B', 'Residence Gerland - Batiment B (35 lgts)', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-005'), '45 Avenue Tony Garnier', '69007', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL034'), (SELECT id FROM tiers.salarie WHERE code = 'SAL044'), 'EN_COURS', '2025-05-01', '2025-12-31', 480000.00, 45.00),
(1, (SELECT id FROM affaire.affaire WHERE code = 'AFF2025-005'), 'CHT2025-005-C', 'Residence Gerland - Parties communes', (SELECT client_id FROM affaire.affaire WHERE code = 'AFF2025-005'), '45 Avenue Tony Garnier', '69007', 'LYON', 1, (SELECT id FROM tiers.salarie WHERE code = 'SAL034'), NULL, 'PLANIFIE', '2025-10-01', '2026-03-31', 220000.00, 10.00);

-- ============================================================================
-- 12. DOCUMENTS COMMERCIAUX
-- ============================================================================

-- Factures pour l'affaire Part-Dieu
INSERT INTO document.entete_document (societe_id, type_document, numero, date_document, tiers_type, tiers_id, fact_intitule, fact_adresse, fact_code_postal, fact_ville, affaire_id, chantier_id, redacteur_id, categorie_av_code, mode_reglement_code, montant_ht, montant_tva, montant_ttc, etat_id, reference_client)
SELECT
    1, 'FACTURE', 'FA24' || LPAD(ROW_NUMBER() OVER()::TEXT, 5, '0'),
    ('2024-' || LPAD(m::TEXT, 2, '0') || '-' || LPAD((10 + m)::TEXT, 2, '0'))::DATE,
    'CLIENT', c.id, c.intitule, c.adresse_ligne1, c.code_postal, c.ville,
    a.id, ch.id,
    (SELECT id FROM tiers.salarie WHERE code = 'SAL011'),
    'V', '45FM',
    (50000 + RANDOM() * 150000)::NUMERIC(15,2),
    0, 0, 10,
    'BC-' || LPAD((1000 + m * 10)::TEXT, 6, '0')
FROM generate_series(1, 10) m
CROSS JOIN LATERAL (SELECT * FROM affaire.affaire WHERE code = 'AFF2024-001' LIMIT 1) a
CROSS JOIN LATERAL (SELECT * FROM tiers.client WHERE id = a.client_id LIMIT 1) c
CROSS JOIN LATERAL (SELECT * FROM chantier.chantier WHERE affaire_id = a.id ORDER BY RANDOM() LIMIT 1) ch;

-- Mettre a jour TVA et TTC
UPDATE document.entete_document
SET montant_tva = ROUND(montant_ht * 0.20, 2),
    montant_net_ht = montant_ht,
    montant_ttc = ROUND(montant_ht * 1.20, 2)
WHERE type_document = 'FACTURE';

-- Lignes de factures
INSERT INTO document.ligne_document (entete_id, ligne_numero, type_ligne, element_id, code_article, designation, quantite, unite_code, prix_unitaire, montant_net_ht, taux_tva_id, montant_tva, nature_id)
SELECT
    d.id,
    ROW_NUMBER() OVER (PARTITION BY d.id),
    'ARTICLE',
    e.id,
    e.code,
    e.designation,
    (10 + RANDOM() * 100)::NUMERIC(15,4),
    e.unite_mesure_code,
    e.prix_vente,
    (10 + RANDOM() * 100)::NUMERIC(15,4) * e.prix_vente,
    1,
    ROUND((10 + RANDOM() * 100)::NUMERIC(15,4) * e.prix_vente * 0.20, 2),
    e.nature_id
FROM document.entete_document d
CROSS JOIN LATERAL (SELECT * FROM ref.element WHERE societe_id = 1 ORDER BY RANDOM() LIMIT 5) e
WHERE d.type_document = 'FACTURE';

-- Devis
INSERT INTO document.entete_document (societe_id, type_document, numero, date_document, date_validite, tiers_type, tiers_id, fact_intitule, affaire_id, redacteur_id, categorie_av_code, mode_reglement_code, montant_ht, montant_tva, montant_ttc, etat_id)
SELECT
    1, 'DEVIS', 'DV24' || LPAD(ROW_NUMBER() OVER()::TEXT, 5, '0'),
    ('2024-' || LPAD((1 + (i % 11))::TEXT, 2, '0') || '-15')::DATE,
    ('2024-' || LPAD((1 + ((i + 2) % 12))::TEXT, 2, '0') || '-15')::DATE,
    'CLIENT', c.id, c.intitule,
    NULL,
    (SELECT id FROM tiers.salarie ORDER BY RANDOM() LIMIT 1),
    'V', '45FM',
    (30000 + RANDOM() * 200000)::NUMERIC(15,2),
    0, 0,
    CASE WHEN RANDOM() < 0.3 THEN 3 WHEN RANDOM() < 0.6 THEN 2 ELSE 1 END
FROM generate_series(1, 30) i
CROSS JOIN LATERAL (SELECT * FROM tiers.client WHERE societe_id = 1 ORDER BY RANDOM() LIMIT 1) c;

UPDATE document.entete_document
SET montant_tva = ROUND(montant_ht * 0.20, 2),
    montant_net_ht = montant_ht,
    montant_ttc = ROUND(montant_ht * 1.20, 2)
WHERE type_document = 'DEVIS';

-- ============================================================================
-- 13. SUIVI MAIN D'OEUVRE
-- ============================================================================

-- Generer des pointages pour les 6 derniers mois
DO $$
DECLARE
    chantiers INTEGER[];
    salaries INTEGER[];
    dt DATE;
    i INTEGER;
    s INTEGER;
    ch INTEGER;
BEGIN
    SELECT ARRAY_AGG(id) INTO chantiers FROM chantier.chantier WHERE etat IN ('EN_COURS', 'PLANIFIE');
    SELECT ARRAY_AGG(id) INTO salaries FROM tiers.salarie WHERE fonction = 'Electricien' AND actif = TRUE;

    FOR dt IN SELECT generate_series('2025-06-01'::DATE, '2025-11-30'::DATE, '1 day'::INTERVAL)::DATE LOOP
        -- Pas de pointage le week-end
        IF EXTRACT(DOW FROM dt) NOT IN (0, 6) THEN
            -- Pour chaque chantier actif, affecter quelques salaries
            FOREACH ch IN ARRAY chantiers LOOP
                FOR i IN 1..4 LOOP
                    s := salaries[1 + ((ch + i + EXTRACT(DOY FROM dt)::INT) % array_length(salaries, 1))];

                    INSERT INTO chantier.suivi_mo (chantier_id, salarie_id, date_travail, heures_normales, heures_sup_25, deplacements, paniers)
                    VALUES (
                        ch, s, dt,
                        7 + RANDOM(),
                        CASE WHEN RANDOM() < 0.2 THEN 1 + RANDOM() ELSE 0 END,
                        1,
                        1
                    );
                END LOOP;
            END LOOP;
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- 14. MOUVEMENTS DE STOCK
-- ============================================================================

-- Stock initial
INSERT INTO stock.stock_article (element_id, depot_id, quantite_stock, prix_moyen_pondere, dernier_prix_achat, date_dernier_mvt)
SELECT
    e.id,
    d.id,
    (50 + RANDOM() * 500)::NUMERIC(15,4),
    e.prix_achat,
    e.prix_achat,
    CURRENT_DATE - (RANDOM() * 30)::INT
FROM ref.element e
CROSS JOIN ref.depot d
WHERE e.gere_en_stock = TRUE AND e.societe_id = 1;

-- Mouvements de sortie chantier
INSERT INTO stock.mouvement (societe_id, element_id, depot_id, type_mvt, date_mvt, quantite, prix_unitaire, montant_total, chantier_id, reference, libelle)
SELECT
    1,
    e.id,
    1, -- Depot siege
    'SORTIE',
    ('2024-' || LPAD((1 + (i % 11))::TEXT, 2, '0') || '-' || LPAD((5 + i % 20)::TEXT, 2, '0'))::TIMESTAMP,
    (5 + RANDOM() * 50)::NUMERIC(15,4),
    e.prix_achat,
    (5 + RANDOM() * 50) * e.prix_achat,
    ch.id,
    'BS24' || LPAD(i::TEXT, 5, '0'),
    'Sortie chantier ' || ch.code
FROM generate_series(1, 200) i
CROSS JOIN LATERAL (SELECT * FROM ref.element WHERE gere_en_stock = TRUE AND societe_id = 1 ORDER BY RANDOM() LIMIT 1) e
CROSS JOIN LATERAL (SELECT * FROM chantier.chantier WHERE etat = 'EN_COURS' ORDER BY RANDOM() LIMIT 1) ch;

-- ============================================================================
-- STATISTIQUES FINALES
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '=== STATISTIQUES SEED MDE ERP ===';
    RAISE NOTICE 'Societes: %', (SELECT COUNT(*) FROM ref.societe);
    RAISE NOTICE 'Clients: %', (SELECT COUNT(*) FROM tiers.client);
    RAISE NOTICE 'Fournisseurs: %', (SELECT COUNT(*) FROM tiers.fournisseur);
    RAISE NOTICE 'Sous-traitants: %', (SELECT COUNT(*) FROM tiers.sous_traitant);
    RAISE NOTICE 'Salaries: %', (SELECT COUNT(*) FROM tiers.salarie);
    RAISE NOTICE 'Elements/Articles: %', (SELECT COUNT(*) FROM ref.element);
    RAISE NOTICE 'Affaires: %', (SELECT COUNT(*) FROM affaire.affaire);
    RAISE NOTICE 'Chantiers: %', (SELECT COUNT(*) FROM chantier.chantier);
    RAISE NOTICE 'Documents: %', (SELECT COUNT(*) FROM document.entete_document);
    RAISE NOTICE 'Pointages MO: %', (SELECT COUNT(*) FROM chantier.suivi_mo);
    RAISE NOTICE 'Mouvements stock: %', (SELECT COUNT(*) FROM stock.mouvement);
END $$;

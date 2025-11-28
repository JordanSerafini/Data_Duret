-- ============================================================================
-- SAGE 100 COMPTABILITE - SEED DATA COMPLET
-- Donnees de demonstration realistes pour le Groupe DURET
-- ============================================================================

\c sage_compta;

-- ============================================================================
-- 1. REFERENTIELS DE BASE
-- ============================================================================

-- Devises
INSERT INTO ref.devise (code, nom, symbole, taux_euro, nb_decimales) VALUES
('EUR', 'Euro', '€', 1.000000, 2),
('USD', 'Dollar americain', '$', 1.085000, 2),
('GBP', 'Livre sterling', '£', 0.858000, 2),
('CHF', 'Franc suisse', 'CHF', 0.945000, 2),
('MAD', 'Dirham marocain', 'DH', 10.850000, 2),
('TND', 'Dinar tunisien', 'DT', 3.350000, 3),
('XOF', 'Franc CFA', 'FCFA', 655.957000, 0),
('CAD', 'Dollar canadien', 'CAD', 1.470000, 2);

-- Pays
INSERT INTO ref.pays (code_iso, code_iso3, nom, code_devise, code_telephone, ue) VALUES
('FR', 'FRA', 'France', 'EUR', '+33', TRUE),
('DE', 'DEU', 'Allemagne', 'EUR', '+49', TRUE),
('BE', 'BEL', 'Belgique', 'EUR', '+32', TRUE),
('ES', 'ESP', 'Espagne', 'EUR', '+34', TRUE),
('IT', 'ITA', 'Italie', 'EUR', '+39', TRUE),
('PT', 'PRT', 'Portugal', 'EUR', '+351', TRUE),
('NL', 'NLD', 'Pays-Bas', 'EUR', '+31', TRUE),
('LU', 'LUX', 'Luxembourg', 'EUR', '+352', TRUE),
('CH', 'CHE', 'Suisse', 'CHF', '+41', FALSE),
('GB', 'GBR', 'Royaume-Uni', 'GBP', '+44', FALSE),
('US', 'USA', 'Etats-Unis', 'USD', '+1', FALSE),
('CA', 'CAN', 'Canada', 'CAD', '+1', FALSE),
('MA', 'MAR', 'Maroc', 'MAD', '+212', FALSE),
('TN', 'TUN', 'Tunisie', 'TND', '+216', FALSE),
('SN', 'SEN', 'Senegal', 'XOF', '+221', FALSE),
('CI', 'CIV', 'Cote d''Ivoire', 'XOF', '+225', FALSE);

-- Modes de reglement
INSERT INTO ref.mode_reglement (code, libelle, type_reglement, nb_jours, fin_de_mois) VALUES
('ESP', 'Especes', 'ESPECES', 0, FALSE),
('CHQ', 'Cheque', 'CHEQUE', 0, FALSE),
('VIR', 'Virement', 'VIREMENT', 0, FALSE),
('CB', 'Carte bancaire', 'CB', 0, FALSE),
('PREL', 'Prelevement', 'PRELEVEMENT', 0, FALSE),
('TRAI', 'Traite', 'TRAITE', 0, FALSE),
('30J', '30 jours net', 'VIREMENT', 30, FALSE),
('30FM', '30 jours fin de mois', 'VIREMENT', 30, TRUE),
('45FM', '45 jours fin de mois', 'VIREMENT', 45, TRUE),
('60J', '60 jours net', 'VIREMENT', 60, FALSE),
('60FM', '60 jours fin de mois', 'VIREMENT', 60, TRUE),
('90FM', '90 jours fin de mois', 'TRAITE', 90, TRUE);

-- Societes du groupe DURET
INSERT INTO ref.societe (code, nom, siret, siren, code_ape, adresse, code_postal, ville, pays, telephone, email, capital, forme_juridique, date_creation, exercice_debut, exercice_fin) VALUES
('DURETELEC', 'DURET ELECTRICITE SAS', '12345678901234', '123456789', '4321A', '15 Rue de l''Industrie', '69100', 'VILLEURBANNE', 'FRANCE', '04 72 XX XX XX', 'contact@duret-elec.fr', 500000.00, 'SAS', '1985-03-15', '2025-01-01', '2025-12-31'),
('DURETENE', 'DURET ENERGIE SARL', '23456789012345', '234567890', '4322B', '15 Rue de l''Industrie', '69100', 'VILLEURBANNE', 'FRANCE', '04 72 XX XX XX', 'contact@duret-energie.fr', 250000.00, 'SARL', '1998-06-01', '2025-01-01', '2025-12-31'),
('DURETRES', 'DURET RESEAUX SA', '34567890123456', '345678901', '4321A', '22 Avenue des Reseaux', '69003', 'LYON', 'FRANCE', '04 78 XX XX XX', 'contact@duret-reseaux.fr', 750000.00, 'SA', '2002-01-10', '2025-01-01', '2025-12-31'),
('DURETSER', 'DURET SERVICES SAS', '45678901234567', '456789012', '4329Z', '8 Place Bellecour', '69002', 'LYON', 'FRANCE', '04 78 XX XX XX', 'contact@duret-services.fr', 150000.00, 'SAS', '2010-09-01', '2025-01-01', '2025-12-31');

-- Exercices comptables
INSERT INTO ref.exercice (societe_id, code, libelle, date_debut, date_fin, cloture, date_cloture) VALUES
(1, '2023', 'Exercice 2023', '2023-01-01', '2023-12-31', TRUE, '2024-03-31'),
(1, '2024', 'Exercice 2024', '2024-01-01', '2024-12-31', TRUE, '2025-03-31'),
(1, '2025', 'Exercice 2025', '2025-01-01', '2025-12-31', FALSE, NULL),
(2, '2023', 'Exercice 2023', '2023-01-01', '2023-12-31', TRUE, '2024-03-31'),
(2, '2024', 'Exercice 2024', '2024-01-01', '2024-12-31', TRUE, '2025-03-31'),
(2, '2025', 'Exercice 2025', '2025-01-01', '2025-12-31', FALSE, NULL),
(3, '2023', 'Exercice 2023', '2023-01-01', '2023-12-31', TRUE, '2024-03-31'),
(3, '2024', 'Exercice 2024', '2024-01-01', '2024-12-31', TRUE, '2025-03-31'),
(3, '2025', 'Exercice 2025', '2025-01-01', '2025-12-31', FALSE, NULL),
(4, '2024', 'Exercice 2024', '2024-01-01', '2024-12-31', TRUE, '2025-03-31'),
(4, '2025', 'Exercice 2025', '2025-01-01', '2025-12-31', FALSE, NULL);

-- ============================================================================
-- 2. PLAN COMPTABLE GENERAL (PCG 2024)
-- ============================================================================

-- Comptes de classe 1 - Capitaux
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '101000', 'Capital social', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '106100', 'Reserve legale', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '106800', 'Autres reserves', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '110000', 'Report a nouveau crediteur', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '119000', 'Report a nouveau debiteur', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '120000', 'Resultat de l''exercice (benefice)', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '129000', 'Resultat de l''exercice (perte)', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '164000', 'Emprunts aupres des etablissements de credit', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '165000', 'Depots et cautionnements recus', 'BILAN', 'PASSIF', 'C', FALSE, FALSE);

-- Comptes de classe 2 - Immobilisations
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '205000', 'Concessions et droits similaires', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '206000', 'Droit au bail', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '207000', 'Fonds commercial', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '211000', 'Terrains', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '213000', 'Constructions', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '215400', 'Materiel industriel', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '218200', 'Materiel de transport', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '218300', 'Materiel de bureau et informatique', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '218400', 'Mobilier', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '231000', 'Immobilisations corporelles en cours', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '275000', 'Depots et cautionnements verses', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '280500', 'Amortissements des concessions', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '281300', 'Amortissements des constructions', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '281540', 'Amortissements du materiel industriel', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '281820', 'Amortissements du materiel de transport', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '281830', 'Amortissements du materiel informatique', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '281840', 'Amortissements du mobilier', 'BILAN', 'ACTIF', 'C', FALSE, FALSE);

-- Comptes de classe 3 - Stocks
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '311000', 'Matieres premieres', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '321000', 'Matieres consommables', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '326000', 'Emballages', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '331000', 'Produits en cours', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '355000', 'Produits finis', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '371000', 'Marchandises', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '391000', 'Provisions pour depreciation matieres premieres', 'BILAN', 'ACTIF', 'C', FALSE, FALSE),
(1, '397100', 'Provisions pour depreciation marchandises', 'BILAN', 'ACTIF', 'C', FALSE, FALSE);

-- Comptes de classe 4 - Tiers
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '401000', 'Fournisseurs', 'BILAN', 'PASSIF', 'C', TRUE, TRUE),
(1, '401100', 'Fournisseurs - Achats de biens', 'BILAN', 'PASSIF', 'C', TRUE, TRUE),
(1, '401200', 'Fournisseurs - Prestations de services', 'BILAN', 'PASSIF', 'C', TRUE, TRUE),
(1, '403000', 'Fournisseurs - Effets a payer', 'BILAN', 'PASSIF', 'C', TRUE, FALSE),
(1, '404000', 'Fournisseurs d''immobilisations', 'BILAN', 'PASSIF', 'C', TRUE, TRUE),
(1, '408000', 'Fournisseurs - Factures non parvenues', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '409100', 'Fournisseurs - Avances et acomptes verses', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '411000', 'Clients', 'BILAN', 'ACTIF', 'D', TRUE, TRUE),
(1, '411100', 'Clients - Ventes de biens', 'BILAN', 'ACTIF', 'D', TRUE, TRUE),
(1, '411200', 'Clients - Prestations de services', 'BILAN', 'ACTIF', 'D', TRUE, TRUE),
(1, '413000', 'Clients - Effets a recevoir', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '416000', 'Clients douteux ou litigieux', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '418000', 'Clients - Produits non encore factures', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '419100', 'Clients - Avances et acomptes recus', 'BILAN', 'PASSIF', 'C', TRUE, FALSE),
(1, '421000', 'Personnel - Remunerations dues', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '425000', 'Personnel - Avances et acomptes', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '428000', 'Personnel - Charges a payer', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '431000', 'Securite sociale', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '437000', 'Autres organismes sociaux', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '441000', 'Etat - Subventions a recevoir', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '442000', 'Etat - Impots et taxes recouvrables', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '443000', 'Operations particulieres avec l''Etat', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '444000', 'Etat - Impots sur les benefices', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '445510', 'TVA a decaisser', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '445620', 'TVA deductible sur immobilisations', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '445660', 'TVA deductible sur autres biens et services', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '445670', 'Credit de TVA a reporter', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '445710', 'TVA collectee', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '447000', 'Autres impots, taxes et versements assimiles', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '455000', 'Associes - Comptes courants', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '467000', 'Autres comptes debiteurs ou crediteurs', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '471000', 'Compte d''attente', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '476000', 'Difference de conversion - Actif', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '477000', 'Difference de conversion - Passif', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '486000', 'Charges constatees d''avance', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '487000', 'Produits constates d''avance', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '491000', 'Provisions pour depreciation comptes clients', 'BILAN', 'ACTIF', 'C', FALSE, FALSE);

-- Comptes de classe 5 - Financiers
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '503000', 'Actions', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '506000', 'Obligations', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '508000', 'Autres valeurs mobilieres', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '511000', 'Valeurs a l''encaissement', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '512100', 'Banque BNP Paribas', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '512200', 'Banque Credit Agricole', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '512300', 'Banque Societe Generale', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '514000', 'Cheques postaux', 'BILAN', 'ACTIF', 'D', TRUE, FALSE),
(1, '517000', 'Autres organismes financiers', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '518000', 'Interets courus', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '519000', 'Concours bancaires courants', 'BILAN', 'PASSIF', 'C', FALSE, FALSE),
(1, '530000', 'Caisse', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '531100', 'Caisse siege', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '531200', 'Caisse chantiers', 'BILAN', 'ACTIF', 'D', FALSE, FALSE),
(1, '580000', 'Virements internes', 'BILAN', 'ACTIF', 'D', FALSE, FALSE);

-- Comptes de classe 6 - Charges
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '601100', 'Achats de matieres premieres', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '601200', 'Achats de materiel electrique', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '602200', 'Achats de fournitures consommables', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '602600', 'Achats d''emballages', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '604000', 'Achats d''etudes et prestations', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '605000', 'Achats de materiels et equipements', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606100', 'Fournitures non stockables - Eau', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606110', 'Fournitures non stockables - Electricite', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606120', 'Fournitures non stockables - Gaz', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606130', 'Fournitures non stockables - Carburants', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606400', 'Fournitures administratives', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '606800', 'Autres matieres et fournitures', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '607000', 'Achats de marchandises', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '609100', 'Rabais, remises obtenus sur achats', 'GESTION', 'CHARGE', 'C', FALSE, FALSE),
(1, '611000', 'Sous-traitance generale', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '612000', 'Redevances de credit-bail', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '613000', 'Locations immobilieres', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '613500', 'Locations mobilieres', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '614000', 'Charges locatives et copropriete', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '615000', 'Entretien et reparations', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '615200', 'Entretien sur biens immobiliers', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '615500', 'Entretien sur biens mobiliers', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '616000', 'Primes d''assurance', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '617000', 'Etudes et recherches', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '618100', 'Documentation generale', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '618500', 'Seminaires, conferences', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '621000', 'Personnel exterieur a l''entreprise', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '622600', 'Honoraires', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '622700', 'Frais d''actes et de contentieux', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '623100', 'Annonces et insertions', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '623400', 'Cadeaux a la clientele', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '623700', 'Publications', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '624000', 'Transports de biens', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '625100', 'Voyages et deplacements', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '625600', 'Missions', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '625700', 'Receptions', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '626000', 'Frais postaux et telecom', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '627000', 'Services bancaires', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '628100', 'Cotisations', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '631100', 'Taxe d''apprentissage', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '631200', 'Formation continue', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '633100', 'Participation construction', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '635100', 'Taxe fonciere', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '635110', 'Contribution economique territoriale', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '635120', 'Taxes sur vehicules', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '637000', 'Autres impots et taxes', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '641100', 'Salaires et appointements', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '641200', 'Conges payes', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '641300', 'Primes et gratifications', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '641400', 'Indemnites et avantages divers', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '644000', 'Remuneration du travail de l''exploitant', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '645100', 'Cotisations URSSAF', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '645200', 'Cotisations retraite', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '645300', 'Cotisations prevoyance', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '645400', 'Cotisations assedic', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '647000', 'Autres charges sociales', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '648000', 'Autres charges de personnel', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '651000', 'Redevances pour concessions', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '654000', 'Pertes sur creances irrecouvrables', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '658000', 'Charges diverses de gestion courante', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '661000', 'Charges d''interets', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '661100', 'Interets des emprunts', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '661600', 'Interets bancaires', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '665000', 'Escomptes accordes', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '666000', 'Pertes de change', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '668000', 'Autres charges financieres', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '671000', 'Charges exceptionnelles d''exploitation', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '675000', 'Valeur comptable elements actifs cedes', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '678000', 'Autres charges exceptionnelles', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '681100', 'Dotations amortissements immobilisations', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '681400', 'Dotations provisions charges exploitation', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '686000', 'Dotations provisions financieres', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '687000', 'Dotations provisions exceptionnelles', 'GESTION', 'CHARGE', 'D', FALSE, FALSE),
(1, '695000', 'Impots sur les benefices', 'GESTION', 'CHARGE', 'D', FALSE, FALSE);

-- Comptes de classe 7 - Produits
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif) VALUES
(1, '701000', 'Ventes de produits finis', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '704000', 'Travaux', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '704100', 'Travaux electricite', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '704200', 'Travaux energie', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '704300', 'Travaux reseaux', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '706000', 'Prestations de services', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '706100', 'Maintenance et SAV', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '706200', 'Etudes et conseils', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '707000', 'Ventes de marchandises', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '708000', 'Produits des activites annexes', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '708500', 'Ports et frais factures', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '709000', 'Rabais, remises accordes', 'GESTION', 'PRODUIT', 'D', FALSE, FALSE),
(1, '713000', 'Variation des en-cours production', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '721000', 'Production immobilisee', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '740000', 'Subventions d''exploitation', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '751000', 'Redevances pour concessions', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '758000', 'Produits divers de gestion courante', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '761000', 'Produits de participations', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '762000', 'Produits des autres immobilisations', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '764000', 'Revenus des valeurs mobilieres', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '765000', 'Escomptes obtenus', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '766000', 'Gains de change', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '768000', 'Autres produits financiers', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '771000', 'Produits exceptionnels d''exploitation', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '775000', 'Produits des cessions d''actifs', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '778000', 'Autres produits exceptionnels', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '781000', 'Reprises sur amortissements', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '786000', 'Reprises sur provisions financieres', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '787000', 'Reprises sur provisions exceptionnelles', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '791000', 'Transferts de charges d''exploitation', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '796000', 'Transferts de charges financieres', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE),
(1, '797000', 'Transferts de charges exceptionnelles', 'GESTION', 'PRODUIT', 'C', FALSE, FALSE);

-- Copier le plan comptable pour les autres societes
INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif)
SELECT 2, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif FROM compta.compte_general WHERE societe_id = 1;

INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif)
SELECT 3, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif FROM compta.compte_general WHERE societe_id = 1;

INSERT INTO compta.compte_general (societe_id, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif)
SELECT 4, numero, intitule, type_compte, nature, sens_defaut, lettrable, collectif FROM compta.compte_general WHERE societe_id = 1;

-- ============================================================================
-- 3. TAUX DE TVA
-- ============================================================================

INSERT INTO compta.taux_tva (code, libelle, taux, type_tva, compte_tva_collectee, compte_tva_deductible, actif) VALUES
('N20', 'TVA normale 20%', 20.00, 'NORMAL', '445710', '445660', TRUE),
('I10', 'TVA intermediaire 10%', 10.00, 'INTERMEDIAIRE', '445710', '445660', TRUE),
('R55', 'TVA reduite 5.5%', 5.50, 'REDUIT', '445710', '445660', TRUE),
('R21', 'TVA super reduite 2.1%', 2.10, 'SUPER_REDUIT', '445710', '445660', TRUE),
('EXO', 'Exonere de TVA', 0.00, 'EXONERE', NULL, NULL, TRUE),
('AUT', 'Autoliquidation', 0.00, 'EXONERE', NULL, NULL, TRUE);

-- ============================================================================
-- 4. AXES ANALYTIQUES
-- ============================================================================

INSERT INTO compta.axe_analytique (societe_id, code, libelle, obligatoire, actif) VALUES
(1, 'AXE1', 'Chantiers / Affaires', TRUE, TRUE),
(1, 'AXE2', 'Services / Activites', FALSE, TRUE),
(1, 'AXE3', 'Projets', FALSE, TRUE);

-- Comptes analytiques - Chantiers
INSERT INTO compta.compte_analytique (axe_id, numero, intitule, niveau) VALUES
(1, 'AFF2025001', 'Chantier Lyon Part-Dieu - Electricite', 1),
(1, 'AFF2025002', 'Chantier Grenoble Campus - Reseaux', 1),
(1, 'AFF2025003', 'Chantier Annecy Tertiaire - Energie', 1),
(1, 'AFF2025004', 'Chantier Villeurbanne Residence', 1),
(1, 'AFF2025005', 'Maintenance Leclerc - Annuel', 1),
(1, 'AFF2025006', 'Projet Solaire Photovoltaique Roanne', 1),
(1, 'AFF2025007', 'Chantier Data Center Lyon', 1),
(1, 'AFF2025008', 'Extension EHPAD Macon', 1),
(1, 'AFF2025009', 'Renovation Mairie Chambery', 1),
(1, 'AFF2025010', 'Installation Bornes Electriques A6', 1);

-- ============================================================================
-- 5. JOURNAUX COMPTABLES
-- ============================================================================

INSERT INTO compta.journal (societe_id, code, intitule, type_journal, compte_contrepartie, actif) VALUES
-- Societe 1 - DURETELEC
(1, 'ACH', 'Journal des achats', 'ACHAT', NULL, TRUE),
(1, 'VTE', 'Journal des ventes', 'VENTE', NULL, TRUE),
(1, 'BQ1', 'Banque BNP Paribas', 'TRESORERIE', '512100', TRUE),
(1, 'BQ2', 'Banque Credit Agricole', 'TRESORERIE', '512200', TRUE),
(1, 'CAI', 'Caisse', 'TRESORERIE', '530000', TRUE),
(1, 'OD', 'Operations diverses', 'OD', NULL, TRUE),
(1, 'SAL', 'Salaires', 'OD', NULL, TRUE),
(1, 'AN', 'A nouveaux', 'AN', NULL, TRUE),
-- Societe 2 - DURETENE
(2, 'ACH', 'Journal des achats', 'ACHAT', NULL, TRUE),
(2, 'VTE', 'Journal des ventes', 'VENTE', NULL, TRUE),
(2, 'BQ1', 'Banque BNP Paribas', 'TRESORERIE', '512100', TRUE),
(2, 'OD', 'Operations diverses', 'OD', NULL, TRUE),
(2, 'AN', 'A nouveaux', 'AN', NULL, TRUE),
-- Societe 3 - DURETRES
(3, 'ACH', 'Journal des achats', 'ACHAT', NULL, TRUE),
(3, 'VTE', 'Journal des ventes', 'VENTE', NULL, TRUE),
(3, 'BQ1', 'Banque Societe Generale', 'TRESORERIE', '512300', TRUE),
(3, 'OD', 'Operations diverses', 'OD', NULL, TRUE),
(3, 'AN', 'A nouveaux', 'AN', NULL, TRUE),
-- Societe 4 - DURETSER
(4, 'ACH', 'Journal des achats', 'ACHAT', NULL, TRUE),
(4, 'VTE', 'Journal des ventes', 'VENTE', NULL, TRUE),
(4, 'BQ1', 'Banque BNP Paribas', 'TRESORERIE', '512100', TRUE),
(4, 'OD', 'Operations diverses', 'OD', NULL, TRUE);

-- ============================================================================
-- 6. TIERS - CLIENTS (100+ clients)
-- ============================================================================

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, siret, numero_tva, adresse_ligne1, code_postal, ville, pays_code, telephone, email, compte_collectif, mode_reglement_code, encours_autorise) VALUES
-- Grands comptes
(1, 'C0001', 'CLIENT', 'BOUYGUES CONSTRUCTION', '57204186800321', 'FR12572041868', '1 Avenue Eugene Freyssinet', '78280', 'GUYANCOURT', 'FR', '01 30 60 60 60', 'contact@bouygues-construction.com', '411000', '45FM', 500000.00),
(1, 'C0002', 'CLIENT', 'VINCI ENERGIES', '40993739700312', 'FR67409937397', '1 Cours Ferdinand de Lesseps', '92851', 'RUEIL-MALMAISON', 'FR', '01 57 98 60 00', 'contact@vinci-energies.com', '411000', '60FM', 750000.00),
(1, 'C0003', 'CLIENT', 'EIFFAGE ENERGIE', '70980tried2341', 'FR45709802341', '3 Avenue Morane Saulnier', '78140', 'VELIZY', 'FR', '01 34 65 00 00', 'contact@eiffage-energie.fr', '411000', '45FM', 400000.00),
(1, 'C0004', 'CLIENT', 'SPIE BATIGNOLLES', '32393584600152', 'FR08323935846', '12 Rue de Berri', '75008', 'PARIS', 'FR', '01 44 20 70 00', 'contact@spiebatignolles.fr', '411000', '60FM', 350000.00),
(1, 'C0005', 'CLIENT', 'ENGIE SOLUTIONS', '42960942000281', 'FR19429609420', '1 Place Samuel de Champlain', '92930', 'PARIS LA DEFENSE', 'FR', '01 44 22 00 00', 'contact@engie.com', '411000', '45FM', 600000.00),
-- Collectivites
(1, 'C0010', 'CLIENT', 'METROPOLE DE LYON', '20004697600057', 'FR50200046976', '20 Rue du Lac', '69003', 'LYON', 'FR', '04 78 63 40 40', 'marches@grandlyon.com', '411000', '30J', 300000.00),
(1, 'C0011', 'CLIENT', 'VILLE DE GRENOBLE', '21380185400015', 'FR35213801854', '11 Boulevard Jean Pain', '38000', 'GRENOBLE', 'FR', '04 76 76 36 36', 'marches@grenoble.fr', '411000', '30J', 200000.00),
(1, 'C0012', 'CLIENT', 'DEPARTEMENT DU RHONE', '22690001600019', 'FR54226900016', '29-31 Cours de la Liberte', '69003', 'LYON', 'FR', '04 72 61 77 77', 'contact@rhone.fr', '411000', '30J', 250000.00),
(1, 'C0013', 'CLIENT', 'REGION AUVERGNE-RHONE-ALPES', '23840001800032', 'FR81238400018', '101 Cours Charlemagne', '69002', 'LYON', 'FR', '04 26 73 40 00', 'contact@auvergnerhonealpes.fr', '411000', '30J', 400000.00),
-- Bailleurs sociaux
(1, 'C0020', 'CLIENT', 'ALLIADE HABITAT', '77982713200137', 'FR34779827132', '143 Rue Garibaldi', '69003', 'LYON', 'FR', '04 78 95 20 00', 'contact@alliade.com', '411000', '45FM', 150000.00),
(1, 'C0021', 'CLIENT', 'LYON METROPOLE HABITAT', '38370526900024', 'FR27383705269', '195 Rue Garibaldi', '69003', 'LYON', 'FR', '04 78 60 42 42', 'contact@lmhabitat.fr', '411000', '45FM', 180000.00),
(1, 'C0022', 'CLIENT', 'OPAC DU RHONE', '77567979200016', 'FR52775679792', '3 Rue Delandine', '69002', 'LYON', 'FR', '04 72 60 10 00', 'contact@opacdurhone.fr', '411000', '30J', 200000.00),
-- Promoteurs immobiliers
(1, 'C0030', 'CLIENT', 'NEXITY', '44451614100217', 'FR79444516141', '19 Rue de Vienne', '75008', 'PARIS', 'FR', '01 85 55 19 00', 'contact@nexity.fr', '411000', '60FM', 350000.00),
(1, 'C0031', 'CLIENT', 'GROUPE PICHET', '35099159200185', 'FR62350991592', '23 Allee de Chartres', '33000', 'BORDEAUX', 'FR', '05 56 44 25 00', 'contact@pichet.com', '411000', '60FM', 280000.00),
(1, 'C0032', 'CLIENT', 'KAUFMAN & BROAD', '70201721100108', 'FR15702017211', '127 Avenue Charles de Gaulle', '92200', 'NEUILLY-SUR-SEINE', 'FR', '01 41 43 43 43', 'contact@kaufmanbroad.fr', '411000', '60FM', 320000.00),
-- Grande distribution
(1, 'C0040', 'CLIENT', 'CARREFOUR PROPERTY', '67203912600085', 'FR42672039126', '93 Avenue de Paris', '91300', 'MASSY', 'FR', '01 64 50 80 00', 'property@carrefour.com', '411000', '45FM', 200000.00),
(1, 'C0041', 'CLIENT', 'CENTRES E.LECLERC', '30297039300134', 'FR85302970393', '26 Quai Marcel Boyer', '94200', 'IVRY-SUR-SEINE', 'FR', '01 45 17 24 24', 'technique@e-leclerc.com', '411000', '45FM', 180000.00),
(1, 'C0042', 'CLIENT', 'AUCHAN RETAIL', '41004201900077', 'FR56410042019', '200 Rue de la Recherche', '59650', 'VILLENEUVE D''ASCQ', 'FR', '03 20 67 67 67', 'immobilier@auchan.fr', '411000', '45FM', 220000.00),
-- Industrie
(1, 'C0050', 'CLIENT', 'ARKEMA FRANCE', '31963279200134', 'FR29319632792', '420 Rue d''Estienne d''Orves', '92700', 'COLOMBES', 'FR', '01 49 00 80 80', 'contact@arkema.com', '411000', '45FM', 250000.00),
(1, 'C0051', 'CLIENT', 'SANOFI PASTEUR', '37996034600146', 'FR83379960346', '2 Avenue Pont Pasteur', '69007', 'LYON', 'FR', '04 37 37 37 37', 'achats@sanofi.com', '411000', '45FM', 300000.00),
(1, 'C0052', 'CLIENT', 'MICHELIN', '85520016100241', 'FR45855200161', '23 Place des Carmes', '63000', 'CLERMONT-FERRAND', 'FR', '04 73 98 59 00', 'achats@michelin.com', '411000', '45FM', 280000.00),
-- Tertiaire
(1, 'C0060', 'CLIENT', 'CREDIT AGRICOLE CENTRE-EST', '39999513500070', 'FR78399995135', '1 Rue Pierre de Truchis', '69410', 'CHAMPAGNE AU MONT D''OR', 'FR', '04 72 52 20 00', 'immobilier@ca-centrest.fr', '411000', '30J', 150000.00),
(1, 'C0061', 'CLIENT', 'CAISSE D''EPARGNE RHONE ALPES', '38447780700136', 'FR16384477807', '116 Cours Lafayette', '69003', 'LYON', 'FR', '04 72 60 66 66', 'achats@cera.caisse-epargne.fr', '411000', '30J', 180000.00),
(1, 'C0062', 'CLIENT', 'BNP PARIBAS REAL ESTATE', '43891764900197', 'FR34438917649', '167 Quai de la Bataille de Stalingrad', '92867', 'ISSY-LES-MOULINEAUX', 'FR', '01 55 65 20 00', 'realestate@bnpparibas.com', '411000', '45FM', 200000.00),
-- Hotellerie
(1, 'C0070', 'CLIENT', 'ACCOR HOTELS', '60203644404578', 'FR47602036444', '82 Rue Henri Farman', '92130', 'ISSY-LES-MOULINEAUX', 'FR', '01 45 38 86 00', 'technique@accor.com', '411000', '45FM', 250000.00),
(1, 'C0071', 'CLIENT', 'LOUVRE HOTELS GROUP', '48324809000224', 'FR22483248090', '2 Avenue de Wagram', '75017', 'PARIS', 'FR', '01 42 91 46 00', 'maintenance@louvrehotels.com', '411000', '45FM', 180000.00),
-- Sante
(1, 'C0080', 'CLIENT', 'HOSPICES CIVILS DE LYON', '26690002900073', 'FR42266900029', '3 Quai des Celestins', '69002', 'LYON', 'FR', '04 72 40 30 30', 'marches@chu-lyon.fr', '411000', '30J', 350000.00),
(1, 'C0081', 'CLIENT', 'KORIAN', '44431723500116', 'FR97444317235', '21-25 Rue Balzac', '75008', 'PARIS', 'FR', '01 55 37 52 00', 'technique@korian.fr', '411000', '45FM', 200000.00),
(1, 'C0082', 'CLIENT', 'ORPEA', '40111tried1232', 'FR40401116232', '12 Rue Jean Jaures', '92813', 'PUTEAUX', 'FR', '01 47 75 78 00', 'achats@orpea.net', '411000', '45FM', 220000.00),
-- Education
(1, 'C0090', 'CLIENT', 'UNIVERSITE LYON 1', '19691774400019', 'FR47196917744', '43 Boulevard du 11 Novembre 1918', '69622', 'VILLEURBANNE', 'FR', '04 72 44 80 00', 'marches@univ-lyon1.fr', '411000', '30J', 150000.00),
(1, 'C0091', 'CLIENT', 'INSA LYON', '19690186900013', 'FR32196901869', '20 Avenue Albert Einstein', '69621', 'VILLEURBANNE', 'FR', '04 72 43 83 83', 'marches@insa-lyon.fr', '411000', '30J', 120000.00),
-- PME locales (clients reguliers)
(1, 'C0100', 'CLIENT', 'GARAGE PEUGEOT MARTIN', '32456789012345', NULL, '45 Avenue Jean Jaures', '69100', 'VILLEURBANNE', 'FR', '04 78 XX XX XX', 'garage.martin@orange.fr', '411000', '30J', 25000.00),
(1, 'C0101', 'CLIENT', 'BOULANGERIE DUPONT SARL', '45678901234567', NULL, '12 Place du Marche', '69003', 'LYON', 'FR', '04 78 XX XX XX', 'boulangerie.dupont@gmail.com', '411000', 'CHQ', 5000.00),
(1, 'C0102', 'CLIENT', 'RESTAURANT LE LYONNAIS', '56789012345678', NULL, '8 Rue Merciere', '69002', 'LYON', 'FR', '04 78 XX XX XX', 'restaurant.lyonnais@orange.fr', '411000', '30J', 15000.00),
(1, 'C0103', 'CLIENT', 'CABINET MEDICAL DU PARC', '67890123456789', NULL, '25 Rue du Parc', '69006', 'LYON', 'FR', '04 78 XX XX XX', 'cabinet.parc@gmail.com', '411000', '30J', 20000.00),
(1, 'C0104', 'CLIENT', 'PHARMACIE CENTRALE', '78901234567890', NULL, '1 Place Bellecour', '69002', 'LYON', 'FR', '04 78 XX XX XX', 'pharmacie.centrale@orange.fr', '411000', '30J', 18000.00),
(1, 'C0105', 'CLIENT', 'IMPRIMERIE RHONE ALPES', '89012345678901', NULL, '67 Rue de la Republique', '69001', 'LYON', 'FR', '04 78 XX XX XX', 'imprimerie.ra@wanadoo.fr', '411000', '30J', 30000.00),
(1, 'C0106', 'CLIENT', 'MENUISERIE BERNARD', '90123456789012', NULL, '34 Rue des Artisans', '69100', 'VILLEURBANNE', 'FR', '04 72 XX XX XX', 'menuiserie.bernard@orange.fr', '411000', '30FM', 35000.00),
(1, 'C0107', 'CLIENT', 'PLOMBERIE CHAUFFAGE MARTIN', '01234567890123', NULL, '56 Avenue Felix Faure', '69003', 'LYON', 'FR', '04 78 XX XX XX', 'plomberie.martin@gmail.com', '411000', '30J', 40000.00),
(1, 'C0108', 'CLIENT', 'SOCIETE IMMOBILIERE DU PARC', '12345678901235', NULL, '15 Quai Claude Bernard', '69007', 'LYON', 'FR', '04 78 XX XX XX', 'si.parc@orange.fr', '411000', '45FM', 80000.00),
(1, 'C0109', 'CLIENT', 'COPROPRIETE LES CEDRES', '23456789012346', NULL, '78 Rue de Crequi', '69006', 'LYON', 'FR', '04 78 XX XX XX', 'syndic.cedres@orange.fr', '411000', '30J', 25000.00),
(1, 'C0110', 'CLIENT', 'HOTEL DU RHONE', '34567890123457', NULL, '2 Place Bellecour', '69002', 'LYON', 'FR', '04 78 XX XX XX', 'hotel.rhone@wanadoo.fr', '411000', '30FM', 45000.00);

-- Ajout de clients pour les autres societes (societe_id = 2, 3, 4)
INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 2, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'CLIENT' AND code <= 'C0020';

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 3, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'CLIENT' AND code <= 'C0015';

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 4, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'CLIENT' AND code <= 'C0010';

-- ============================================================================
-- 7. TIERS - FOURNISSEURS (80+ fournisseurs)
-- ============================================================================

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, siret, numero_tva, adresse_ligne1, code_postal, ville, pays_code, telephone, email, compte_collectif, mode_reglement_code) VALUES
-- Fournisseurs materiel electrique
(1, 'F0001', 'FOURNISSEUR', 'REXEL FRANCE', '30997412700124', 'FR50309974127', '13 Boulevard du Fort de Vaux', '75017', 'PARIS', 'FR', '01 42 85 85 00', 'commercial@rexel.fr', '401000', '30FM'),
(1, 'F0002', 'FOURNISSEUR', 'SONEPAR FRANCE', '55080014100186', 'FR76550800141', '153 Avenue Jean Jaures', '93300', 'AUBERVILLIERS', 'FR', '01 48 11 34 00', 'contact@sonepar.fr', '401000', '30FM'),
(1, 'F0003', 'FOURNISSEUR', 'LEGRAND', '75850100100178', 'FR48758501001', '128 Avenue du Marechal de Lattre de Tassigny', '87000', 'LIMOGES', 'FR', '05 55 06 87 87', 'commercial@legrand.fr', '401000', '45FM'),
(1, 'F0004', 'FOURNISSEUR', 'SCHNEIDER ELECTRIC', '54207855401286', 'FR91542078554', '35 Rue Joseph Monier', '92500', 'RUEIL-MALMAISON', 'FR', '01 41 29 70 00', 'commercial@schneider-electric.com', '401000', '45FM'),
(1, 'F0005', 'FOURNISSEUR', 'ABB FRANCE', '62980197800249', 'FR43629801978', '3 Avenue du Canada', '91978', 'COURTABOEUF', 'FR', '01 64 86 30 00', 'contact@fr.abb.com', '401000', '45FM'),
(1, 'F0006', 'FOURNISSEUR', 'SIEMENS FRANCE', '56202442900145', 'FR88562024429', '40 Avenue des Fruitiers', '93527', 'SAINT-DENIS', 'FR', '01 49 22 20 00', 'contact@siemens.fr', '401000', '45FM'),
(1, 'F0007', 'FOURNISSEUR', 'HAGER', '55081003300199', 'FR40550810033', '132 Boulevard d''Europe', '67210', 'OBERNAI', 'FR', '03 88 49 50 50', 'contact@hager.fr', '401000', '30FM'),
(1, 'F0008', 'FOURNISSEUR', 'GENERAL ELECTRIC', '41478789700265', 'FR34414787897', '204 Rond Point du Pont de Sevres', '92100', 'BOULOGNE-BILLANCOURT', 'FR', '01 41 31 50 00', 'contact@ge.com', '401000', '60FM'),
-- Fournisseurs cables
(1, 'F0010', 'FOURNISSEUR', 'NEXANS FRANCE', '42844188900183', 'FR65428441889', '4 Allee de l''Arche', '92400', 'COURBEVOIE', 'FR', '01 73 23 84 00', 'commercial@nexans.com', '401000', '45FM'),
(1, 'F0011', 'FOURNISSEUR', 'PRYSMIAN GROUP', '55210036200129', 'FR76552100362', '8 Rue Lionel Terray', '69330', 'MEYZIEU', 'FR', '04 72 02 16 00', 'contact@prysmiangroup.com', '401000', '45FM'),
(1, 'F0012', 'FOURNISSEUR', 'ACOME', '57207909500021', 'FR92572079095', '52 Rue du Montparnasse', '75014', 'PARIS', 'FR', '02 33 31 51 00', 'commercial@acome.fr', '401000', '30FM'),
-- Fournisseurs eclairage
(1, 'F0020', 'FOURNISSEUR', 'PHILIPS LIGHTING FRANCE', '54206108600148', 'FR05542061086', '33 Rue de Verdun', '92150', 'SURESNES', 'FR', '01 47 28 50 00', 'contact@philips.fr', '401000', '45FM'),
(1, 'F0021', 'FOURNISSEUR', 'OSRAM', '31002890600149', 'FR75310028906', '34 Rue de la Belle Feuille', '92100', 'BOULOGNE-BILLANCOURT', 'FR', '01 41 22 91 91', 'contact@osram.fr', '401000', '45FM'),
(1, 'F0022', 'FOURNISSEUR', 'TRILUX FRANCE', '38019348700025', 'FR89380193487', '6 Rue de la Morache', '21603', 'LONGVIC', 'FR', '03 80 66 83 83', 'contact@trilux.fr', '401000', '45FM'),
-- Fournisseurs CVC / Energie
(1, 'F0030', 'FOURNISSEUR', 'DAIKIN FRANCE', '41983573700142', 'FR59419835737', '4 Rue Henri Sainte Claire Deville', '92563', 'RUEIL-MALMAISON', 'FR', '01 47 51 20 00', 'contact@daikin.fr', '401000', '45FM'),
(1, 'F0031', 'FOURNISSEUR', 'ATLANTIC CLIMATISATION', '40358339900054', 'FR28403583399', 'BP 65', '85002', 'LA ROCHE-SUR-YON', 'FR', '02 51 44 34 00', 'contact@atlantic.fr', '401000', '45FM'),
(1, 'F0032', 'FOURNISSEUR', 'CARRIER FRANCE', '32895538900028', 'FR53328955389', '23 Rue Alexis de Tocqueville', '92160', 'ANTONY', 'FR', '01 46 74 40 00', 'contact@carrier.fr', '401000', '45FM'),
(1, 'F0033', 'FOURNISSEUR', 'VIESSMANN', '69501932800029', 'FR04695019328', '41 Avenue Georges Pompidou', '57157', 'MARLY', 'FR', '03 87 63 35 35', 'contact@viessmann.fr', '401000', '45FM'),
-- Fournisseurs panneaux solaires
(1, 'F0040', 'FOURNISSEUR', 'SUNPOWER FRANCE', '48774519800042', 'FR17487745198', '3 Rue des Arts et Metiers', '94200', 'IVRY-SUR-SEINE', 'FR', '01 53 68 00 00', 'contact@sunpower.fr', '401000', '60FM'),
(1, 'F0041', 'FOURNISSEUR', 'SOLARWORLD', '50949830400015', 'FR85509498304', '15 Rue de la Sabliere', '33310', 'LORMONT', 'FR', '05 56 31 65 00', 'contact@solarworld.fr', '401000', '60FM'),
-- Fournisseurs outillage
(1, 'F0050', 'FOURNISSEUR', 'FACOM', '54203764900043', 'FR85542037649', '6-8 Rue Gustave Eiffel', '91420', 'MORANGIS', 'FR', '01 64 54 45 45', 'contact@facom.fr', '401000', '30FM'),
(1, 'F0051', 'FOURNISSEUR', 'DEWALT FRANCE', '34973621700047', 'FR75349736217', '5 Allee des Hêtres', '69760', 'LIMONEST', 'FR', '04 72 20 39 20', 'contact@dewalt.fr', '401000', '30FM'),
(1, 'F0052', 'FOURNISSEUR', 'MILWAUKEE', '49088765400023', 'FR42490887654', '17 Avenue des Tilleuls', '77185', 'LOGNES', 'FR', '01 64 62 60 00', 'contact@milwaukeetool.fr', '401000', '30FM'),
(1, 'F0053', 'FOURNISSEUR', 'HILTI FRANCE', '31091287200056', 'FR71310912872', '1 Rue Jean Mermoz', '78772', 'MAGNY-LES-HAMEAUX', 'FR', '01 30 69 30 00', 'contact@hilti.fr', '401000', '30FM'),
-- Sous-traitants
(1, 'F0060', 'FOURNISSEUR', 'ELEC SERVICES 69', '45678901234568', NULL, '12 Rue de l''Industrie', '69100', 'VILLEURBANNE', 'FR', '04 78 XX XX XX', 'contact@elecservices69.fr', '401000', '30FM'),
(1, 'F0061', 'FOURNISSEUR', 'RHONE ELECTRICITE', '56789012345679', NULL, '34 Avenue Jean Jaures', '69007', 'LYON', 'FR', '04 78 XX XX XX', 'contact@rhone-elec.fr', '401000', '30FM'),
(1, 'F0062', 'FOURNISSEUR', 'ALPES CABLAGE', '67890123456780', NULL, '8 Zone Industrielle', '38000', 'GRENOBLE', 'FR', '04 76 XX XX XX', 'contact@alpes-cablage.fr', '401000', '30FM'),
-- Location vehicules et materiel
(1, 'F0070', 'FOURNISSEUR', 'LOXAM', '45674561200089', 'FR34456745612', '256 Rue Nicolas Cugnot', '59650', 'VILLENEUVE D''ASCQ', 'FR', '03 20 19 20 21', 'contact@loxam.fr', '401000', '30FM'),
(1, 'F0071', 'FOURNISSEUR', 'KILOUTOU', '98765432100145', 'FR45987654321', '3 Rue Auger', '93500', 'PANTIN', 'FR', '01 41 71 20 00', 'contact@kiloutou.fr', '401000', '30FM'),
(1, 'F0072', 'FOURNISSEUR', 'ADA LOCATION', '34512678900028', 'FR67345126789', '12 Rue de la Mare', '77000', 'MELUN', 'FR', '01 64 37 20 00', 'pro@ada.fr', '401000', 'CHQ'),
-- Services (expert-comptable, banque, etc.)
(1, 'F0080', 'FOURNISSEUR', 'CABINET MAZARS', '78462391400034', 'FR28784623914', '61 Rue Henri Regnault', '92400', 'COURBEVOIE', 'FR', '01 49 97 60 00', 'contact@mazars.fr', '401000', '30J'),
(1, 'F0081', 'FOURNISSEUR', 'KPMG', '77570796300115', 'FR69775707963', '2 Avenue Gambetta', '92066', 'PARIS LA DEFENSE', 'FR', '01 55 68 68 68', 'contact@kpmg.fr', '401000', '30J'),
(1, 'F0082', 'FOURNISSEUR', 'AXA FRANCE', '31045553900012', 'FR48310455539', '313 Terrasses de l''Arche', '92727', 'NANTERRE', 'FR', '01 47 74 10 00', 'entreprises@axa.fr', '401000', 'VIR'),
(1, 'F0083', 'FOURNISSEUR', 'BNP PARIBAS', '66210007700014', 'FR23662100077', '16 Boulevard des Italiens', '75009', 'PARIS', 'FR', '01 40 14 45 46', 'pro@bnpparibas.com', '401000', 'VIR'),
-- Fournitures de bureau
(1, 'F0090', 'FOURNISSEUR', 'OFFICE DEPOT', '39808979400117', 'FR80398089794', '126 Avenue du Poteau', '60300', 'SENLIS', 'FR', '03 44 63 64 65', 'contact@officedepot.fr', '401000', '30J'),
(1, 'F0091', 'FOURNISSEUR', 'STAPLES', '42955178200023', 'FR23429551782', '22 Rue de l''Esperance', '93000', 'BOBIGNY', 'FR', '01 48 95 16 16', 'pro@staples.fr', '401000', '30J'),
-- Informatique
(1, 'F0095', 'FOURNISSEUR', 'LDLC PRO', '40320291800073', 'FR94403202918', '2 Rue des Eries', '69960', 'CORBAS', 'FR', '04 27 46 60 00', 'pro@ldlc.com', '401000', '30J'),
(1, 'F0096', 'FOURNISSEUR', 'INMAC WSTORE', '33258189700036', 'FR43332581897', '11 Rue de l''Egalite', '93260', 'LES LILAS', 'FR', '01 49 72 20 20', 'contact@wstore.fr', '401000', '30J');

-- Copier fournisseurs pour autres societes
INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 2, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'FOURNISSEUR';

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 3, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'FOURNISSEUR';

INSERT INTO tiers.tiers (societe_id, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code)
SELECT 4, code, type_tiers, intitule, adresse_ligne1, code_postal, ville, pays_code, telephone, compte_collectif, mode_reglement_code
FROM tiers.tiers WHERE societe_id = 1 AND type_tiers = 'FOURNISSEUR';

-- ============================================================================
-- 8. BANQUES
-- ============================================================================

INSERT INTO tresor.banque (societe_id, code, intitule, nom_banque, adresse, code_postal, ville, code_banque, code_guichet, numero_compte, cle_rib, bic, iban, compte_comptable, journal_id, decouvert_autorise) VALUES
(1, 'BNP01', 'Compte courant BNP', 'BNP PARIBAS', '2 Place de la Gare', '69001', 'LYON', '30004', '00123', '00012345678', '45', 'BNPAFRPP', 'FR7630004001230001234567845', '512100', 3, 150000.00),
(1, 'CA01', 'Compte Credit Agricole', 'CREDIT AGRICOLE CENTRE-EST', '116 Cours Lafayette', '69003', 'LYON', '30006', '00456', '00098765432', '12', 'AGRIFRPP', 'FR7630006004560009876543212', '512200', 4, 100000.00),
(2, 'BNP01', 'Compte courant BNP', 'BNP PARIBAS', '2 Place de la Gare', '69001', 'LYON', '30004', '00123', '00012345679', '23', 'BNPAFRPP', 'FR7630004001230001234567923', '512100', 11, 80000.00),
(3, 'SG01', 'Compte Societe Generale', 'SOCIETE GENERALE', '15 Rue de la Republique', '69001', 'LYON', '30003', '00789', '00045678901', '78', 'SOGEFRPP', 'FR7630003007890004567890178', '512300', 16, 120000.00),
(4, 'BNP01', 'Compte courant BNP', 'BNP PARIBAS', '2 Place de la Gare', '69001', 'LYON', '30004', '00123', '00012345680', '56', 'BNPAFRPP', 'FR7630004001230001234568056', '512100', 21, 50000.00);

-- ============================================================================
-- 9. ECRITURES COMPTABLES - EXERCICE 2024
-- ============================================================================

-- Pieces et ecritures pour DURETELEC (societe_id = 1)
-- On va generer environ 500 pieces / 2000 ecritures

-- A nouveaux 2025
INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine)
VALUES (1, 3, 8, 'AN250001', '2025-01-01', 'A nouveaux 2025', 'VALIDE', 'IMPORT');

-- Exemple d'ecritures de ventes (factures clients)
DO $$
DECLARE
    v_piece_id INTEGER;
    v_client_id INTEGER;
    v_date DATE;
    v_montant_ht NUMERIC(18,2);
    v_montant_tva NUMERIC(18,2);
    v_montant_ttc NUMERIC(18,2);
    v_num INTEGER := 1;
    v_compte_vente_id INTEGER;
    v_compte_tva_id INTEGER;
    v_compte_client_id INTEGER;
BEGIN
    -- Recuperer les IDs des comptes
    SELECT id INTO v_compte_vente_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '704100' LIMIT 1;
    SELECT id INTO v_compte_tva_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '445710' LIMIT 1;
    SELECT id INTO v_compte_client_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '411000' LIMIT 1;

    -- Generer des factures pour chaque mois
    FOR m IN 1..11 LOOP
        FOR i IN 1..15 LOOP
            v_date := ('2025-' || LPAD(m::TEXT, 2, '0') || '-' || LPAD((1 + (i * 2) % 28)::TEXT, 2, '0'))::DATE;
            v_montant_ht := (5000 + RANDOM() * 95000)::NUMERIC(18,2);
            v_montant_tva := ROUND(v_montant_ht * 0.20, 2);
            v_montant_ttc := v_montant_ht + v_montant_tva;

            -- Selectionner un client aleatoire
            SELECT id INTO v_client_id FROM tiers.tiers
            WHERE societe_id = 1 AND type_tiers = 'CLIENT'
            ORDER BY RANDOM() LIMIT 1;

            -- Creer la piece
            INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine)
            VALUES (1, 3, 2, 'VTE' || LPAD(v_num::TEXT, 6, '0'), v_date, 'Facture client', 'VALIDE', 'FACTURE')
            RETURNING id INTO v_piece_id;

            -- Ligne client (debit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, tiers_id, libelle, reference, debit, credit, date_echeance)
            VALUES (v_piece_id, 1, v_date, v_compte_client_id, '411000', v_client_id, 'Facture travaux', 'FAC' || LPAD(v_num::TEXT, 6, '0'), v_montant_ttc, 0, v_date + INTERVAL '30 days');

            -- Ligne vente (credit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
            VALUES (v_piece_id, 2, v_date, v_compte_vente_id, '704100', 'Facture travaux', 'FAC' || LPAD(v_num::TEXT, 6, '0'), 0, v_montant_ht);

            -- Ligne TVA (credit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit, taux_tva_id, base_tva)
            VALUES (v_piece_id, 3, v_date, v_compte_tva_id, '445710', 'TVA collectee 20%', 'FAC' || LPAD(v_num::TEXT, 6, '0'), 0, v_montant_tva, 1, v_montant_ht);

            v_num := v_num + 1;
        END LOOP;
    END LOOP;
END $$;

-- Generer des ecritures d'achats
DO $$
DECLARE
    v_piece_id INTEGER;
    v_fournisseur_id INTEGER;
    v_date DATE;
    v_montant_ht NUMERIC(18,2);
    v_montant_tva NUMERIC(18,2);
    v_montant_ttc NUMERIC(18,2);
    v_num INTEGER := 1;
    v_compte_achat_id INTEGER;
    v_compte_tva_id INTEGER;
    v_compte_fournisseur_id INTEGER;
BEGIN
    SELECT id INTO v_compte_achat_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '601200' LIMIT 1;
    SELECT id INTO v_compte_tva_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '445660' LIMIT 1;
    SELECT id INTO v_compte_fournisseur_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '401000' LIMIT 1;

    FOR m IN 1..11 LOOP
        FOR i IN 1..20 LOOP
            v_date := ('2025-' || LPAD(m::TEXT, 2, '0') || '-' || LPAD((1 + (i * 1.5)::INT % 28)::TEXT, 2, '0'))::DATE;
            v_montant_ht := (1000 + RANDOM() * 30000)::NUMERIC(18,2);
            v_montant_tva := ROUND(v_montant_ht * 0.20, 2);
            v_montant_ttc := v_montant_ht + v_montant_tva;

            SELECT id INTO v_fournisseur_id FROM tiers.tiers
            WHERE societe_id = 1 AND type_tiers = 'FOURNISSEUR'
            ORDER BY RANDOM() LIMIT 1;

            INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine)
            VALUES (1, 3, 1, 'ACH' || LPAD(v_num::TEXT, 6, '0'), v_date, 'Facture fournisseur', 'VALIDE', 'FACTURE')
            RETURNING id INTO v_piece_id;

            -- Ligne achat (debit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
            VALUES (v_piece_id, 1, v_date, v_compte_achat_id, '601200', 'Achat materiel', 'FF' || LPAD(v_num::TEXT, 6, '0'), v_montant_ht, 0);

            -- Ligne TVA (debit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit, taux_tva_id, base_tva)
            VALUES (v_piece_id, 2, v_date, v_compte_tva_id, '445660', 'TVA deductible 20%', 'FF' || LPAD(v_num::TEXT, 6, '0'), v_montant_tva, 0, 1, v_montant_ht);

            -- Ligne fournisseur (credit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, tiers_id, libelle, reference, debit, credit, date_echeance)
            VALUES (v_piece_id, 3, v_date, v_compte_fournisseur_id, '401000', v_fournisseur_id, 'Achat materiel', 'FF' || LPAD(v_num::TEXT, 6, '0'), 0, v_montant_ttc, v_date + INTERVAL '45 days');

            v_num := v_num + 1;
        END LOOP;
    END LOOP;
END $$;

-- Generer des ecritures de banque (encaissements)
DO $$
DECLARE
    v_piece_id INTEGER;
    v_date DATE;
    v_montant NUMERIC(18,2);
    v_num INTEGER := 1;
    v_compte_banque_id INTEGER;
    v_compte_client_id INTEGER;
    v_client_id INTEGER;
BEGIN
    SELECT id INTO v_compte_banque_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '512100' LIMIT 1;
    SELECT id INTO v_compte_client_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '411000' LIMIT 1;

    FOR m IN 1..11 LOOP
        FOR i IN 1..12 LOOP
            v_date := ('2025-' || LPAD(m::TEXT, 2, '0') || '-' || LPAD(((5 + i * 2) % 28 + 1)::TEXT, 2, '0'))::DATE;
            v_montant := (8000 + RANDOM() * 80000)::NUMERIC(18,2);

            SELECT id INTO v_client_id FROM tiers.tiers
            WHERE societe_id = 1 AND type_tiers = 'CLIENT'
            ORDER BY RANDOM() LIMIT 1;

            INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine)
            VALUES (1, 3, 3, 'BQ1' || LPAD(v_num::TEXT, 6, '0'), v_date, 'Encaissement client', 'VALIDE', 'BANQUE')
            RETURNING id INTO v_piece_id;

            -- Ligne banque (debit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
            VALUES (v_piece_id, 1, v_date, v_compte_banque_id, '512100', 'Encaissement VIR', 'ENC' || LPAD(v_num::TEXT, 6, '0'), v_montant, 0);

            -- Ligne client (credit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, tiers_id, libelle, reference, debit, credit)
            VALUES (v_piece_id, 2, v_date, v_compte_client_id, '411000', v_client_id, 'Encaissement VIR', 'ENC' || LPAD(v_num::TEXT, 6, '0'), 0, v_montant);

            v_num := v_num + 1;
        END LOOP;
    END LOOP;
END $$;

-- Generer des ecritures de banque (decaissements fournisseurs)
DO $$
DECLARE
    v_piece_id INTEGER;
    v_date DATE;
    v_montant NUMERIC(18,2);
    v_num INTEGER := 1000;
    v_compte_banque_id INTEGER;
    v_compte_fournisseur_id INTEGER;
    v_fournisseur_id INTEGER;
BEGIN
    SELECT id INTO v_compte_banque_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '512100' LIMIT 1;
    SELECT id INTO v_compte_fournisseur_id FROM compta.compte_general WHERE societe_id = 1 AND numero = '401000' LIMIT 1;

    FOR m IN 1..11 LOOP
        FOR i IN 1..10 LOOP
            v_date := ('2025-' || LPAD(m::TEXT, 2, '0') || '-' || LPAD(((10 + i * 2) % 28 + 1)::TEXT, 2, '0'))::DATE;
            v_montant := (5000 + RANDOM() * 40000)::NUMERIC(18,2);

            SELECT id INTO v_fournisseur_id FROM tiers.tiers
            WHERE societe_id = 1 AND type_tiers = 'FOURNISSEUR'
            ORDER BY RANDOM() LIMIT 1;

            INSERT INTO compta.piece (societe_id, exercice_id, journal_id, numero_piece, date_piece, libelle, etat, origine)
            VALUES (1, 3, 3, 'BQ1' || LPAD(v_num::TEXT, 6, '0'), v_date, 'Paiement fournisseur', 'VALIDE', 'BANQUE')
            RETURNING id INTO v_piece_id;

            -- Ligne fournisseur (debit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, tiers_id, libelle, reference, debit, credit)
            VALUES (v_piece_id, 1, v_date, v_compte_fournisseur_id, '401000', v_fournisseur_id, 'Paiement VIR', 'VIR' || LPAD(v_num::TEXT, 6, '0'), v_montant, 0);

            -- Ligne banque (credit)
            INSERT INTO compta.ecriture (piece_id, ligne_numero, date_ecriture, compte_id, compte_numero, libelle, reference, debit, credit)
            VALUES (v_piece_id, 2, v_date, v_compte_banque_id, '512100', 'Paiement VIR', 'VIR' || LPAD(v_num::TEXT, 6, '0'), 0, v_montant);

            v_num := v_num + 1;
        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 10. ECHEANCES
-- ============================================================================

-- Generer des echeances clients
INSERT INTO tresor.echeance (societe_id, tiers_id, type_echeance, document_type, document_numero, document_date, date_echeance, montant_origine, etat, mode_reglement_code)
SELECT
    1,
    t.id,
    'CLIENT',
    'FACTURE',
    'FAC' || LPAD((ROW_NUMBER() OVER())::TEXT, 6, '0'),
    ('2025-' || LPAD((1 + (ROW_NUMBER() OVER() % 11))::TEXT, 2, '0') || '-15')::DATE,
    ('2025-' || LPAD((2 + (ROW_NUMBER() OVER() % 11))::TEXT, 2, '0') || '-15')::DATE,
    (10000 + RANDOM() * 90000)::NUMERIC(18,2),
    CASE WHEN RANDOM() < 0.3 THEN 'REGLE' WHEN RANDOM() < 0.5 THEN 'PARTIEL' ELSE 'A_REGLER' END,
    '30FM'
FROM tiers.tiers t, generate_series(1, 5) AS gs
WHERE t.societe_id = 1 AND t.type_tiers = 'CLIENT';

-- Generer des echeances fournisseurs
INSERT INTO tresor.echeance (societe_id, tiers_id, type_echeance, document_type, document_numero, document_date, date_echeance, montant_origine, etat, mode_reglement_code)
SELECT
    1,
    t.id,
    'FOURNISSEUR',
    'FACTURE',
    'FF' || LPAD((ROW_NUMBER() OVER())::TEXT, 6, '0'),
    ('2025-' || LPAD((1 + (ROW_NUMBER() OVER() % 11))::TEXT, 2, '0') || '-10')::DATE,
    ('2025-' || LPAD((2 + (ROW_NUMBER() OVER() % 11))::TEXT, 2, '0') || '-25')::DATE,
    (5000 + RANDOM() * 35000)::NUMERIC(18,2),
    CASE WHEN RANDOM() < 0.4 THEN 'REGLE' ELSE 'A_REGLER' END,
    '45FM'
FROM tiers.tiers t, generate_series(1, 4) AS gs
WHERE t.societe_id = 1 AND t.type_tiers = 'FOURNISSEUR';

-- ============================================================================
-- STATISTIQUES FINALES
-- ============================================================================

-- Afficher les statistiques
DO $$
BEGIN
    RAISE NOTICE '=== STATISTIQUES SEED SAGE COMPTA ===';
    RAISE NOTICE 'Societes: %', (SELECT COUNT(*) FROM ref.societe);
    RAISE NOTICE 'Exercices: %', (SELECT COUNT(*) FROM ref.exercice);
    RAISE NOTICE 'Comptes generaux: %', (SELECT COUNT(*) FROM compta.compte_general);
    RAISE NOTICE 'Journaux: %', (SELECT COUNT(*) FROM compta.journal);
    RAISE NOTICE 'Clients: %', (SELECT COUNT(*) FROM tiers.tiers WHERE type_tiers = 'CLIENT');
    RAISE NOTICE 'Fournisseurs: %', (SELECT COUNT(*) FROM tiers.tiers WHERE type_tiers = 'FOURNISSEUR');
    RAISE NOTICE 'Pieces comptables: %', (SELECT COUNT(*) FROM compta.piece);
    RAISE NOTICE 'Ecritures comptables: %', (SELECT COUNT(*) FROM compta.ecriture);
    RAISE NOTICE 'Echeances: %', (SELECT COUNT(*) FROM tresor.echeance);
    RAISE NOTICE 'Banques: %', (SELECT COUNT(*) FROM tresor.banque);
END $$;

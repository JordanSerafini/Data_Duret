"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CommercialService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let CommercialService = class CommercialService {
    constructor(caPeriodeRepository, caClientRepository, caAffaireRepository, clientRepository, affaireRepository) {
        this.caPeriodeRepository = caPeriodeRepository;
        this.caClientRepository = caClientRepository;
        this.caAffaireRepository = caAffaireRepository;
        this.clientRepository = clientRepository;
        this.affaireRepository = affaireRepository;
    }
    async getCaByPeriode(filter) {
        const queryBuilder = this.caPeriodeRepository
            .createQueryBuilder('ca')
            .select([
            'ca.annee',
            'ca.mois',
            'ca.trimestre',
            'ca.niveau_agregation AS niveau',
            'ca.ca_devis',
            'ca.ca_commande',
            'ca.ca_facture',
            'ca.ca_avoir',
            'ca.ca_net',
            'ca.nb_devis',
            'ca.nb_commandes',
            'ca.nb_factures',
            'ca.nb_clients_actifs',
            'ca.nb_affaires_actives',
            'ca.panier_moyen',
            'ca.taux_transformation',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('ca.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('ca.mois = :mois', { mois: filter.mois });
        }
        if (filter.trimestre) {
            queryBuilder.andWhere('ca.trimestre = :trimestre', { trimestre: filter.trimestre });
        }
        if (filter.niveau) {
            queryBuilder.andWhere('ca.niveau_agregation = :niveau', { niveau: filter.niveau });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('ca.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('ca.annee', 'DESC').addOrderBy('ca.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getCaEvolution(filter) {
        const queryBuilder = this.caPeriodeRepository
            .createQueryBuilder('ca')
            .select([
            'ca.annee AS annee',
            'ca.mois AS mois',
            'SUM(ca.ca_facture) AS ca_facture',
            'SUM(ca.ca_commande) AS ca_commande',
            'SUM(ca.ca_devis) AS ca_devis',
            'SUM(ca.nb_clients_actifs) AS nb_clients',
        ])
            .where('ca.niveau_agregation = :niveau', { niveau: 'MOIS' })
            .groupBy('ca.annee')
            .addGroupBy('ca.mois');
        if (filter.annee) {
            queryBuilder.andWhere('ca.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('ca.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('ca.annee', 'ASC').addOrderBy('ca.mois', 'ASC');
        return queryBuilder.getRawMany();
    }
    async getClients(filter, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.caClientRepository
            .createQueryBuilder('cac')
            .leftJoin(entities_1.DimClient, 'c', 'cac.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS id',
            'c.code',
            'c.raison_sociale',
            'c.ville',
            'c.segment_client',
            'cac.annee',
            'cac.ca_cumule',
            'cac.ca_n_moins_1',
            'cac.variation_ca_pct',
            'cac.taux_marge',
            'cac.encours_actuel',
            'cac.retard_paiement_moyen_jours',
            'cac.nb_impayes',
            'cac.segment_ca',
            'cac.score_fidelite',
            'cac.potentiel_croissance',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('cac.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('cac.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('cac.ca_cumule', 'DESC')
            .offset(skip)
            .limit(limit);
        const data = await queryBuilder.getRawMany();
        return {
            data,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async getClientById(clientId, filter) {
        const client = await this.clientRepository.findOne({
            where: { clientSk: clientId, isCurrent: true },
        });
        const caData = await this.caClientRepository.find({
            where: { clientSk: clientId },
            order: { annee: 'DESC' },
        });
        return {
            client,
            historique_ca: caData,
        };
    }
    async getTopClients(filter, limit = 10) {
        const queryBuilder = this.caClientRepository
            .createQueryBuilder('cac')
            .leftJoin(entities_1.DimClient, 'c', 'cac.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS client_sk',
            'c.code AS code',
            'c.raison_sociale AS raison_sociale',
            'c.ville AS ville',
            'cac.ca_cumule AS ca_cumule',
            'cac.marge_brute AS marge_totale',
            'cac.taux_marge AS taux_marge',
            'cac.nb_factures AS nb_factures',
            'c.segment_client AS segment',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('cac.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('cac.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('cac.ca_cumule', 'DESC').limit(limit);
        return queryBuilder.getRawMany();
    }
    async getAffaires(filter, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.caAffaireRepository
            .createQueryBuilder('caa')
            .leftJoin(entities_1.DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
            .leftJoin(entities_1.DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'a.affaire_sk AS id',
            'a.code',
            'a.libelle',
            'a.etat',
            'a.date_debut_reelle',
            'a.date_fin_prevue',
            'c.raison_sociale AS client',
            'caa.montant_commande',
            'caa.montant_facture',
            'caa.montant_reste_a_facturer',
            'caa.taux_marge_prevu',
            'caa.taux_marge_reel',
            'caa.ecart_marge',
            'caa.heures_budget',
            'caa.heures_realisees',
            'caa.ecart_heures',
            'caa.avancement_facturation_pct',
            'caa.avancement_travaux_pct',
            'caa.niveau_risque',
            'caa.est_en_retard',
            'caa.est_en_depassement_budget',
        ]);
        if (filter.societeId) {
            queryBuilder.andWhere('caa.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('caa.niveau_risque', 'DESC')
            .addOrderBy('caa.montant_commande', 'DESC')
            .offset(skip)
            .limit(limit);
        const data = await queryBuilder.getRawMany();
        return {
            data,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async getAffaireById(affaireId) {
        const affaire = await this.affaireRepository.findOne({
            where: { affaireSk: affaireId, isCurrent: true },
        });
        const caData = await this.caAffaireRepository.findOne({
            where: { affaireSk: affaireId },
        });
        return {
            affaire,
            kpis: caData,
        };
    }
    async getAffairesEnRetard(filter) {
        const queryBuilder = this.caAffaireRepository
            .createQueryBuilder('caa')
            .leftJoin(entities_1.DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
            .leftJoin(entities_1.DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'a.code',
            'a.libelle',
            'c.raison_sociale AS client',
            'a.date_fin_prevue',
            'caa.niveau_risque',
            'caa.est_en_retard',
            'caa.montant_reste_a_facturer',
        ])
            .where('caa.est_en_retard = true');
        if (filter.societeId) {
            queryBuilder.andWhere('caa.societe_sk = :societeId', { societeId: filter.societeId });
        }
        return queryBuilder.getRawMany();
    }
    async getAffairesEnDepassement(filter) {
        const queryBuilder = this.caAffaireRepository
            .createQueryBuilder('caa')
            .leftJoin(entities_1.DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
            .leftJoin(entities_1.DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'a.code',
            'a.libelle',
            'c.raison_sociale AS client',
            'caa.ecart_marge',
            'caa.ecart_heures',
            'caa.niveau_risque',
        ])
            .where('caa.est_en_depassement_budget = true');
        if (filter.societeId) {
            queryBuilder.andWhere('caa.societe_sk = :societeId', { societeId: filter.societeId });
        }
        return queryBuilder.getRawMany();
    }
    async getSegments() {
        const queryBuilder = this.clientRepository
            .createQueryBuilder('c')
            .select('DISTINCT c.segment_client', 'segment')
            .where('c.segment_client IS NOT NULL')
            .andWhere('c.is_current = true')
            .orderBy('c.segment_client', 'ASC');
        const results = await queryBuilder.getRawMany();
        return results.map((r) => r.segment);
    }
    async getSpiCpiAnalysis(filter) {
        const queryBuilder = this.caAffaireRepository
            .createQueryBuilder('caa')
            .leftJoin(entities_1.DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
            .leftJoin(entities_1.DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'a.affaire_sk AS affaire_sk',
            'a.code AS code',
            'a.libelle AS libelle',
            'a.date_debut_reelle AS date_debut',
            'a.date_fin_prevue AS date_fin_prevue',
            'c.raison_sociale AS client',
            'caa.montant_commande AS montant_commande',
            'caa.montant_facture AS montant_facture',
            'caa.cout_total_prevu AS cout_prevu',
            'caa.cout_total_reel AS cout_reel',
            'caa.heures_budget AS heures_budget',
            'caa.heures_realisees AS heures_realisees',
            'caa.avancement_travaux_pct AS avancement_travaux',
            'caa.avancement_facturation_pct AS avancement_facturation',
            'caa.est_en_retard AS est_en_retard',
            'caa.est_en_depassement_budget AS est_en_depassement',
            'caa.niveau_risque AS niveau_risque',
        ])
            .where('caa.montant_commande > 0');
        if (filter.societeId) {
            queryBuilder.andWhere('caa.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const affaires = await queryBuilder.getRawMany();
        const now = new Date();
        const analyses = affaires.map((a) => {
            const montantCommande = parseFloat(a.montant_commande) || 0;
            const montantFacture = parseFloat(a.montant_facture) || 0;
            const coutPrevu = parseFloat(a.cout_prevu) || 0;
            const coutReel = parseFloat(a.cout_reel) || 0;
            const heuresBudget = parseFloat(a.heures_budget) || 0;
            const heuresRealisees = parseFloat(a.heures_realisees) || 0;
            const avancementTravaux = parseFloat(a.avancement_travaux) || 0;
            const avancementFacturation = parseFloat(a.avancement_facturation) || 0;
            const dateDebut = a.date_debut ? new Date(a.date_debut) : null;
            const dateFin = a.date_fin_prevue ? new Date(a.date_fin_prevue) : null;
            let avancementTemporelPrevu = 50;
            if (dateDebut && dateFin && dateFin > dateDebut) {
                const dureeTotale = dateFin.getTime() - dateDebut.getTime();
                const dureeEcoulee = Math.max(0, now.getTime() - dateDebut.getTime());
                avancementTemporelPrevu = Math.min(100, (dureeEcoulee / dureeTotale) * 100);
            }
            const earnedValueSchedule = avancementTravaux;
            const plannedValue = avancementTemporelPrevu;
            const spi = plannedValue > 0 ? earnedValueSchedule / plannedValue : 1;
            const earnedValueCost = montantCommande * (avancementTravaux / 100);
            const actualCost = coutReel > 0 ? coutReel : (heuresRealisees * 50);
            const cpi = actualCost > 0 ? earnedValueCost / actualCost : 1;
            const budgetAtCompletion = coutPrevu > 0 ? coutPrevu : montantCommande * 0.8;
            const eac = cpi > 0 ? budgetAtCompletion / cpi : budgetAtCompletion;
            const varianceAtCompletion = budgetAtCompletion - eac;
            let statusSpi;
            if (spi >= 1.1)
                statusSpi = 'AVANCE';
            else if (spi >= 0.95)
                statusSpi = 'CONFORME';
            else if (spi >= 0.8)
                statusSpi = 'RETARD_LEGER';
            else
                statusSpi = 'RETARD_CRITIQUE';
            let statusCpi;
            if (cpi >= 1.1)
                statusCpi = 'SOUS_BUDGET';
            else if (cpi >= 0.95)
                statusCpi = 'CONFORME';
            else if (cpi >= 0.8)
                statusCpi = 'DEPASSEMENT_LEGER';
            else
                statusCpi = 'DEPASSEMENT_CRITIQUE';
            const scorePerformance = Math.round(Math.min(100, Math.max(0, ((spi + cpi) / 2) * 50)));
            return {
                affaire_sk: a.affaire_sk,
                code: a.code,
                libelle: a.libelle,
                client: a.client,
                spi: Math.round(spi * 100) / 100,
                cpi: Math.round(cpi * 100) / 100,
                status_spi: statusSpi,
                status_cpi: statusCpi,
                score_performance: scorePerformance,
                avancement: {
                    travaux: Math.round(avancementTravaux),
                    facturation: Math.round(avancementFacturation),
                    temporel_prevu: Math.round(avancementTemporelPrevu),
                },
                estimations: {
                    budget_initial: Math.round(budgetAtCompletion),
                    estimation_achèvement: Math.round(eac),
                    variance: Math.round(varianceAtCompletion),
                },
                alertes: {
                    retard: a.est_en_retard,
                    depassement: a.est_en_depassement,
                    niveau_risque: a.niveau_risque,
                },
            };
        });
        analyses.sort((a, b) => a.score_performance - b.score_performance);
        const totalAffaires = analyses.length;
        const spiMoyen = analyses.reduce((acc, a) => acc + a.spi, 0) / (totalAffaires || 1);
        const cpiMoyen = analyses.reduce((acc, a) => acc + a.cpi, 0) / (totalAffaires || 1);
        const enRetardCritique = analyses.filter((a) => a.status_spi === 'RETARD_CRITIQUE').length;
        const enDepassementCritique = analyses.filter((a) => a.status_cpi === 'DEPASSEMENT_CRITIQUE').length;
        let statusGlobal;
        if (spiMoyen >= 0.95 && cpiMoyen >= 0.95)
            statusGlobal = 'PERFORMANT';
        else if (spiMoyen >= 0.85 && cpiMoyen >= 0.85)
            statusGlobal = 'ACCEPTABLE';
        else if (spiMoyen >= 0.75 || cpiMoyen >= 0.75)
            statusGlobal = 'A_SURVEILLER';
        else
            statusGlobal = 'CRITIQUE';
        return {
            status: statusGlobal,
            synthese: {
                nb_affaires: totalAffaires,
                spi_moyen: Math.round(spiMoyen * 100) / 100,
                cpi_moyen: Math.round(cpiMoyen * 100) / 100,
                affaires_retard_critique: enRetardCritique,
                affaires_depassement_critique: enDepassementCritique,
                score_performance_global: Math.round(((spiMoyen + cpiMoyen) / 2) * 50),
            },
            interpretation: {
                spi: spiMoyen >= 1 ? 'Projets globalement dans les temps' :
                    spiMoyen >= 0.9 ? 'Légers retards à surveiller' : 'Retards significatifs',
                cpi: cpiMoyen >= 1 ? 'Projets sous budget global' :
                    cpiMoyen >= 0.9 ? 'Légers dépassements budgétaires' : 'Dépassements significatifs',
            },
            affaires: analyses.slice(0, 20),
        };
    }
    async getClientSatisfactionScore(filter) {
        const queryBuilder = this.caClientRepository
            .createQueryBuilder('cac')
            .leftJoin(entities_1.DimClient, 'c', 'cac.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS client_sk',
            'c.code AS code',
            'c.raison_sociale AS raison_sociale',
            'c.ville AS ville',
            'c.segment_client AS segment',
            'cac.annee AS annee',
            'cac.ca_cumule AS ca_cumule',
            'cac.ca_n_moins_1 AS ca_n_moins_1',
            'cac.variation_ca_pct AS variation_ca',
            'cac.nb_affaires AS nb_affaires',
            'cac.nb_factures AS nb_factures',
            'cac.nb_avoirs AS nb_avoirs',
            'cac.taux_marge AS taux_marge',
            'cac.encours_actuel AS encours',
            'cac.retard_paiement_moyen_jours AS retard_paiement',
            'cac.nb_impayes AS nb_impayes',
            'cac.score_fidelite AS score_fidelite',
            'cac.potentiel_croissance AS potentiel',
        ])
            .where('cac.ca_cumule > 0');
        if (filter.annee) {
            queryBuilder.andWhere('cac.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('cac.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const clients = await queryBuilder.getRawMany();
        const analyses = clients.map((c) => {
            const caCumule = parseFloat(c.ca_cumule) || 0;
            const caNMoins1 = parseFloat(c.ca_n_moins_1) || 0;
            const variationCa = parseFloat(c.variation_ca) || 0;
            const nbAffaires = parseInt(c.nb_affaires) || 0;
            const nbFactures = parseInt(c.nb_factures) || 0;
            const nbAvoirs = parseInt(c.nb_avoirs) || 0;
            const retardPaiement = parseInt(c.retard_paiement) || 0;
            const nbImpayes = parseInt(c.nb_impayes) || 0;
            const scoreFidelite = parseInt(c.score_fidelite) || 50;
            const tauxMarge = parseFloat(c.taux_marge) || 0;
            const scoreFideliteNorm = Math.min(100, scoreFidelite);
            let scorePaiement = 100;
            if (retardPaiement > 90)
                scorePaiement -= 50;
            else if (retardPaiement > 60)
                scorePaiement -= 30;
            else if (retardPaiement > 30)
                scorePaiement -= 15;
            else if (retardPaiement > 15)
                scorePaiement -= 5;
            if (nbImpayes > 5)
                scorePaiement -= 30;
            else if (nbImpayes > 2)
                scorePaiement -= 15;
            else if (nbImpayes > 0)
                scorePaiement -= 5;
            scorePaiement = Math.max(0, scorePaiement);
            let scoreCroissance = 50;
            if (variationCa > 20)
                scoreCroissance = 100;
            else if (variationCa > 10)
                scoreCroissance = 85;
            else if (variationCa > 0)
                scoreCroissance = 70;
            else if (variationCa > -10)
                scoreCroissance = 50;
            else if (variationCa > -20)
                scoreCroissance = 30;
            else
                scoreCroissance = 10;
            let scoreEngagement = 50;
            if (nbAffaires >= 5)
                scoreEngagement = 100;
            else if (nbAffaires >= 3)
                scoreEngagement = 80;
            else if (nbAffaires >= 2)
                scoreEngagement = 60;
            else if (nbAffaires >= 1)
                scoreEngagement = 40;
            else
                scoreEngagement = 20;
            const tauxAvoir = nbFactures > 0 ? (nbAvoirs / nbFactures) * 100 : 0;
            if (tauxAvoir > 20)
                scoreEngagement -= 20;
            else if (tauxAvoir > 10)
                scoreEngagement -= 10;
            const scoreGlobal = Math.round(scoreFideliteNorm * 0.30 +
                scorePaiement * 0.25 +
                scoreCroissance * 0.25 +
                scoreEngagement * 0.20);
            let status;
            if (scoreGlobal >= 80)
                status = 'TRES_SATISFAIT';
            else if (scoreGlobal >= 60)
                status = 'SATISFAIT';
            else if (scoreGlobal >= 40)
                status = 'NEUTRE';
            else if (scoreGlobal >= 20)
                status = 'A_RISQUE';
            else
                status = 'CRITIQUE';
            let risqueChurn;
            if (scoreGlobal >= 70 && variationCa >= 0)
                risqueChurn = 'FAIBLE';
            else if (scoreGlobal >= 50 || variationCa > -10)
                risqueChurn = 'MODERE';
            else
                risqueChurn = 'ELEVE';
            const recommandations = [];
            if (retardPaiement > 30)
                recommandations.push('Relancer les paiements en retard');
            if (variationCa < -10)
                recommandations.push('Action commerciale prioritaire');
            if (nbImpayes > 2)
                recommandations.push('Réviser conditions de paiement');
            if (tauxAvoir > 10)
                recommandations.push('Analyser causes des litiges');
            if (nbAffaires === 0 && caNMoins1 > 0)
                recommandations.push('Client inactif - relancer');
            return {
                client_sk: c.client_sk,
                code: c.code,
                raison_sociale: c.raison_sociale,
                ville: c.ville,
                segment: c.segment,
                score_satisfaction: scoreGlobal,
                status,
                risque_churn: risqueChurn,
                scores_details: {
                    fidelite: Math.round(scoreFideliteNorm),
                    paiement: Math.round(scorePaiement),
                    croissance: Math.round(scoreCroissance),
                    engagement: Math.round(scoreEngagement),
                },
                indicateurs: {
                    ca_cumule: caCumule,
                    variation_ca_pct: variationCa,
                    nb_affaires: nbAffaires,
                    retard_paiement_jours: retardPaiement,
                    nb_impayes: nbImpayes,
                    taux_avoir_pct: Math.round(tauxAvoir * 10) / 10,
                },
                recommandations,
            };
        });
        analyses.sort((a, b) => a.score_satisfaction - b.score_satisfaction);
        const totalClients = analyses.length;
        const scoresMoyen = analyses.reduce((acc, c) => acc + c.score_satisfaction, 0) / (totalClients || 1);
        const tresSatisfaits = analyses.filter((c) => c.status === 'TRES_SATISFAIT').length;
        const satisfaits = analyses.filter((c) => c.status === 'SATISFAIT').length;
        const aRisque = analyses.filter((c) => c.status === 'A_RISQUE' || c.status === 'CRITIQUE').length;
        const risqueChurnEleve = analyses.filter((c) => c.risque_churn === 'ELEVE').length;
        return {
            synthese: {
                nb_clients: totalClients,
                score_moyen: Math.round(scoresMoyen),
                repartition: {
                    tres_satisfaits: tresSatisfaits,
                    satisfaits: satisfaits,
                    neutres: totalClients - tresSatisfaits - satisfaits - aRisque,
                    a_risque: aRisque,
                },
                clients_risque_churn: risqueChurnEleve,
                taux_satisfaction: Math.round(((tresSatisfaits + satisfaits) / totalClients) * 100),
            },
            clients_prioritaires: analyses.slice(0, 10),
            clients_fideles: analyses.slice(-10).reverse(),
        };
    }
    async getEarlyWarningAffaires(filter) {
        const queryBuilder = this.caAffaireRepository
            .createQueryBuilder('caa')
            .leftJoin(entities_1.DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
            .leftJoin(entities_1.DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'a.affaire_sk AS affaire_sk',
            'a.code AS code',
            'a.libelle AS libelle',
            'a.etat AS etat',
            'a.date_debut_reelle AS date_debut',
            'a.date_fin_prevue AS date_fin_prevue',
            'c.raison_sociale AS client',
            'caa.montant_commande AS montant_commande',
            'caa.montant_facture AS montant_facture',
            'caa.montant_reste_a_facturer AS reste_a_facturer',
            'caa.cout_total_prevu AS cout_prevu',
            'caa.cout_total_reel AS cout_reel',
            'caa.marge_prevue AS marge_prevue',
            'caa.marge_reelle AS marge_reelle',
            'caa.taux_marge_prevu AS taux_marge_prevu',
            'caa.taux_marge_reel AS taux_marge_reel',
            'caa.heures_budget AS heures_budget',
            'caa.heures_realisees AS heures_realisees',
            'caa.avancement_travaux_pct AS avancement_travaux',
            'caa.avancement_facturation_pct AS avancement_facturation',
            'caa.est_en_retard AS est_en_retard',
            'caa.est_en_depassement_budget AS est_en_depassement',
            'caa.niveau_risque AS niveau_risque',
        ])
            .where('caa.montant_commande > 0');
        if (filter.societeId) {
            queryBuilder.andWhere('caa.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const affaires = await queryBuilder.getRawMany();
        const now = new Date();
        const alertes = [];
        affaires.forEach((a) => {
            const montantCommande = parseFloat(a.montant_commande) || 0;
            const montantFacture = parseFloat(a.montant_facture) || 0;
            const resteAFacturer = parseFloat(a.reste_a_facturer) || 0;
            const coutPrevu = parseFloat(a.cout_prevu) || montantCommande * 0.8;
            const coutReel = parseFloat(a.cout_reel) || 0;
            const margePrevue = parseFloat(a.marge_prevue) || 0;
            const margeReelle = parseFloat(a.marge_reelle) || 0;
            const tauxMargePrevu = parseFloat(a.taux_marge_prevu) || 0;
            const tauxMargeReel = parseFloat(a.taux_marge_reel) || 0;
            const heuresBudget = parseFloat(a.heures_budget) || 0;
            const heuresRealisees = parseFloat(a.heures_realisees) || 0;
            const avancementTravaux = parseFloat(a.avancement_travaux) || 0;
            const avancementFacturation = parseFloat(a.avancement_facturation) || 0;
            const alertesAffaire = [];
            let scoreRisque = 0;
            const dateDebut = a.date_debut ? new Date(a.date_debut) : null;
            const dateFin = a.date_fin_prevue ? new Date(a.date_fin_prevue) : null;
            if (dateDebut && dateFin && dateFin > dateDebut) {
                const dureeTotale = dateFin.getTime() - dateDebut.getTime();
                const dureeEcoulee = Math.max(0, now.getTime() - dateDebut.getTime());
                const avancementTemporelPrevu = Math.min(100, (dureeEcoulee / dureeTotale) * 100);
                const ecartPlanning = avancementTemporelPrevu - avancementTravaux;
                if (ecartPlanning > 20) {
                    alertesAffaire.push({
                        type: 'RETARD_PLANNING',
                        severite: 'CRITIQUE',
                        message: `Retard planning de ${Math.round(ecartPlanning)}% par rapport au prévisionnel`,
                        valeur: Math.round(ecartPlanning),
                    });
                    scoreRisque += 30;
                }
                else if (ecartPlanning > 10) {
                    alertesAffaire.push({
                        type: 'RETARD_PLANNING',
                        severite: 'ATTENTION',
                        message: `Léger retard planning de ${Math.round(ecartPlanning)}%`,
                        valeur: Math.round(ecartPlanning),
                    });
                    scoreRisque += 15;
                }
                const joursRestants = Math.ceil((dateFin.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
                if (joursRestants <= 7 && avancementTravaux < 90) {
                    alertesAffaire.push({
                        type: 'DEADLINE_PROCHE',
                        severite: 'CRITIQUE',
                        message: `Échéance dans ${joursRestants} jours avec ${Math.round(avancementTravaux)}% d'avancement`,
                        valeur: joursRestants,
                    });
                    scoreRisque += 25;
                }
                else if (joursRestants <= 30 && avancementTravaux < 70) {
                    alertesAffaire.push({
                        type: 'DEADLINE_PROCHE',
                        severite: 'ATTENTION',
                        message: `Échéance dans ${joursRestants} jours avec ${Math.round(avancementTravaux)}% d'avancement`,
                        valeur: joursRestants,
                    });
                    scoreRisque += 10;
                }
            }
            if (coutPrevu > 0 && coutReel > 0) {
                const depassementPct = ((coutReel - coutPrevu) / coutPrevu) * 100;
                if (depassementPct > 20) {
                    alertesAffaire.push({
                        type: 'DEPASSEMENT_BUDGET',
                        severite: 'CRITIQUE',
                        message: `Dépassement budget de ${Math.round(depassementPct)}%`,
                        valeur: Math.round(depassementPct),
                        impact: Math.round(coutReel - coutPrevu),
                    });
                    scoreRisque += 30;
                }
                else if (depassementPct > 10) {
                    alertesAffaire.push({
                        type: 'DEPASSEMENT_BUDGET',
                        severite: 'ATTENTION',
                        message: `Dépassement budget de ${Math.round(depassementPct)}%`,
                        valeur: Math.round(depassementPct),
                        impact: Math.round(coutReel - coutPrevu),
                    });
                    scoreRisque += 15;
                }
            }
            if (heuresBudget > 0) {
                const ratioHeures = (heuresRealisees / heuresBudget) * 100;
                const heuresProjetees = avancementTravaux > 0
                    ? (heuresRealisees / avancementTravaux) * 100
                    : heuresRealisees;
                const depassementHeuresPrevu = ((heuresProjetees - heuresBudget) / heuresBudget) * 100;
                if (depassementHeuresPrevu > 30) {
                    alertesAffaire.push({
                        type: 'DEPASSEMENT_HEURES',
                        severite: 'CRITIQUE',
                        message: `Projection dépassement heures de ${Math.round(depassementHeuresPrevu)}%`,
                        valeur: Math.round(depassementHeuresPrevu),
                    });
                    scoreRisque += 20;
                }
                else if (depassementHeuresPrevu > 15) {
                    alertesAffaire.push({
                        type: 'DEPASSEMENT_HEURES',
                        severite: 'ATTENTION',
                        message: `Projection dépassement heures de ${Math.round(depassementHeuresPrevu)}%`,
                        valeur: Math.round(depassementHeuresPrevu),
                    });
                    scoreRisque += 10;
                }
            }
            if (tauxMargePrevu > 0 && tauxMargeReel !== null) {
                const ecartMarge = tauxMargePrevu - tauxMargeReel;
                if (ecartMarge > 10) {
                    alertesAffaire.push({
                        type: 'EROSION_MARGE',
                        severite: 'CRITIQUE',
                        message: `Érosion marge de ${Math.round(ecartMarge)} points (prévu: ${tauxMargePrevu}%, réel: ${tauxMargeReel}%)`,
                        valeur: Math.round(ecartMarge),
                    });
                    scoreRisque += 25;
                }
                else if (ecartMarge > 5) {
                    alertesAffaire.push({
                        type: 'EROSION_MARGE',
                        severite: 'ATTENTION',
                        message: `Érosion marge de ${Math.round(ecartMarge)} points`,
                        valeur: Math.round(ecartMarge),
                    });
                    scoreRisque += 12;
                }
            }
            const ecartFacturation = avancementTravaux - avancementFacturation;
            if (ecartFacturation > 20 && avancementTravaux > 30) {
                alertesAffaire.push({
                    type: 'RETARD_FACTURATION',
                    severite: 'ATTENTION',
                    message: `Retard facturation: travaux à ${Math.round(avancementTravaux)}% mais facturé à ${Math.round(avancementFacturation)}%`,
                    valeur: Math.round(ecartFacturation),
                    impact: Math.round(resteAFacturer),
                });
                scoreRisque += 10;
            }
            let niveauRisque;
            if (scoreRisque >= 50)
                niveauRisque = 'CRITIQUE';
            else if (scoreRisque >= 30)
                niveauRisque = 'ELEVE';
            else if (scoreRisque >= 15)
                niveauRisque = 'MODERE';
            else
                niveauRisque = 'FAIBLE';
            if (alertesAffaire.length > 0) {
                alertes.push({
                    affaire_sk: a.affaire_sk,
                    code: a.code,
                    libelle: a.libelle,
                    client: a.client,
                    etat: a.etat,
                    montant_commande: montantCommande,
                    score_risque: Math.min(100, scoreRisque),
                    niveau_risque: niveauRisque,
                    nb_alertes: alertesAffaire.length,
                    alertes: alertesAffaire.sort((x, y) => (y.severite === 'CRITIQUE' ? 1 : 0) - (x.severite === 'CRITIQUE' ? 1 : 0)),
                    indicateurs: {
                        avancement_travaux: Math.round(avancementTravaux),
                        avancement_facturation: Math.round(avancementFacturation),
                        taux_marge_prevu: tauxMargePrevu,
                        taux_marge_reel: tauxMargeReel,
                        heures_consommees_pct: heuresBudget > 0 ? Math.round((heuresRealisees / heuresBudget) * 100) : 0,
                    },
                });
            }
        });
        alertes.sort((a, b) => b.score_risque - a.score_risque);
        const totalAffaires = affaires.length;
        const affairesAvecAlertes = alertes.length;
        const critiques = alertes.filter((a) => a.niveau_risque === 'CRITIQUE').length;
        const elevees = alertes.filter((a) => a.niveau_risque === 'ELEVE').length;
        const montantARisque = alertes
            .filter((a) => a.niveau_risque === 'CRITIQUE' || a.niveau_risque === 'ELEVE')
            .reduce((acc, a) => acc + a.montant_commande, 0);
        return {
            synthese: {
                total_affaires: totalAffaires,
                affaires_avec_alertes: affairesAvecAlertes,
                taux_alertes: Math.round((affairesAvecAlertes / totalAffaires) * 100),
                repartition_risque: {
                    critique: critiques,
                    eleve: elevees,
                    modere: alertes.filter((a) => a.niveau_risque === 'MODERE').length,
                },
                montant_a_risque: montantARisque,
            },
            alertes_prioritaires: alertes.slice(0, 15),
            types_alertes: {
                retard_planning: alertes.filter((a) => a.alertes.some((al) => al.type === 'RETARD_PLANNING')).length,
                depassement_budget: alertes.filter((a) => a.alertes.some((al) => al.type === 'DEPASSEMENT_BUDGET')).length,
                erosion_marge: alertes.filter((a) => a.alertes.some((al) => al.type === 'EROSION_MARGE')).length,
                deadline_proche: alertes.filter((a) => a.alertes.some((al) => al.type === 'DEADLINE_PROCHE')).length,
            },
        };
    }
    async getCaForecast(filter) {
        const evolution = await this.caPeriodeRepository
            .createQueryBuilder('ca')
            .select([
            'ca.annee AS annee',
            'ca.mois AS mois',
            'SUM(ca.ca_facture) AS ca_facture',
        ])
            .where('ca.niveau_agregation = :niveau', { niveau: 'MOIS' })
            .groupBy('ca.annee')
            .addGroupBy('ca.mois')
            .orderBy('ca.annee', 'ASC')
            .addOrderBy('ca.mois', 'ASC')
            .getRawMany();
        if (evolution.length < 3) {
            return { historical: evolution, forecast: [], trend: 'INSUFFISANT' };
        }
        const values = evolution.map((e) => parseFloat(e.ca_facture) || 0);
        const n = values.length;
        const xMean = (n - 1) / 2;
        const yMean = values.reduce((a, b) => a + b, 0) / n;
        let numerator = 0;
        let denominator = 0;
        for (let i = 0; i < n; i++) {
            numerator += (i - xMean) * (values[i] - yMean);
            denominator += (i - xMean) * (i - xMean);
        }
        const slope = denominator !== 0 ? numerator / denominator : 0;
        const intercept = yMean - slope * xMean;
        const lastEntry = evolution[evolution.length - 1];
        let currentYear = parseInt(lastEntry.annee);
        let currentMonth = parseInt(lastEntry.mois);
        const forecast = [];
        for (let i = 1; i <= 3; i++) {
            currentMonth++;
            if (currentMonth > 12) {
                currentMonth = 1;
                currentYear++;
            }
            const predictedValue = Math.max(0, intercept + slope * (n - 1 + i));
            const confidenceLow = predictedValue * 0.85;
            const confidenceHigh = predictedValue * 1.15;
            forecast.push({
                annee: currentYear,
                mois: currentMonth,
                ca_prevu: Math.round(predictedValue),
                confidence_low: Math.round(confidenceLow),
                confidence_high: Math.round(confidenceHigh),
            });
        }
        const trend = slope > yMean * 0.02 ? 'HAUSSE' : slope < -yMean * 0.02 ? 'BAISSE' : 'STABLE';
        const lastCA = values[values.length - 1];
        const forecastTotal = forecast.reduce((sum, f) => sum + f.ca_prevu, 0);
        const historicalLast3 = values.slice(-3).reduce((a, b) => a + b, 0);
        const variationPct = historicalLast3 > 0 ? ((forecastTotal - historicalLast3) / historicalLast3) * 100 : 0;
        return {
            historical: evolution.slice(-6),
            forecast,
            trend,
            slope: Math.round(slope),
            variation_pct: Math.round(variationPct * 10) / 10,
            ca_prevu_total: forecastTotal,
        };
    }
};
exports.CommercialService = CommercialService;
exports.CommercialService = CommercialService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.AggCaPeriode)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.AggCaClient)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.AggCaAffaire)),
    __param(3, (0, typeorm_1.InjectRepository)(entities_1.DimClient)),
    __param(4, (0, typeorm_1.InjectRepository)(entities_1.DimAffaire)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], CommercialService);
//# sourceMappingURL=commercial.service.js.map
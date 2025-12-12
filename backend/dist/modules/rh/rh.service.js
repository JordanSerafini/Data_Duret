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
exports.RhService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let RhService = class RhService {
    constructor(heuresRepository, salarieRepository) {
        this.heuresRepository = heuresRepository;
        this.salarieRepository = salarieRepository;
    }
    async getProductivite(filter, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.salarie_sk AS id',
            's.matricule',
            's.nom_complet AS nom',
            's.poste',
            's.qualification',
            'h.annee',
            'h.mois',
            'h.heures_total',
            'h.heures_theoriques',
            'h.taux_occupation',
            'h.heures_productives',
            'h.taux_productivite',
            'h.nb_affaires_travaillees',
            'h.cout_horaire_moyen',
            'h.cout_total',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('h.taux_productivite', 'DESC')
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
    async getHeuresParSalarie(salarieId, filter) {
        const salarie = await this.salarieRepository.findOne({
            where: { salarieSk: salarieId, isCurrent: true },
        });
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .where('h.salarie_sk = :salarieId', { salarieId });
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        queryBuilder.orderBy('h.annee', 'DESC').addOrderBy('h.mois', 'DESC');
        const heures = await queryBuilder.getMany();
        return {
            salarie,
            history: await queryBuilder.getRawMany(),
        };
    }
    async getPostes() {
        const queryBuilder = this.salarieRepository
            .createQueryBuilder('s')
            .select('DISTINCT s.poste', 'poste')
            .where('s.is_current = true')
            .andWhere('s.poste IS NOT NULL')
            .orderBy('s.poste', 'ASC');
        const results = await queryBuilder.getRawMany();
        return results.map((r) => r.poste);
    }
    async getQualifications() {
        const queryBuilder = this.salarieRepository
            .createQueryBuilder('s')
            .select('DISTINCT s.qualification', 'qualification')
            .where('s.is_current = true')
            .andWhere('s.qualification IS NOT NULL')
            .orderBy('s.qualification', 'ASC');
        const results = await queryBuilder.getRawMany();
        return results.map((r) => r.qualification);
    }
    async getSyntheseMensuelle(filter) {
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .select([
            'h.annee',
            'h.mois',
            'COUNT(DISTINCT h.salarie_sk) AS nb_salaries',
            'SUM(h.heures_total) AS heures_totales',
            'SUM(h.heures_productives) AS heures_productives',
            'AVG(h.taux_occupation) AS taux_occupation_moyen',
            'AVG(h.taux_productivite) AS taux_productivite_moyen',
            'SUM(h.cout_total) AS cout_total',
            'AVG(h.cout_horaire_moyen) AS cout_horaire_moyen',
        ])
            .groupBy('h.annee')
            .addGroupBy('h.mois');
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('h.annee', 'DESC').addOrderBy('h.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getTopProductifs(filter, limit = 10) {
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.nom_complet AS nom',
            's.poste',
            'h.taux_productivite',
            'h.nb_affaires_travaillees',
            'h.heures_productives',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('h.taux_productivite', 'DESC').limit(limit);
        return queryBuilder.getRawMany();
    }
    async getSalariesSousOccupes(filter, seuilOccupation = 70) {
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.nom_complet AS nom',
            's.poste',
            'h.taux_occupation',
            'h.heures_total',
            'h.heures_theoriques',
        ])
            .where('h.taux_occupation < :seuil', { seuil: seuilOccupation });
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('h.taux_occupation', 'ASC');
        return queryBuilder.getRawMany();
    }
    async getSalaries(filter) {
        const queryBuilder = this.salarieRepository
            .createQueryBuilder('s')
            .where('s.is_current = true')
            .andWhere('s.est_actif = true');
        if (filter.societeId) {
            queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('s.nom_complet', 'ASC');
        return queryBuilder.getMany();
    }
    async getWorkforceEfficiencyScore(filter) {
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.salarie_sk AS id',
            's.matricule AS matricule',
            's.nom_complet AS nom',
            's.poste AS poste',
            's.qualification AS qualification',
            'SUM(h.heures_total) AS heures_total',
            'SUM(h.heures_theoriques) AS heures_theoriques',
            'SUM(h.heures_productives) AS heures_productives',
            'SUM(h.cout_total) AS cout_total',
            'AVG(h.taux_occupation) AS taux_occupation_moyen',
            'AVG(h.taux_productivite) AS taux_productivite_moyen',
            'AVG(h.cout_horaire_moyen) AS cout_horaire_moyen',
            'SUM(h.nb_affaires_travaillees) AS nb_affaires_total',
            'COUNT(*) AS nb_mois',
            'STDDEV(h.taux_productivite) AS ecart_type_productivite',
        ])
            .groupBy('s.salarie_sk')
            .addGroupBy('s.matricule')
            .addGroupBy('s.nom_complet')
            .addGroupBy('s.poste')
            .addGroupBy('s.qualification');
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const salaries = await queryBuilder.getRawMany();
        if (salaries.length === 0) {
            return {
                score_global: 0,
                status: 'INSUFFISANT',
                synthese: {
                    nb_salaries: 0,
                    heures_totales: 0,
                    heures_productives: 0,
                    cout_total: 0,
                },
                distribution: {},
                salaries: [],
                recommandations: [],
            };
        }
        const salariesAvecScores = salaries.map((s) => {
            const heuresTotales = parseFloat(s.heures_total) || 0;
            const heuresTheoriques = parseFloat(s.heures_theoriques) || 1;
            const heuresProductives = parseFloat(s.heures_productives) || 0;
            const coutTotal = parseFloat(s.cout_total) || 0;
            const tauxOccupation = parseFloat(s.taux_occupation_moyen) || 0;
            const tauxProductivite = parseFloat(s.taux_productivite_moyen) || 0;
            const nbAffaires = parseFloat(s.nb_affaires_total) || 0;
            const nbMois = parseInt(s.nb_mois) || 1;
            const ecartType = parseFloat(s.ecart_type_productivite) || 0;
            const scoreProductivite = Math.min(100, tauxProductivite);
            const scoreOccupation = Math.min(100, tauxOccupation);
            const polyvalenceMoyenne = nbAffaires / nbMois;
            const scorePolyvalence = Math.min(100, polyvalenceMoyenne * 33);
            const coeffVariation = tauxProductivite > 0 ? (ecartType / tauxProductivite) * 100 : 0;
            const scoreRegularite = Math.max(0, 100 - coeffVariation * 2);
            const coutHoraire = parseFloat(s.cout_horaire_moyen) || 0;
            const scoreGlobal = Math.round(scoreProductivite * 0.35 +
                scoreOccupation * 0.25 +
                scorePolyvalence * 0.15 +
                scoreRegularite * 0.25);
            let status;
            if (scoreGlobal >= 80)
                status = 'EXCELLENT';
            else if (scoreGlobal >= 60)
                status = 'BON';
            else if (scoreGlobal >= 40)
                status = 'MOYEN';
            else
                status = 'A_AMELIORER';
            return {
                id: s.id,
                matricule: s.matricule,
                nom: s.nom,
                poste: s.poste,
                qualification: s.qualification,
                heures_totales: Math.round(heuresTotales),
                heures_productives: Math.round(heuresProductives),
                cout_total: Math.round(coutTotal),
                cout_horaire_moyen: Math.round(coutHoraire * 100) / 100,
                nb_affaires: Math.round(nbAffaires),
                scores: {
                    productivite: Math.round(scoreProductivite),
                    occupation: Math.round(scoreOccupation),
                    polyvalence: Math.round(scorePolyvalence),
                    regularite: Math.round(scoreRegularite),
                    global: scoreGlobal,
                },
                status,
                indicateurs: {
                    taux_occupation: Math.round(tauxOccupation * 10) / 10,
                    taux_productivite: Math.round(tauxProductivite * 10) / 10,
                    polyvalence_mensuelle: Math.round(polyvalenceMoyenne * 10) / 10,
                    variation_pct: Math.round(coeffVariation * 10) / 10,
                },
            };
        });
        salariesAvecScores.sort((a, b) => b.scores.global - a.scores.global);
        const scoreGlobalEquipe = Math.round(salariesAvecScores.reduce((sum, s) => sum + s.scores.global, 0) / salariesAvecScores.length);
        const distribution = {
            excellent: salariesAvecScores.filter((s) => s.status === 'EXCELLENT').length,
            bon: salariesAvecScores.filter((s) => s.status === 'BON').length,
            moyen: salariesAvecScores.filter((s) => s.status === 'MOYEN').length,
            a_ameliorer: salariesAvecScores.filter((s) => s.status === 'A_AMELIORER').length,
        };
        const synthese = {
            nb_salaries: salaries.length,
            heures_totales: Math.round(salaries.reduce((sum, s) => sum + parseFloat(s.heures_total || 0), 0)),
            heures_productives: Math.round(salaries.reduce((sum, s) => sum + parseFloat(s.heures_productives || 0), 0)),
            cout_total: Math.round(salaries.reduce((sum, s) => sum + parseFloat(s.cout_total || 0), 0)),
            taux_productivite_moyen: Math.round(salaries.reduce((sum, s) => sum + parseFloat(s.taux_productivite_moyen || 0), 0) / salaries.length * 10) / 10,
            taux_occupation_moyen: Math.round(salaries.reduce((sum, s) => sum + parseFloat(s.taux_occupation_moyen || 0), 0) / salaries.length * 10) / 10,
        };
        const coutParHeureProductive = synthese.heures_productives > 0
            ? synthese.cout_total / synthese.heures_productives
            : 0;
        let statusGlobal;
        if (scoreGlobalEquipe >= 80)
            statusGlobal = 'EXCELLENT';
        else if (scoreGlobalEquipe >= 60)
            statusGlobal = 'BON';
        else if (scoreGlobalEquipe >= 40)
            statusGlobal = 'MOYEN';
        else
            statusGlobal = 'A_AMELIORER';
        const recommandations = [];
        if (distribution.a_ameliorer > salaries.length * 0.2) {
            recommandations.push({
                type: 'FORMATION',
                priorite: 'HAUTE',
                message: `${distribution.a_ameliorer} salariés ont un score d'efficacité faible`,
                impact: 'Plan de formation et accompagnement recommandé',
            });
        }
        if (synthese.taux_occupation_moyen < 75) {
            recommandations.push({
                type: 'PLANIFICATION',
                priorite: 'HAUTE',
                message: `Taux d'occupation moyen faible (${synthese.taux_occupation_moyen}%)`,
                impact: 'Optimiser la planification des ressources pour réduire le temps mort',
            });
        }
        if (synthese.taux_productivite_moyen < 70) {
            recommandations.push({
                type: 'PRODUCTIVITE',
                priorite: 'MOYENNE',
                message: `Taux de productivité moyen à améliorer (${synthese.taux_productivite_moyen}%)`,
                impact: 'Analyser les causes des heures non productives',
            });
        }
        const topPerformers = salariesAvecScores.filter((s) => s.status === 'EXCELLENT');
        if (topPerformers.length > 0 && distribution.a_ameliorer > 0) {
            recommandations.push({
                type: 'MENTORING',
                priorite: 'MOYENNE',
                message: `${topPerformers.length} salariés excellents peuvent mentorer les équipes`,
                impact: 'Programme de mentoring interne pour améliorer les compétences',
            });
        }
        return {
            score_global: scoreGlobalEquipe,
            status: statusGlobal,
            synthese: {
                ...synthese,
                cout_par_heure_productive: Math.round(coutParHeureProductive * 100) / 100,
            },
            distribution,
            salaries: salariesAvecScores,
            top_performers: salariesAvecScores.slice(0, 5),
            a_accompagner: salariesAvecScores.filter((s) => s.status === 'A_AMELIORER'),
            recommandations,
        };
    }
    async getCostAnalysis(filter) {
        const parPosteQuery = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.poste AS poste',
            'COUNT(DISTINCT h.salarie_sk) AS nb_salaries',
            'SUM(h.heures_total) AS heures_totales',
            'SUM(h.heures_productives) AS heures_productives',
            'SUM(h.cout_total) AS cout_total',
            'AVG(h.cout_horaire_moyen) AS cout_horaire_moyen',
            'AVG(h.taux_productivite) AS productivite_moyenne',
        ])
            .where('s.poste IS NOT NULL')
            .groupBy('s.poste');
        if (filter.annee) {
            parPosteQuery.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            parPosteQuery.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const parPoste = await parPosteQuery.getRawMany();
        const parQualifQuery = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.qualification AS qualification',
            'COUNT(DISTINCT h.salarie_sk) AS nb_salaries',
            'SUM(h.heures_total) AS heures_totales',
            'SUM(h.cout_total) AS cout_total',
            'AVG(h.cout_horaire_moyen) AS cout_horaire_moyen',
            'AVG(h.taux_productivite) AS productivite_moyenne',
        ])
            .where('s.qualification IS NOT NULL')
            .groupBy('s.qualification');
        if (filter.annee) {
            parQualifQuery.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            parQualifQuery.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const parQualification = await parQualifQuery.getRawMany();
        const evolutionQuery = this.heuresRepository
            .createQueryBuilder('h')
            .select([
            'h.annee',
            'h.mois',
            'COUNT(DISTINCT h.salarie_sk) AS nb_salaries',
            'SUM(h.heures_total) AS heures_totales',
            'SUM(h.heures_productives) AS heures_productives',
            'SUM(h.cout_total) AS cout_total',
            'AVG(h.taux_productivite) AS productivite_moyenne',
        ])
            .groupBy('h.annee')
            .addGroupBy('h.mois')
            .orderBy('h.annee', 'ASC')
            .addOrderBy('h.mois', 'ASC');
        if (filter.annee) {
            evolutionQuery.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            evolutionQuery.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const evolution = await evolutionQuery.getRawMany();
        const parPosteFormate = parPoste.map((p) => {
            const heuresProductives = parseFloat(p.heures_productives) || 0;
            const coutTotal = parseFloat(p.cout_total) || 0;
            const coutParHeureProductive = heuresProductives > 0 ? coutTotal / heuresProductives : 0;
            return {
                poste: p.poste,
                nb_salaries: parseInt(p.nb_salaries),
                heures_totales: Math.round(parseFloat(p.heures_totales) || 0),
                heures_productives: Math.round(heuresProductives),
                cout_total: Math.round(coutTotal),
                cout_horaire_moyen: Math.round((parseFloat(p.cout_horaire_moyen) || 0) * 100) / 100,
                cout_par_heure_productive: Math.round(coutParHeureProductive * 100) / 100,
                productivite_moyenne: Math.round((parseFloat(p.productivite_moyenne) || 0) * 10) / 10,
                efficience: Math.round(((parseFloat(p.productivite_moyenne) || 0) / coutParHeureProductive) * 10) / 10 || 0,
            };
        });
        const parQualificationFormate = parQualification.map((q) => ({
            qualification: q.qualification,
            nb_salaries: parseInt(q.nb_salaries),
            heures_totales: Math.round(parseFloat(q.heures_totales) || 0),
            cout_total: Math.round(parseFloat(q.cout_total) || 0),
            cout_horaire_moyen: Math.round((parseFloat(q.cout_horaire_moyen) || 0) * 100) / 100,
            productivite_moyenne: Math.round((parseFloat(q.productivite_moyenne) || 0) * 10) / 10,
        }));
        const evolutionFormate = evolution.map((e) => ({
            annee: e.annee,
            mois: e.mois,
            nb_salaries: parseInt(e.nb_salaries),
            heures_totales: Math.round(parseFloat(e.heures_totales) || 0),
            heures_productives: Math.round(parseFloat(e.heures_productives) || 0),
            cout_total: Math.round(parseFloat(e.cout_total) || 0),
            productivite_moyenne: Math.round((parseFloat(e.productivite_moyenne) || 0) * 10) / 10,
        }));
        const coutTotalGlobal = parPoste.reduce((sum, p) => sum + (parseFloat(p.cout_total) || 0), 0);
        const heuresProductivesGlobal = parPoste.reduce((sum, p) => sum + (parseFloat(p.heures_productives) || 0), 0);
        return {
            synthese: {
                cout_total: Math.round(coutTotalGlobal),
                heures_productives: Math.round(heuresProductivesGlobal),
                cout_par_heure_productive: heuresProductivesGlobal > 0
                    ? Math.round((coutTotalGlobal / heuresProductivesGlobal) * 100) / 100
                    : 0,
                nb_postes: parPoste.length,
                nb_qualifications: parQualification.length,
            },
            par_poste: parPosteFormate.sort((a, b) => b.cout_total - a.cout_total),
            par_qualification: parQualificationFormate.sort((a, b) => b.cout_total - a.cout_total),
            evolution: evolutionFormate,
        };
    }
};
exports.RhService = RhService;
exports.RhService = RhService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.AggHeuresSalarie)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.DimSalarie)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], RhService);
//# sourceMappingURL=rh.service.js.map
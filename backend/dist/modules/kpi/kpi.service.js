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
exports.KpiService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let KpiService = class KpiService {
    constructor(kpiRepository, societeRepository) {
        this.kpiRepository = kpiRepository;
        this.societeRepository = societeRepository;
    }
    async getDashboard(filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .leftJoin(entities_1.DimSociete, 's', 'k.societe_sk = s.societe_sk AND s.is_current = true')
            .select([
            's.raison_sociale AS societe',
            'k.annee',
            'k.mois',
            'k.kpi_ca_mensuel AS ca_mensuel',
            'k.kpi_ca_cumul AS ca_cumul',
            'k.kpi_ca_realisation_pct AS ca_realisation_pct',
            'k.kpi_ca_variation_n1_pct AS ca_variation_n1_pct',
            'k.kpi_marge_brute AS marge_brute',
            'k.kpi_taux_marge AS taux_marge',
            'k.kpi_tresorerie_nette AS tresorerie_nette',
            'k.kpi_bfr AS bfr',
            'k.kpi_dso_jours AS dso_jours',
            'k.kpi_carnet_commandes AS carnet_commandes',
            'k.kpi_reste_a_facturer AS reste_a_facturer',
            'k.kpi_nb_affaires_en_cours AS nb_affaires_en_cours',
            'k.kpi_nb_affaires_en_retard AS nb_affaires_en_retard',
            'k.kpi_nb_affaires_en_depassement AS nb_affaires_en_depassement',
            'k.kpi_effectif_moyen AS effectif_moyen',
            'k.kpi_taux_occupation AS taux_occupation',
            'k.calcul_date',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('k.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('k.societe_sk = :societeId', {
                societeId: filter.societeId,
            });
        }
        queryBuilder.orderBy('k.annee', 'DESC').addOrderBy('k.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getKpisBySociete(societeId, filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .where('k.societe_sk = :societeId', { societeId });
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('k.mois = :mois', { mois: filter.mois });
        }
        queryBuilder.orderBy('k.annee', 'DESC').addOrderBy('k.mois', 'DESC');
        return queryBuilder.getMany();
    }
    async getEvolution(filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .select([
            'k.annee',
            'k.mois',
            'SUM(k.kpi_ca_mensuel) AS ca_total',
            'SUM(k.kpi_marge_brute) AS marge_totale',
            'AVG(k.kpi_taux_marge) AS taux_marge_moyen',
            'SUM(k.kpi_tresorerie_nette) AS tresorerie_totale',
            'SUM(k.kpi_nb_affaires_en_cours) AS nb_affaires_total',
        ])
            .groupBy('k.annee')
            .addGroupBy('k.mois');
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('k.societe_sk = :societeId', {
                societeId: filter.societeId,
            });
        }
        queryBuilder.orderBy('k.annee', 'ASC').addOrderBy('k.mois', 'ASC');
        return queryBuilder.getRawMany();
    }
    async getSocietes() {
        return this.societeRepository.find({
            where: { isCurrent: true },
            select: ['societeSk', 'code', 'raisonSociale', 'ville'],
            order: { raisonSociale: 'ASC' },
        });
    }
    async getLatestKpis() {
        const subQuery = this.kpiRepository
            .createQueryBuilder('sub')
            .select('MAX(sub.annee * 100 + sub.mois)', 'max_periode');
        const latestPeriode = await subQuery.getRawOne();
        if (!latestPeriode?.max_periode) {
            return [];
        }
        const annee = Math.floor(latestPeriode.max_periode / 100);
        const mois = latestPeriode.max_periode % 100;
        return this.getDashboard({ annee, mois });
    }
    async getSummary() {
        const latest = await this.getLatestKpis();
        if (!latest.length) {
            return {
                periode: null,
                totaux: null,
                alertes: null,
            };
        }
        const totaux = latest.reduce((acc, kpi) => ({
            ca_total: acc.ca_total + (parseFloat(kpi.ca_mensuel) || 0),
            marge_totale: acc.marge_totale + (parseFloat(kpi.marge_brute) || 0),
            tresorerie_totale: acc.tresorerie_totale + (parseFloat(kpi.tresorerie_nette) || 0),
            carnet_total: acc.carnet_total + (parseFloat(kpi.carnet_commandes) || 0),
            nb_affaires: acc.nb_affaires + (parseInt(kpi.nb_affaires_en_cours) || 0),
            nb_retards: acc.nb_retards + (parseInt(kpi.nb_affaires_en_retard) || 0),
            nb_depassements: acc.nb_depassements + (parseInt(kpi.nb_affaires_en_depassement) || 0),
        }), {
            ca_total: 0,
            marge_totale: 0,
            tresorerie_totale: 0,
            carnet_total: 0,
            nb_affaires: 0,
            nb_retards: 0,
            nb_depassements: 0,
        });
        return {
            periode: {
                annee: latest[0].annee,
                mois: latest[0].mois,
            },
            totaux,
            alertes: {
                affaires_en_retard: totaux.nb_retards,
                affaires_en_depassement: totaux.nb_depassements,
            },
            nb_societes: latest.length,
        };
    }
};
exports.KpiService = KpiService;
exports.KpiService = KpiService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.KpiGlobal)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.DimSociete)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], KpiService);
//# sourceMappingURL=kpi.service.js.map
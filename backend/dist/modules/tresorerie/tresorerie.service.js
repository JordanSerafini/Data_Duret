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
exports.TresorerieService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let TresorerieService = class TresorerieService {
    constructor(tresorerieRepository, balanceAgeeRepository, clientRepository) {
        this.tresorerieRepository = tresorerieRepository;
        this.balanceAgeeRepository = balanceAgeeRepository;
        this.clientRepository = clientRepository;
    }
    async getSolde(filter) {
        const queryBuilder = this.tresorerieRepository
            .createQueryBuilder('t')
            .select([
            't.annee AS annee',
            't.mois AS mois',
            't.jour AS jour',
            't.niveau_agregation AS niveau',
            't.solde_banque AS solde_banque',
            't.solde_caisse AS solde_caisse',
            't.solde_total AS solde_total',
            't.encaissements AS encaissements',
            't.decaissements AS decaissements',
            't.flux_net AS flux_net',
            't.creances_clients AS creances_clients',
            't.creances_echues AS creances_echues',
            't.dettes_fournisseurs AS dettes_fournisseurs',
            't.dettes_echues AS dettes_echues',
            't.bfr_estime AS bfr_estime',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('t.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('t.mois = :mois', { mois: filter.mois });
        }
        if (filter.niveau) {
            queryBuilder.andWhere('t.niveau_agregation = :niveau', { niveau: filter.niveau });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('t.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('t.annee', 'DESC').addOrderBy('t.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getEvolution(filter) {
        const queryBuilder = this.tresorerieRepository
            .createQueryBuilder('t')
            .select([
            't.annee AS annee',
            't.mois AS mois',
            'SUM(t.solde_total) AS solde_total',
            'SUM(t.flux_net) AS flux_net',
            'SUM(t.creances_echues) AS creances_echues',
            'SUM(t.dettes_echues) AS dettes_echues',
            'SUM(t.bfr_estime) AS bfr',
        ])
            .where('t.niveau_agregation = :niveau', { niveau: 'MOIS' })
            .groupBy('t.annee')
            .addGroupBy('t.mois');
        if (filter.annee) {
            queryBuilder.andWhere('t.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('t.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('t.annee', 'ASC').addOrderBy('t.mois', 'ASC');
        return queryBuilder.getRawMany();
    }
    async getBfr(filter) {
        const queryBuilder = this.tresorerieRepository
            .createQueryBuilder('t')
            .select([
            't.annee',
            't.mois',
            'SUM(t.creances_clients) AS creances_clients',
            'SUM(t.dettes_fournisseurs) AS dettes_fournisseurs',
            'SUM(t.bfr_estime) AS bfr',
        ])
            .where('t.niveau_agregation = :niveau', { niveau: 'MOIS' })
            .groupBy('t.annee')
            .addGroupBy('t.mois');
        if (filter.annee) {
            queryBuilder.andWhere('t.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('t.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('t.annee', 'DESC').addOrderBy('t.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getBalanceAgee(filter, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.balanceAgeeRepository
            .createQueryBuilder('ba')
            .leftJoin(entities_1.DimClient, 'c', 'ba.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS id',
            'c.raison_sociale AS client',
            'c.ville',
            'ba.date_calcul',
            'ba.non_echu',
            'ba.echu_0_30j',
            'ba.echu_31_60j',
            'ba.echu_61_90j',
            'ba.echu_plus_90j',
            'ba.total_creances',
            'ba.total_echu',
            'ba.dso_jours',
            'ba.taux_recouvrement',
            'ba.score_risque_credit',
        ]);
        if (filter.societeId) {
            queryBuilder.andWhere('ba.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.andWhere('ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('ba.total_echu', 'DESC')
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
    async getBalanceAgeeSynthese(filter) {
        const queryBuilder = this.balanceAgeeRepository
            .createQueryBuilder('ba')
            .select([
            'SUM(ba.non_echu) AS total_non_echu',
            'SUM(ba.echu_0_30j) AS total_0_30j',
            'SUM(ba.echu_31_60j) AS total_31_60j',
            'SUM(ba.echu_61_90j) AS total_61_90j',
            'SUM(ba.echu_plus_90j) AS total_plus_90j',
            'SUM(ba.total_creances) AS total_creances',
            'SUM(ba.total_echu) AS total_echu',
            'AVG(ba.dso_jours) AS dso_moyen',
            'COUNT(*) AS nb_clients',
        ]);
        if (filter.societeId) {
            queryBuilder.andWhere('ba.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.andWhere('ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)');
        return queryBuilder.getRawOne();
    }
    async getClientsRisqueCredit(filter, seuilRisque = 60) {
        const queryBuilder = this.balanceAgeeRepository
            .createQueryBuilder('ba')
            .leftJoin(entities_1.DimClient, 'c', 'ba.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.raison_sociale AS client',
            'c.ville AS ville',
            'ba.total_echu AS total_echu',
            'ba.score_risque_credit AS score_risque_credit',
            'ba.dso_jours AS dso_jours',
        ])
            .where('ba.score_risque_credit >= :seuil', { seuil: seuilRisque })
            .andWhere('ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)');
        if (filter.societeId) {
            queryBuilder.andWhere('ba.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('ba.score_risque_credit', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getTensionScore(filter) {
        const queryBuilder = this.tresorerieRepository
            .createQueryBuilder('t')
            .select([
            't.solde_total',
            't.flux_net',
            't.encaissements',
            't.decaissements',
            't.creances_echues',
            't.dettes_echues',
            't.bfr_estime',
            't.annee',
            't.mois',
        ])
            .where('t.niveau_agregation = :niveau', { niveau: 'MOIS' });
        if (filter.societeId) {
            queryBuilder.andWhere('t.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('t.annee', 'DESC').addOrderBy('t.mois', 'DESC').limit(6);
        const data = await queryBuilder.getRawMany();
        if (data.length === 0) {
            return {
                score: 50,
                status: 'INSUFFISANT',
                message: 'Données insuffisantes pour calculer le score',
            };
        }
        const latest = data[0];
        const soldeTotal = parseFloat(latest.solde_total) || 0;
        const fluxNet = parseFloat(latest.flux_net) || 0;
        const encaissements = parseFloat(latest.encaissements) || 1;
        const decaissements = Math.abs(parseFloat(latest.decaissements)) || 1;
        const creancesEchues = parseFloat(latest.creances_echues) || 0;
        const dettesEchues = parseFloat(latest.dettes_echues) || 0;
        const ratioLiquidite = (creancesEchues + dettesEchues) > 0
            ? soldeTotal / (creancesEchues + dettesEchues)
            : 10;
        const ratioCouverture = decaissements > 0 ? soldeTotal / decaissements : 10;
        const ratioFlux = decaissements > 0 ? fluxNet / decaissements : 0;
        let tendanceScore = 50;
        if (data.length >= 3) {
            const flux3mois = data.slice(0, 3).map((d) => parseFloat(d.flux_net) || 0);
            const tendance = flux3mois[0] - flux3mois[2];
            if (tendance > 0)
                tendanceScore = 70 + Math.min(30, (tendance / Math.abs(flux3mois[2] || 1)) * 30);
            else
                tendanceScore = 50 - Math.min(50, Math.abs(tendance / (flux3mois[2] || 1)) * 50);
        }
        const scoreLiquidite = Math.min(100, Math.max(0, ratioLiquidite * 10));
        const scoreCouverture = Math.min(100, Math.max(0, ratioCouverture * 10));
        const scoreFlux = Math.min(100, Math.max(0, (ratioFlux + 1) * 50));
        const score = Math.round(scoreLiquidite * 0.30 +
            scoreCouverture * 0.25 +
            scoreFlux * 0.25 +
            tendanceScore * 0.20);
        let status;
        let couleur;
        if (score >= 70) {
            status = 'CONFORTABLE';
            couleur = '#10B981';
        }
        else if (score >= 50) {
            status = 'NORMAL';
            couleur = '#3B82F6';
        }
        else if (score >= 30) {
            status = 'TENDU';
            couleur = '#F59E0B';
        }
        else {
            status = 'CRITIQUE';
            couleur = '#EF4444';
        }
        const alertes = [];
        if (ratioLiquidite < 2)
            alertes.push('Liquidité faible par rapport aux échéances');
        if (ratioCouverture < 2)
            alertes.push('Couverture décaissements < 2 mois');
        if (fluxNet < 0)
            alertes.push('Flux net négatif ce mois');
        if (creancesEchues > soldeTotal * 0.2)
            alertes.push('Créances échues importantes (>20% du solde)');
        return {
            score,
            status,
            couleur,
            alertes,
            details: {
                solde_total: soldeTotal,
                flux_net: fluxNet,
                encaissements,
                decaissements,
                creances_echues: creancesEchues,
                dettes_echues: dettesEchues,
            },
            ratios: {
                liquidite: Math.round(ratioLiquidite * 100) / 100,
                couverture_mois: Math.round(ratioCouverture * 10) / 10,
                flux_decaissements: Math.round(ratioFlux * 100) / 100,
            },
            scores_details: {
                liquidite: Math.round(scoreLiquidite),
                couverture: Math.round(scoreCouverture),
                flux: Math.round(scoreFlux),
                tendance: Math.round(tendanceScore),
            },
            periode: {
                annee: latest.annee,
                mois: latest.mois,
            },
        };
    }
    async getTresorerieForecast(filter) {
        const queryBuilder = this.tresorerieRepository
            .createQueryBuilder('t')
            .select([
            't.annee AS annee',
            't.mois AS mois',
            'SUM(t.solde_total) AS solde_total',
            'SUM(t.flux_net) AS flux_net',
            'SUM(t.encaissements) AS encaissements',
            'SUM(t.decaissements) AS decaissements',
        ])
            .where('t.niveau_agregation = :niveau', { niveau: 'MOIS' })
            .groupBy('t.annee')
            .addGroupBy('t.mois');
        if (filter.societeId) {
            queryBuilder.andWhere('t.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('t.annee', 'ASC').addOrderBy('t.mois', 'ASC');
        const evolution = await queryBuilder.getRawMany();
        if (evolution.length < 3) {
            return { historical: evolution, forecast: [], trend: 'INSUFFISANT' };
        }
        const fluxValues = evolution.map((e) => parseFloat(e.flux_net) || 0);
        const soldeValues = evolution.map((e) => parseFloat(e.solde_total) || 0);
        const n = fluxValues.length;
        const xMean = (n - 1) / 2;
        const yMeanFlux = fluxValues.reduce((a, b) => a + b, 0) / n;
        let numerator = 0;
        let denominator = 0;
        for (let i = 0; i < n; i++) {
            numerator += (i - xMean) * (fluxValues[i] - yMeanFlux);
            denominator += (i - xMean) * (i - xMean);
        }
        const slopeFlux = denominator !== 0 ? numerator / denominator : 0;
        const interceptFlux = yMeanFlux - slopeFlux * xMean;
        const lastEntry = evolution[evolution.length - 1];
        const lastSolde = parseFloat(lastEntry.solde_total) || 0;
        let currentYear = parseInt(lastEntry.annee);
        let currentMonth = parseInt(lastEntry.mois);
        const forecast = [];
        let cumulSolde = lastSolde;
        for (let i = 1; i <= 3; i++) {
            currentMonth++;
            if (currentMonth > 12) {
                currentMonth = 1;
                currentYear++;
            }
            const predictedFlux = interceptFlux + slopeFlux * (n - 1 + i);
            cumulSolde += predictedFlux;
            forecast.push({
                annee: currentYear,
                mois: currentMonth,
                flux_prevu: Math.round(predictedFlux),
                solde_prevu: Math.round(cumulSolde),
                confidence_low: Math.round(cumulSolde * 0.85),
                confidence_high: Math.round(cumulSolde * 1.15),
            });
        }
        const trend = slopeFlux > yMeanFlux * 0.02 ? 'HAUSSE' : slopeFlux < -yMeanFlux * 0.02 ? 'BAISSE' : 'STABLE';
        const forecastLastSolde = forecast[forecast.length - 1].solde_prevu;
        const variationPct = lastSolde > 0 ? ((forecastLastSolde - lastSolde) / lastSolde) * 100 : 0;
        return {
            historical: evolution.slice(-6),
            forecast,
            trend,
            slope_flux: Math.round(slopeFlux),
            variation_pct: Math.round(variationPct * 10) / 10,
            solde_prevu_3m: forecastLastSolde,
        };
    }
};
exports.TresorerieService = TresorerieService;
exports.TresorerieService = TresorerieService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.AggTresorerie)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.AggBalanceAgeeClient)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.DimClient)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], TresorerieService);
//# sourceMappingURL=tresorerie.service.js.map
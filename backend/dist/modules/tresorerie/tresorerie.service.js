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
            't.annee',
            't.mois',
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
            'c.ville',
            'ba.total_echu',
            'ba.score_risque_credit',
            'ba.dso_jours',
        ])
            .where('ba.score_risque_credit >= :seuil', { seuil: seuilRisque })
            .andWhere('ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)');
        if (filter.societeId) {
            queryBuilder.andWhere('ba.societe_sk = :societeId', { societeId: filter.societeId });
        }
        queryBuilder.orderBy('ba.score_risque_credit', 'DESC');
        return queryBuilder.getRawMany();
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
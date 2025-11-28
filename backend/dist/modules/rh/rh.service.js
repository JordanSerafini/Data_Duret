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
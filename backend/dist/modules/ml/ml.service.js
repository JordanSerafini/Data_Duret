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
exports.MlService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let MlService = class MlService {
    constructor(clientFeaturesRepository, affaireFeaturesRepository, clientRepository, affaireRepository) {
        this.clientFeaturesRepository = clientFeaturesRepository;
        this.affaireFeaturesRepository = affaireFeaturesRepository;
        this.clientRepository = clientRepository;
        this.affaireRepository = affaireRepository;
    }
    async getClientSegmentation(pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS id',
            'c.raison_sociale AS client',
            'c.ville',
            'f.segment_valeur',
            'f.segment_comportement',
            'f.segment_risque',
            'f.score_rfm',
            'f.score_potentiel',
            'f.ca_12m',
            'f.tendance_ca',
            'f.nb_commandes_12m',
            'f.panier_moyen',
            'f.anciennete_mois',
        ])
            .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.score_rfm', 'DESC')
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
    async getClientChurnRisk(seuilRisque = 0.3, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS id',
            'c.raison_sociale AS client',
            'c.ville',
            'f.probabilite_churn',
            'f.segment_risque',
            'f.recence_derniere_commande_jours',
            'f.tendance_ca',
            'f.ca_12m',
            'f.nb_commandes_12m',
            'f.delai_paiement_moyen_jours',
        ])
            .where('f.probabilite_churn >= :seuil', { seuil: seuilRisque })
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.probabilite_churn', 'DESC')
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
    async getClientsFortPotentiel(seuilPotentiel = 70, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS id',
            'c.raison_sociale AS client',
            'c.ville',
            'f.score_potentiel',
            'f.segment_valeur',
            'f.ca_12m',
            'f.tendance_ca',
            'f.panier_moyen',
        ])
            .where('f.score_potentiel >= :seuil', { seuil: seuilPotentiel })
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.score_potentiel', 'DESC')
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
    async getClientFeatures(clientId) {
        const client = await this.clientRepository.findOne({
            where: { clientSk: clientId, isCurrent: true },
        });
        const features = await this.clientFeaturesRepository.findOne({
            where: { clientSk: clientId },
            order: { dateExtraction: 'DESC' },
        });
        return {
            client,
            features,
        };
    }
    async getSegmentationSynthese() {
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .select([
            'f.segment_valeur',
            'COUNT(*) AS nb_clients',
            'SUM(f.ca_12m) AS ca_total',
            'AVG(f.score_rfm) AS score_rfm_moyen',
            'AVG(f.probabilite_churn) AS churn_moyen',
        ])
            .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)')
            .groupBy('f.segment_valeur');
        return queryBuilder.getRawMany();
    }
    async getClientsParSegment(segment, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.raison_sociale AS client',
            'c.ville',
            'f.score_rfm',
            'f.ca_12m',
            'f.probabilite_churn',
        ])
            .where('f.segment_valeur = :segment', { segment })
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.ca_12m', 'DESC')
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
    async getAffairePredictions(pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.affaireFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimAffaire, 'a', 'f.affaire_sk = a.affaire_sk AND a.is_current = true')
            .select([
            'a.affaire_sk AS id',
            'a.code',
            'a.libelle',
            'f.type_affaire',
            'f.montant_commande',
            'f.duree_prevue_jours',
            'f.marge_reelle_pct',
            'f.marge_predite_pct',
            'f.risque_depassement_score',
            'f.ecart_budget_heures_pct',
            'f.retard_jours',
        ])
            .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.risque_depassement_score', 'DESC')
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
    async getAffaireFeatures(affaireId) {
        const affaire = await this.affaireRepository.findOne({
            where: { affaireSk: affaireId, isCurrent: true },
        });
        const features = await this.affaireFeaturesRepository.findOne({
            where: { affaireSk: affaireId },
            order: { dateExtraction: 'DESC' },
        });
        return {
            affaire,
            features,
        };
    }
    async getAffairesRisqueDepassement(seuilRisque = 50, pagination) {
        const { page = 1, limit = 20 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.affaireFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimAffaire, 'a', 'f.affaire_sk = a.affaire_sk AND a.is_current = true')
            .select([
            'a.code',
            'a.libelle',
            'f.risque_depassement_score',
            'f.montant_commande',
            'f.marge_predite_pct',
            'f.heures_budget',
            'f.ratio_mo_montant',
        ])
            .where('f.risque_depassement_score >= :seuil', { seuil: seuilRisque })
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.risque_depassement_score', 'DESC')
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
    async getStatistiquesML() {
        const [clientStats, affaireStats] = await Promise.all([
            this.clientFeaturesRepository
                .createQueryBuilder('f')
                .select([
                'COUNT(*) AS nb_clients',
                'AVG(f.probabilite_churn) AS churn_moyen',
                'COUNT(CASE WHEN f.probabilite_churn > 0.5 THEN 1 END) AS nb_risque_churn',
                'AVG(f.score_rfm) AS score_rfm_moyen',
            ])
                .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)')
                .getRawOne(),
            this.affaireFeaturesRepository
                .createQueryBuilder('f')
                .select([
                'COUNT(*) AS nb_affaires',
                'AVG(f.risque_depassement_score) AS risque_moyen',
                'COUNT(CASE WHEN f.risque_depassement_score > 50 THEN 1 END) AS nb_risque_depassement',
                'AVG(f.marge_predite_pct) AS marge_moyenne_predite',
            ])
                .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)')
                .getRawOne(),
        ]);
        return {
            clients: clientStats,
            affaires: affaireStats,
        };
    }
    async getClientsWithHealthScore(pagination) {
        const { page = 1, limit = 50 } = pagination;
        const skip = (page - 1) * limit;
        const queryBuilder = this.clientFeaturesRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.client_sk AS client_sk',
            'c.raison_sociale AS raison_sociale',
            'c.ville AS ville',
            'f.ca_12m AS ca_12m',
            'f.tendance_ca AS tendance_ca',
            'f.probabilite_churn AS probabilite_churn',
            'f.score_rfm AS score_rfm',
            'f.score_potentiel AS score_potentiel',
            'f.segment_valeur AS segment_valeur',
            'f.segment_comportement AS segment_comportement',
            'f.nb_commandes_12m AS nb_commandes_12m',
            'f.recence_derniere_commande_jours AS recence_jours',
            'f.delai_paiement_moyen_jours AS delai_paiement',
            `CASE
          WHEN f.probabilite_churn < 0.15 AND f.tendance_ca IN ('HAUSSE', 'STABLE') AND f.score_rfm >= 70 THEN 'EXCELLENT'
          WHEN f.probabilite_churn < 0.30 AND f.score_rfm >= 50 THEN 'BON'
          WHEN f.probabilite_churn < 0.50 THEN 'ATTENTION'
          ELSE 'CRITIQUE'
        END AS health_status`,
            `ROUND(((100 - COALESCE(f.probabilite_churn, 0) * 100) * 0.4 + COALESCE(f.score_rfm, 50) * 0.4 +
          CASE WHEN f.tendance_ca = 'HAUSSE' THEN 20 WHEN f.tendance_ca = 'STABLE' THEN 10 ELSE 0 END) * 0.2)::numeric AS health_score`,
        ])
            .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        const total = await queryBuilder.getCount();
        queryBuilder
            .orderBy('f.ca_12m', 'DESC', 'NULLS LAST')
            .offset(skip)
            .limit(limit);
        const data = await queryBuilder.getRawMany();
        return {
            data,
            meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
        };
    }
    async getHealthScoreSummary() {
        const result = await this.clientFeaturesRepository
            .createQueryBuilder('f')
            .select([
            `COUNT(CASE WHEN f.probabilite_churn < 0.15 AND f.tendance_ca IN ('HAUSSE', 'STABLE') AND f.score_rfm >= 70 THEN 1 END) AS excellent`,
            `COUNT(CASE WHEN f.probabilite_churn >= 0.15 AND f.probabilite_churn < 0.30 AND f.score_rfm >= 50 THEN 1 END) AS bon`,
            `COUNT(CASE WHEN f.probabilite_churn >= 0.30 AND f.probabilite_churn < 0.50 THEN 1 END) AS attention`,
            `COUNT(CASE WHEN f.probabilite_churn >= 0.50 THEN 1 END) AS critique`,
            'COUNT(*) AS total',
        ])
            .where('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)')
            .getRawOne();
        return result;
    }
};
exports.MlService = MlService;
exports.MlService = MlService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.MlFeaturesClient)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.MlFeaturesAffaire)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.DimClient)),
    __param(3, (0, typeorm_1.InjectRepository)(entities_1.DimAffaire)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], MlService);
//# sourceMappingURL=ml.service.js.map
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
exports.AnomaliesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let AnomaliesService = class AnomaliesService {
    constructor(affaireRepository, clientRepository, balanceRepository, stockRepository, dimAffaireRepository, dimClientRepository, heuresRepository, salarieRepository, mlClientRepository, mlAffaireRepository) {
        this.affaireRepository = affaireRepository;
        this.clientRepository = clientRepository;
        this.balanceRepository = balanceRepository;
        this.stockRepository = stockRepository;
        this.dimAffaireRepository = dimAffaireRepository;
        this.dimClientRepository = dimClientRepository;
        this.heuresRepository = heuresRepository;
        this.salarieRepository = salarieRepository;
        this.mlClientRepository = mlClientRepository;
        this.mlAffaireRepository = mlAffaireRepository;
    }
    async getAllAnomalies(filter) {
        const [ecartsBudget, retards, impayes, risqueCredit, alertesStock, churnAlerts, affaireRiskAlerts, sousOccupationAlerts,] = await Promise.all([
            this.getEcartsBudget(filter),
            this.getAffairesRetard(filter),
            this.getImpayes(filter),
            this.getRisqueCredit(filter),
            this.getAlertesStock(filter),
            this.getChurnAlerts(filter),
            this.getAffaireRiskAlerts(filter),
            this.getSousOccupationAlerts(filter),
        ]);
        return [
            ...ecartsBudget,
            ...retards,
            ...impayes,
            ...risqueCredit,
            ...alertesStock,
            ...churnAlerts,
            ...affaireRiskAlerts,
            ...sousOccupationAlerts,
        ].sort((a, b) => {
            const severiteOrder = { CRITIQUE: 0, HAUTE: 1, MOYENNE: 2, BASSE: 3 };
            return severiteOrder[a.severite] - severiteOrder[b.severite];
        });
    }
    async getChurnAlerts(filter) {
        const queryBuilder = this.mlClientRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
            .select([
            'c.raison_sociale AS client',
            'c.code AS code',
            'f.probabilite_churn',
            'f.segment_risque',
        ])
            .where('f.probabilite_churn > 0.5')
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_client)');
        if (filter.societeId) {
            queryBuilder.andWhere('c.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'RISQUE_CHURN',
            severite: parseFloat(r.probabilite_churn) > 0.8 ? 'CRITIQUE' : 'HAUTE',
            categorie: 'Clients',
            description: `Risque de churn élevé (${(parseFloat(r.probabilite_churn) * 100).toFixed(0)}%) pour ${r.client}`,
            valeur: parseFloat(r.probabilite_churn),
            seuil: 0.5,
            entite: r.code,
            details: {
                client: r.client,
                segment_risque: r.segment_risque,
            },
        }));
    }
    async getAffaireRiskAlerts(filter) {
        const queryBuilder = this.mlAffaireRepository
            .createQueryBuilder('f')
            .leftJoin(entities_1.DimAffaire, 'a', 'f.affaire_sk = a.affaire_sk AND a.is_current = true')
            .select([
            'a.code',
            'a.libelle',
            'f.risque_depassement_score',
            'f.marge_predite_pct',
        ])
            .where('f.risque_depassement_score > 50')
            .andWhere('f.date_extraction = (SELECT MAX(date_extraction) FROM gold.ml_features_affaire)');
        if (filter.societeId) {
            queryBuilder.andWhere('a.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'RISQUE_AFFAIRE',
            severite: parseFloat(r.risque_depassement_score) > 80 ? 'CRITIQUE' : 'HAUTE',
            categorie: 'Affaires',
            description: `Risque de dépassement élevé (Score: ${r.risque_depassement_score}) pour ${r.code}`,
            valeur: parseFloat(r.risque_depassement_score),
            seuil: 50,
            entite: r.code,
            details: {
                libelle: r.libelle,
                marge_predite: parseFloat(r.marge_predite_pct),
            },
        }));
    }
    async getSousOccupationAlerts(filter) {
        const queryBuilder = this.heuresRepository
            .createQueryBuilder('h')
            .leftJoin(entities_1.DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
            .select([
            's.nom_complet AS nom',
            's.matricule',
            'h.taux_occupation',
            'h.heures_total',
        ])
            .where('h.taux_occupation < 70')
            .andWhere('h.taux_occupation > 0');
        if (filter.annee) {
            queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'SOUS_OCCUPATION',
            severite: parseFloat(r.taux_occupation) < 50 ? 'HAUTE' : 'MOYENNE',
            categorie: 'RH',
            description: `Sous-occupation (${parseFloat(r.taux_occupation).toFixed(0)}%) pour ${r.nom}`,
            valeur: parseFloat(r.taux_occupation),
            seuil: 70,
            entite: r.matricule,
            details: {
                nom: r.nom,
                heures_total: parseFloat(r.heures_total),
            },
        }));
    }
    async getEcartsBudget(filter) {
        const queryBuilder = this.affaireRepository
            .createQueryBuilder('a')
            .leftJoin(entities_1.DimAffaire, 'd', 'a.affaire_sk = d.affaire_sk AND d.is_current = true')
            .select([
            'd.code AS code',
            'd.libelle AS libelle',
            'a.ecart_marge AS ecart_marge',
            'a.ecart_heures AS ecart_heures',
            'a.taux_marge_prevu AS marge_prevue',
            'a.taux_marge_reel AS marge_reelle',
            'a.niveau_risque AS risque',
        ])
            .where('a.est_en_depassement_budget = true');
        if (filter.societeId) {
            queryBuilder.andWhere('a.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'ECART_BUDGET',
            severite: this.getSeveriteFromRisque(r.risque),
            categorie: 'Affaires',
            description: `Affaire ${r.code} en dépassement de budget`,
            valeur: parseFloat(r.ecart_marge) || 0,
            entite: r.code,
            details: {
                libelle: r.libelle,
                ecart_heures: parseFloat(r.ecart_heures),
                marge_prevue: parseFloat(r.marge_prevue),
                marge_reelle: parseFloat(r.marge_reelle),
            },
        }));
    }
    async getAffairesRetard(filter) {
        const queryBuilder = this.affaireRepository
            .createQueryBuilder('a')
            .leftJoin(entities_1.DimAffaire, 'd', 'a.affaire_sk = d.affaire_sk AND d.is_current = true')
            .select([
            'd.code AS code',
            'd.libelle AS libelle',
            'd.date_fin_prevue AS date_fin_prevue',
            'a.montant_reste_a_facturer AS reste_facturer',
            'a.niveau_risque AS risque',
        ])
            .where('a.est_en_retard = true');
        if (filter.societeId) {
            queryBuilder.andWhere('a.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'AFFAIRE_RETARD',
            severite: this.getSeveriteFromRisque(r.risque),
            categorie: 'Affaires',
            description: `Affaire ${r.code} en retard`,
            entite: r.code,
            details: {
                libelle: r.libelle,
                date_fin_prevue: r.date_fin_prevue,
                reste_facturer: parseFloat(r.reste_facturer),
            },
        }));
    }
    async getImpayes(filter) {
        const queryBuilder = this.clientRepository
            .createQueryBuilder('c')
            .leftJoin(entities_1.DimClient, 'd', 'c.client_sk = d.client_sk AND d.is_current = true')
            .select([
            'd.raison_sociale AS client',
            'd.code AS code',
            'c.nb_impayes AS nb_impayes',
            'c.encours_actuel AS encours',
            'c.retard_paiement_moyen_jours AS retard_moyen',
        ])
            .where('c.nb_impayes > 0');
        if (filter.annee) {
            queryBuilder.andWhere('c.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('c.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'IMPAYE',
            severite: this.getSeveriteImpayes(r.nb_impayes, r.encours),
            categorie: 'Clients',
            description: `${r.nb_impayes} impayé(s) pour ${r.client}`,
            valeur: parseFloat(r.encours) || 0,
            entite: r.code,
            details: {
                client: r.client,
                nb_impayes: r.nb_impayes,
                retard_moyen_jours: r.retard_moyen,
            },
        }));
    }
    async getRisqueCredit(filter) {
        const queryBuilder = this.balanceRepository
            .createQueryBuilder('b')
            .leftJoin(entities_1.DimClient, 'd', 'b.client_sk = d.client_sk AND d.is_current = true')
            .select([
            'd.raison_sociale AS client',
            'd.code AS code',
            'b.score_risque_credit AS score',
            'b.total_echu AS total_echu',
            'b.dso_jours AS dso',
        ])
            .where('b.score_risque_credit >= 60')
            .andWhere('b.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)');
        if (filter.societeId) {
            queryBuilder.andWhere('b.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: 'RISQUE_CREDIT',
            severite: this.getSeveriteRisqueCredit(r.score),
            categorie: 'Clients',
            description: `Risque crédit élevé pour ${r.client}`,
            valeur: r.score,
            seuil: 60,
            entite: r.code,
            details: {
                client: r.client,
                total_echu: parseFloat(r.total_echu),
                dso_jours: r.dso,
            },
        }));
    }
    async getAlertesStock(filter) {
        const queryBuilder = this.stockRepository
            .createQueryBuilder('s')
            .select([
            's.depot_code AS depot',
            's.est_sous_stock_mini AS rupture',
            's.est_surstock AS surstock',
            's.stock_final AS stock',
            's.stock_minimum AS stock_min',
            's.couverture_jours AS couverture',
        ])
            .where('(s.est_sous_stock_mini = true OR s.est_surstock = true)')
            .andWhere('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');
        if (filter.societeId) {
            queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const results = await queryBuilder.getRawMany();
        return results.map((r) => ({
            type: r.rupture ? 'RUPTURE_STOCK' : 'SURSTOCK',
            severite: r.rupture ? 'HAUTE' : 'MOYENNE',
            categorie: 'Stock',
            description: r.rupture
                ? `Rupture imminente - ${r.couverture || 0} jours de couverture`
                : `Surstock détecté au dépôt ${r.depot}`,
            valeur: parseFloat(r.stock) || 0,
            seuil: parseFloat(r.stock_min) || 0,
            details: {
                depot: r.depot,
                couverture_jours: r.couverture,
            },
        }));
    }
    async getSynthese(filter) {
        const anomalies = await this.getAllAnomalies(filter);
        const synthese = {
            total: anomalies.length,
            par_severite: {
                critique: anomalies.filter((a) => a.severite === 'CRITIQUE').length,
                haute: anomalies.filter((a) => a.severite === 'HAUTE').length,
                moyenne: anomalies.filter((a) => a.severite === 'MOYENNE').length,
                basse: anomalies.filter((a) => a.severite === 'BASSE').length,
            },
            par_categorie: {
                affaires: anomalies.filter((a) => a.categorie === 'Affaires').length,
                clients: anomalies.filter((a) => a.categorie === 'Clients').length,
                stock: anomalies.filter((a) => a.categorie === 'Stock').length,
            },
            par_type: {},
        };
        anomalies.forEach((a) => {
            synthese.par_type[a.type] = (synthese.par_type[a.type] || 0) + 1;
        });
        return synthese;
    }
    getSeveriteFromRisque(risque) {
        switch (risque) {
            case 'CRITIQUE':
                return 'CRITIQUE';
            case 'ELEVE':
                return 'HAUTE';
            case 'MOYEN':
                return 'MOYENNE';
            default:
                return 'BASSE';
        }
    }
    getSeveriteImpayes(nbImpayes, encours) {
        if (nbImpayes >= 5 || encours > 50000)
            return 'CRITIQUE';
        if (nbImpayes >= 3 || encours > 20000)
            return 'HAUTE';
        if (nbImpayes >= 2 || encours > 10000)
            return 'MOYENNE';
        return 'BASSE';
    }
    getSeveriteRisqueCredit(score) {
        if (score >= 80)
            return 'CRITIQUE';
        if (score >= 70)
            return 'HAUTE';
        if (score >= 60)
            return 'MOYENNE';
        return 'BASSE';
    }
};
exports.AnomaliesService = AnomaliesService;
exports.AnomaliesService = AnomaliesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.AggCaAffaire)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.AggCaClient)),
    __param(2, (0, typeorm_1.InjectRepository)(entities_1.AggBalanceAgeeClient)),
    __param(3, (0, typeorm_1.InjectRepository)(entities_1.AggStockElement)),
    __param(4, (0, typeorm_1.InjectRepository)(entities_1.DimAffaire)),
    __param(5, (0, typeorm_1.InjectRepository)(entities_1.DimClient)),
    __param(6, (0, typeorm_1.InjectRepository)(entities_1.AggHeuresSalarie)),
    __param(7, (0, typeorm_1.InjectRepository)(entities_1.DimSalarie)),
    __param(8, (0, typeorm_1.InjectRepository)(entities_1.MlFeaturesClient)),
    __param(9, (0, typeorm_1.InjectRepository)(entities_1.MlFeaturesAffaire)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], AnomaliesService);
//# sourceMappingURL=anomalies.service.js.map
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
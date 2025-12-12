import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MlFeaturesClient, MlFeaturesAffaire, DimClient, DimAffaire } from '../../database/entities';
import { PaginationDto } from '../../common/dto';

@Injectable()
export class MlService {
  constructor(
    @InjectRepository(MlFeaturesClient)
    private clientFeaturesRepository: Repository<MlFeaturesClient>,
    @InjectRepository(MlFeaturesAffaire)
    private affaireFeaturesRepository: Repository<MlFeaturesAffaire>,
    @InjectRepository(DimClient)
    private clientRepository: Repository<DimClient>,
    @InjectRepository(DimAffaire)
    private affaireRepository: Repository<DimAffaire>,
  ) {}

  // ==================== CLIENTS ====================

  async getClientSegmentation(pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clientFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
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

  async getClientChurnRisk(seuilRisque = 0.3, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clientFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
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

  async getClientsFortPotentiel(seuilPotentiel = 70, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clientFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
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

  async getClientFeatures(clientId: number) {
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

  async getClientsParSegment(segment: string, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clientFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
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

  // ==================== AFFAIRES ====================

  async getAffairePredictions(pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.affaireFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimAffaire, 'a', 'f.affaire_sk = a.affaire_sk AND a.is_current = true')
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

  async getAffaireFeatures(affaireId: number) {
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

  async getAffairesRisqueDepassement(seuilRisque = 50, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.affaireFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimAffaire, 'a', 'f.affaire_sk = a.affaire_sk AND a.is_current = true')
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

  // ==================== SCORE SANTÉ CLIENT ====================

  async getClientsWithHealthScore(pagination: PaginationDto) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.clientFeaturesRepository
      .createQueryBuilder('f')
      .leftJoin(DimClient, 'c', 'f.client_sk = c.client_sk AND c.is_current = true')
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
}

import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AggTresorerie, AggBalanceAgeeClient, DimClient } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@Injectable()
export class TresorerieService {
  constructor(
    @InjectRepository(AggTresorerie)
    private tresorerieRepository: Repository<AggTresorerie>,
    @InjectRepository(AggBalanceAgeeClient)
    private balanceAgeeRepository: Repository<AggBalanceAgeeClient>,
    @InjectRepository(DimClient)
    private clientRepository: Repository<DimClient>,
  ) {}

  // ==================== TRESORERIE ====================

  async getSolde(filter: PeriodeFilterDto) {
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

  async getEvolution(filter: PeriodeFilterDto) {
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

  async getBfr(filter: PeriodeFilterDto) {
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

  // ==================== BALANCE AGEE ====================

  async getBalanceAgee(filter: PeriodeFilterDto, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.balanceAgeeRepository
      .createQueryBuilder('ba')
      .leftJoin(DimClient, 'c', 'ba.client_sk = c.client_sk AND c.is_current = true')
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

    // Prendre la dernière date de calcul
    queryBuilder.andWhere(
      'ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)',
    );

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

  async getBalanceAgeeSynthese(filter: PeriodeFilterDto) {
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

    queryBuilder.andWhere(
      'ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)',
    );

    return queryBuilder.getRawOne();
  }

  async getClientsRisqueCredit(filter: PeriodeFilterDto, seuilRisque = 60) {
    const queryBuilder = this.balanceAgeeRepository
      .createQueryBuilder('ba')
      .leftJoin(DimClient, 'c', 'ba.client_sk = c.client_sk AND c.is_current = true')
      .select([
        'c.raison_sociale AS client',
        'c.ville',
        'ba.total_echu',
        'ba.score_risque_credit',
        'ba.dso_jours',
      ])
      .where('ba.score_risque_credit >= :seuil', { seuil: seuilRisque })
      .andWhere(
        'ba.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_balance_agee_client)',
      );

    if (filter.societeId) {
      queryBuilder.andWhere('ba.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('ba.score_risque_credit', 'DESC');

    return queryBuilder.getRawMany();
  }
}

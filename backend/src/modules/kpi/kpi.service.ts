import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { KpiGlobal, DimSociete } from '../../database/entities';
import { PeriodeFilterDto } from '../../common/dto';

@Injectable()
export class KpiService {
  constructor(
    @InjectRepository(KpiGlobal)
    private kpiRepository: Repository<KpiGlobal>,
    @InjectRepository(DimSociete)
    private societeRepository: Repository<DimSociete>,
  ) {}

  async getDashboard(filter: PeriodeFilterDto) {
    const queryBuilder = this.kpiRepository
      .createQueryBuilder('k')
      .leftJoin(DimSociete, 's', 'k.societe_sk = s.societe_sk AND s.is_current = true')
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

  async getKpisBySociete(societeId: number, filter: PeriodeFilterDto) {
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

  async getEvolution(filter: PeriodeFilterDto) {
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

    const totaux = latest.reduce(
      (acc, kpi) => ({
        ca_total: acc.ca_total + (parseFloat(kpi.ca_mensuel) || 0),
        marge_totale: acc.marge_totale + (parseFloat(kpi.marge_brute) || 0),
        tresorerie_totale: acc.tresorerie_totale + (parseFloat(kpi.tresorerie_nette) || 0),
        carnet_total: acc.carnet_total + (parseFloat(kpi.carnet_commandes) || 0),
        nb_affaires: acc.nb_affaires + (parseInt(kpi.nb_affaires_en_cours) || 0),
        nb_retards: acc.nb_retards + (parseInt(kpi.nb_affaires_en_retard) || 0),
        nb_depassements: acc.nb_depassements + (parseInt(kpi.nb_affaires_en_depassement) || 0),
      }),
      {
        ca_total: 0,
        marge_totale: 0,
        tresorerie_totale: 0,
        carnet_total: 0,
        nb_affaires: 0,
        nb_retards: 0,
        nb_depassements: 0,
      },
    );

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
}

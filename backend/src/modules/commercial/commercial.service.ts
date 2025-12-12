import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  AggCaPeriode,
  AggCaClient,
  AggCaAffaire,
  DimClient,
  DimAffaire,
} from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@Injectable()
export class CommercialService {
  constructor(
    @InjectRepository(AggCaPeriode)
    private caPeriodeRepository: Repository<AggCaPeriode>,
    @InjectRepository(AggCaClient)
    private caClientRepository: Repository<AggCaClient>,
    @InjectRepository(AggCaAffaire)
    private caAffaireRepository: Repository<AggCaAffaire>,
    @InjectRepository(DimClient)
    private clientRepository: Repository<DimClient>,
    @InjectRepository(DimAffaire)
    private affaireRepository: Repository<DimAffaire>,
  ) {}

  // ==================== CA PAR PERIODE ====================

  async getCaByPeriode(filter: PeriodeFilterDto) {
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

  async getCaEvolution(filter: PeriodeFilterDto) {
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

  // ==================== CLIENTS ====================

  async getClients(filter: PeriodeFilterDto, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.caClientRepository
      .createQueryBuilder('cac')
      .leftJoin(DimClient, 'c', 'cac.client_sk = c.client_sk AND c.is_current = true')
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

  async getClientById(clientId: number, filter: PeriodeFilterDto) {
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

  async getTopClients(filter: PeriodeFilterDto, limit = 10) {
    const queryBuilder = this.caClientRepository
      .createQueryBuilder('cac')
      .leftJoin(DimClient, 'c', 'cac.client_sk = c.client_sk AND c.is_current = true')
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

  // ==================== AFFAIRES ====================

  async getAffaires(filter: PeriodeFilterDto, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.caAffaireRepository
      .createQueryBuilder('caa')
      .leftJoin(DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
      .leftJoin(DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
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

  async getAffaireById(affaireId: number) {
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

  async getAffairesEnRetard(filter: PeriodeFilterDto) {
    const queryBuilder = this.caAffaireRepository
      .createQueryBuilder('caa')
      .leftJoin(DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
      .leftJoin(DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
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

  async getAffairesEnDepassement(filter: PeriodeFilterDto) {
    const queryBuilder = this.caAffaireRepository
      .createQueryBuilder('caa')
      .leftJoin(DimAffaire, 'a', 'caa.affaire_sk = a.affaire_sk AND a.is_current = true')
      .leftJoin(DimClient, 'c', 'caa.client_sk = c.client_sk AND c.is_current = true')
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

  // ==================== PRÉVISION CA ====================

  async getCaForecast(filter: PeriodeFilterDto) {
    const evolution = await this.caPeriodeRepository
      .createQueryBuilder('ca')
      .select([
        'ca.annee AS annee',
        'ca.mois AS mois',
        'SUM(ca.ca_facture) AS ca_facture',
      ])
      .where('ca.niveau_agregation = :niveau', { niveau: 'MOIS' })
      .groupBy('ca.annee')
      .addGroupBy('ca.mois')
      .orderBy('ca.annee', 'ASC')
      .addOrderBy('ca.mois', 'ASC')
      .getRawMany();

    if (evolution.length < 3) {
      return { historical: evolution, forecast: [], trend: 'INSUFFISANT' };
    }

    const values = evolution.map((e) => parseFloat(e.ca_facture) || 0);
    const n = values.length;

    // Régression linéaire simple: y = a + b*x
    const xMean = (n - 1) / 2;
    const yMean = values.reduce((a, b) => a + b, 0) / n;

    let numerator = 0;
    let denominator = 0;
    for (let i = 0; i < n; i++) {
      numerator += (i - xMean) * (values[i] - yMean);
      denominator += (i - xMean) * (i - xMean);
    }

    const slope = denominator !== 0 ? numerator / denominator : 0;
    const intercept = yMean - slope * xMean;

    // Prévision 3 mois
    const lastEntry = evolution[evolution.length - 1];
    let currentYear = parseInt(lastEntry.annee);
    let currentMonth = parseInt(lastEntry.mois);

    const forecast = [];
    for (let i = 1; i <= 3; i++) {
      currentMonth++;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      }

      const predictedValue = Math.max(0, intercept + slope * (n - 1 + i));
      const confidenceLow = predictedValue * 0.85;
      const confidenceHigh = predictedValue * 1.15;

      forecast.push({
        annee: currentYear,
        mois: currentMonth,
        ca_prevu: Math.round(predictedValue),
        confidence_low: Math.round(confidenceLow),
        confidence_high: Math.round(confidenceHigh),
      });
    }

    // Tendance
    const trend = slope > yMean * 0.02 ? 'HAUSSE' : slope < -yMean * 0.02 ? 'BAISSE' : 'STABLE';

    // Variation prévue
    const lastCA = values[values.length - 1];
    const forecastTotal = forecast.reduce((sum, f) => sum + f.ca_prevu, 0);
    const historicalLast3 = values.slice(-3).reduce((a, b) => a + b, 0);
    const variationPct = historicalLast3 > 0 ? ((forecastTotal - historicalLast3) / historicalLast3) * 100 : 0;

    return {
      historical: evolution.slice(-6),
      forecast,
      trend,
      slope: Math.round(slope),
      variation_pct: Math.round(variationPct * 10) / 10,
      ca_prevu_total: forecastTotal,
    };
  }
}

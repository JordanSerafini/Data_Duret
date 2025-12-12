import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AggStockElement, DimElement } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
import { StockFilterDto } from './dto/stock-filter.dto';

@Injectable()
export class StockService {
  constructor(
    @InjectRepository(AggStockElement)
    private stockRepository: Repository<AggStockElement>,
    @InjectRepository(DimElement)
    private elementRepository: Repository<DimElement>,
  ) {}

  async getAlertes(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.code AS code',
        'e.designation AS designation',
        'e.famille AS famille',
        's.depot_code AS depot_code',
        's.stock_final AS stock_final',
        's.stock_minimum AS stock_minimum',
        's.valeur_stock AS valeur_stock',
        's.rotation_stock AS rotation_stock',
        's.couverture_jours AS couverture_jours',
        's.est_sous_stock_mini AS rupture',
        's.est_surstock AS surstock',
        "CASE WHEN s.est_sous_stock_mini THEN 'RUPTURE IMMINENTE' WHEN s.est_surstock THEN 'SURSTOCK' ELSE 'OK' END AS alerte",
      ])
      .where('(s.est_sous_stock_mini = true OR s.est_surstock = true)')
      .andWhere('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder
      .orderBy('s.est_sous_stock_mini', 'DESC')
      .addOrderBy('s.valeur_stock', 'DESC');

    return queryBuilder.getRawMany();
  }

  async getAlertesRupture(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.code',
        'e.designation',
        'e.famille',
        's.depot_code',
        's.stock_final',
        's.stock_minimum',
        's.couverture_jours',
        's.conso_moyenne_mensuelle',
      ])
      .where('s.est_sous_stock_mini = true')
      .andWhere('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('s.couverture_jours', 'ASC');

    return queryBuilder.getRawMany();
  }

  async getAlertesSurstock(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.code',
        'e.designation',
        'e.famille',
        's.depot_code',
        's.stock_final',
        's.valeur_stock',
        's.rotation_stock',
        's.couverture_jours',
      ])
      .where('s.est_surstock = true')
      .andWhere('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('s.valeur_stock', 'DESC');

    return queryBuilder.getRawMany();
  }

  async getRotation(filter: PeriodeFilterDto, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.element_sk AS id',
        'e.code',
        'e.designation',
        'e.famille',
        's.stock_final',
        's.valeur_stock',
        's.rotation_stock',
        's.couverture_jours',
        's.conso_moyenne_mensuelle',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    const total = await queryBuilder.getCount();

    queryBuilder
      .orderBy('s.rotation_stock', 'DESC')
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

  async getSynthese(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .select([
        'COUNT(*) AS nb_articles',
        'SUM(s.valeur_stock) AS valeur_totale',
        'SUM(CASE WHEN s.est_sous_stock_mini THEN 1 ELSE 0 END) AS nb_ruptures',
        'SUM(CASE WHEN s.est_surstock THEN 1 ELSE 0 END) AS nb_surstocks',
        'AVG(s.rotation_stock) AS rotation_moyenne',
        'AVG(s.couverture_jours) AS couverture_moyenne',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    return queryBuilder.getRawOne();
  }

  async getValeurParFamille(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.famille AS famille',
        'COUNT(*) AS nb_articles',
        'SUM(s.valeur_stock) AS valeur',
        'AVG(s.rotation_stock) AS rotation_moyenne',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)')
      .groupBy('e.famille');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('SUM(s.valeur_stock)', 'DESC');

    return queryBuilder.getRawMany();
  }

  async findAll(filter: StockFilterDto) {
    const { page = 1, limit = 20, sortField = 'valeur_stock', sortOrder = 'DESC' } = filter;
    const skip = (page - 1) * limit;

    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.element_sk AS id',
        'e.code AS code',
        'e.designation AS designation',
        'e.famille AS famille',
        'e.unite AS unite',
        's.stock_final AS stock_final',
        's.valeur_stock AS valeur_stock',
        's.prix_moyen_pondere AS prix_moyen_pondere',
        's.rotation_stock AS rotation_stock',
        's.couverture_jours AS couverture_jours',
        's.est_sous_stock_mini AS est_sous_stock_mini',
        's.est_surstock AS est_surstock',
        's.conso_moyenne_mensuelle AS conso_moyenne_mensuelle',
        's.last_updated AS last_updated',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    if (filter.famille) {
      queryBuilder.andWhere('e.famille = :famille', { famille: filter.famille });
    }

    if (filter.search) {
      queryBuilder.andWhere(
        '(LOWER(e.code) LIKE :search OR LOWER(e.designation) LIKE :search)',
        { search: `%${filter.search.toLowerCase()}%` },
      );
    }

    const total = await queryBuilder.getCount();

    // Map sort fields to actual columns
    const sortMapping = {
      valeur_stock: 's.valeur_stock',
      stock_final: 's.stock_final',
      rotation_stock: 's.rotation_stock',
      couverture_jours: 's.couverture_jours',
      code: 'e.code',
      designation: 'e.designation',
    };

    const sortColumn = sortMapping[sortField as keyof typeof sortMapping] || 's.valeur_stock';

    queryBuilder
      .orderBy(sortColumn, sortOrder)
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

  async getFamilles() {
    const queryBuilder = this.elementRepository
      .createQueryBuilder('e')
      .select('DISTINCT e.famille', 'famille')
      .where('e.is_current = true')
      .andWhere('e.famille IS NOT NULL')
      .orderBy('e.famille', 'ASC');

    const results = await queryBuilder.getRawMany();
    return results.map((r) => r.famille);
  }

  // ==================== PRÉVISIONS STOCK ====================

  async getStockPrevisions(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.element_sk AS id',
        'e.code AS code',
        'e.designation AS designation',
        'e.famille AS famille',
        's.stock_final AS stock_final',
        's.stock_minimum AS stock_minimum',
        's.conso_moyenne_mensuelle AS conso_moyenne',
        's.conso_dernier_mois AS conso_dernier_mois',
        's.valeur_stock AS valeur_stock',
        's.couverture_jours AS couverture_jours',
        // Calcul jours avant atteinte du stock minimum
        `CASE
          WHEN s.conso_moyenne_mensuelle > 0 THEN
            ROUND(((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30))::numeric, 0)
          ELSE NULL
        END AS jours_avant_mini`,
        // Tendance consommation
        `CASE
          WHEN s.conso_moyenne_mensuelle > 0 AND s.conso_dernier_mois IS NOT NULL THEN
            ROUND(((s.conso_dernier_mois - s.conso_moyenne_mensuelle) / s.conso_moyenne_mensuelle * 100)::numeric, 1)
          ELSE 0
        END AS tendance_conso_pct`,
        // Niveau d'alerte
        `CASE
          WHEN s.stock_final <= s.stock_minimum THEN 'RUPTURE'
          WHEN s.conso_moyenne_mensuelle > 0 AND ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30)) <= 7 THEN 'CRITIQUE'
          WHEN s.conso_moyenne_mensuelle > 0 AND ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30)) <= 15 THEN 'ATTENTION'
          WHEN s.conso_moyenne_mensuelle > 0 AND ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30)) <= 30 THEN 'SURVEILLANCE'
          ELSE 'OK'
        END AS niveau_alerte`,
        // Score de criticité (0-100, plus élevé = plus critique)
        `CASE
          WHEN s.stock_final <= s.stock_minimum THEN 100
          WHEN s.conso_moyenne_mensuelle > 0 THEN
            GREATEST(0, LEAST(100,
              100 - ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30))::numeric
            ))::integer
          ELSE 0
        END AS score_criticite`,
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)')
      .andWhere('s.conso_moyenne_mensuelle > 0');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    // Filtrer seulement les articles à surveiller (<=30 jours ou rupture)
    queryBuilder.andWhere(`(
      s.stock_final <= s.stock_minimum
      OR (s.conso_moyenne_mensuelle > 0 AND ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30)) <= 30)
    )`);

    queryBuilder.orderBy('score_criticite', 'DESC');

    const data = await queryBuilder.getRawMany();

    // Grouper par niveau d'alerte
    const parNiveau = {
      rupture: data.filter((d) => d.niveau_alerte === 'RUPTURE'),
      critique: data.filter((d) => d.niveau_alerte === 'CRITIQUE'),
      attention: data.filter((d) => d.niveau_alerte === 'ATTENTION'),
      surveillance: data.filter((d) => d.niveau_alerte === 'SURVEILLANCE'),
    };

    return {
      alertes: data,
      synthese: {
        nb_rupture: parNiveau.rupture.length,
        nb_critique: parNiveau.critique.length,
        nb_attention: parNiveau.attention.length,
        nb_surveillance: parNiveau.surveillance.length,
        valeur_a_risque: data.reduce((sum, d) => sum + (parseFloat(d.valeur_stock) || 0), 0),
      },
      par_niveau: parNiveau,
    };
  }

  async getStockHealthScore(filter: PeriodeFilterDto) {
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .select([
        'COUNT(*) AS nb_total',
        'SUM(s.valeur_stock) AS valeur_totale',
        // Ruptures
        'SUM(CASE WHEN s.est_sous_stock_mini THEN 1 ELSE 0 END) AS nb_ruptures',
        'SUM(CASE WHEN s.est_sous_stock_mini THEN s.valeur_stock ELSE 0 END) AS valeur_ruptures',
        // Surstocks
        'SUM(CASE WHEN s.est_surstock THEN 1 ELSE 0 END) AS nb_surstocks',
        'SUM(CASE WHEN s.est_surstock THEN s.valeur_stock ELSE 0 END) AS valeur_surstocks',
        // Articles à risque (<=15 jours)
        `SUM(CASE WHEN s.conso_moyenne_mensuelle > 0
          AND ((s.stock_final - s.stock_minimum) / (s.conso_moyenne_mensuelle / 30)) <= 15
          THEN 1 ELSE 0 END) AS nb_risque_15j`,
        // Rotation
        'AVG(s.rotation_stock) AS rotation_moyenne',
        'AVG(s.couverture_jours) FILTER (WHERE s.conso_moyenne_mensuelle > 0) AS couverture_moyenne',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    const stats = await queryBuilder.getRawOne();

    // Calcul du score de santé (0-100)
    const nbTotal = parseInt(stats.nb_total) || 1;
    const nbRuptures = parseInt(stats.nb_ruptures) || 0;
    const nbSurstocks = parseInt(stats.nb_surstocks) || 0;
    const nbRisque15j = parseInt(stats.nb_risque_15j) || 0;
    const valeurTotale = parseFloat(stats.valeur_totale) || 1;
    const valeurRuptures = parseFloat(stats.valeur_ruptures) || 0;
    const valeurSurstocks = parseFloat(stats.valeur_surstocks) || 0;

    // Score basé sur plusieurs critères (pondérés)
    const tauxRupture = (nbRuptures / nbTotal) * 100;
    const tauxSurstock = (nbSurstocks / nbTotal) * 100;
    const tauxRisque = (nbRisque15j / nbTotal) * 100;
    const tauxValeurRisque = ((valeurRuptures + valeurSurstocks) / valeurTotale) * 100;

    // Score = 100 - pénalités
    const score = Math.max(0, Math.min(100, Math.round(
      100
      - (tauxRupture * 3)      // -3 points par % de rupture
      - (tauxRisque * 1.5)     // -1.5 point par % à risque 15j
      - (tauxSurstock * 0.5)   // -0.5 point par % surstock
      - (tauxValeurRisque * 0.3) // -0.3 point par % valeur à risque
    )));

    // Classification
    let status: string;
    if (score >= 80) status = 'EXCELLENT';
    else if (score >= 60) status = 'BON';
    else if (score >= 40) status = 'ATTENTION';
    else status = 'CRITIQUE';

    return {
      score,
      status,
      details: {
        nb_total: nbTotal,
        nb_ruptures: nbRuptures,
        nb_surstocks: nbSurstocks,
        nb_risque_15j: nbRisque15j,
        valeur_totale: valeurTotale,
        valeur_ruptures: valeurRuptures,
        valeur_surstocks: valeurSurstocks,
        rotation_moyenne: parseFloat(stats.rotation_moyenne) || 0,
        couverture_moyenne: parseFloat(stats.couverture_moyenne) || 0,
      },
      indicateurs: {
        taux_rupture: Math.round(tauxRupture * 10) / 10,
        taux_surstock: Math.round(tauxSurstock * 10) / 10,
        taux_risque_15j: Math.round(tauxRisque * 10) / 10,
        taux_valeur_risque: Math.round(tauxValeurRisque * 10) / 10,
      },
    };
  }
}

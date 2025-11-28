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
        'e.code',
        'e.designation',
        'e.famille',
        's.depot_code',
        's.stock_final',
        's.stock_minimum',
        's.valeur_stock',
        's.rotation_stock',
        's.couverture_jours',
        's.est_sous_stock_mini AS rupture',
        's.est_surstock AS surstock',
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
        'e.famille',
        'COUNT(*) AS nb_articles',
        'SUM(s.valeur_stock) AS valeur_totale',
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
}

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

  // ==================== ANALYSE ABC/XYZ (CLASSIFICATION INVENTAIRE BTP) ====================

  /**
   * Analyse ABC/XYZ standard pour le BTP
   * ABC = Classification par valeur (Pareto):
   *   - A: 70% de la valeur totale (articles stratégiques)
   *   - B: 25% de la valeur totale (articles importants)
   *   - C: 5% de la valeur totale (articles courants)
   * XYZ = Classification par variabilité de consommation:
   *   - X: CV < 20% (consommation stable, prévisible)
   *   - Y: CV 20-50% (consommation variable, tendances)
   *   - Z: CV > 50% (consommation imprévisible)
   */
  async getAbcXyzAnalysis(filter: PeriodeFilterDto) {
    // Récupérer tous les articles avec leur valeur et consommation
    const queryBuilder = this.stockRepository
      .createQueryBuilder('s')
      .leftJoin(DimElement, 'e', 's.element_sk = e.element_sk AND e.is_current = true')
      .select([
        'e.element_sk AS id',
        'e.code AS code',
        'e.designation AS designation',
        'e.famille AS famille',
        's.valeur_stock AS valeur_stock',
        's.conso_moyenne_mensuelle AS conso_moyenne',
        's.conso_dernier_mois AS conso_dernier_mois',
        's.stock_final AS stock_final',
        's.rotation_stock AS rotation_stock',
        's.couverture_jours AS couverture_jours',
        // Écart-type estimé (approximation avec dernier mois vs moyenne)
        `CASE
          WHEN s.conso_moyenne_mensuelle > 0 THEN
            ABS(COALESCE(s.conso_dernier_mois, s.conso_moyenne_mensuelle) - s.conso_moyenne_mensuelle)
          ELSE 0
        END AS ecart_conso`,
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)')
      .andWhere('s.valeur_stock > 0');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('s.valeur_stock', 'DESC');

    const articles = await queryBuilder.getRawMany();

    if (articles.length === 0) {
      return {
        synthese: {
          nb_articles: 0,
          valeur_totale: 0,
          repartition_abc: { A: 0, B: 0, C: 0 },
          repartition_xyz: { X: 0, Y: 0, Z: 0 },
        },
        matrice: {},
        articles: [],
        recommandations: [],
      };
    }

    // Calcul de la valeur totale
    const valeurTotale = articles.reduce((sum, a) => sum + (parseFloat(a.valeur_stock) || 0), 0);

    // Classification ABC (Pareto)
    let valeurCumulee = 0;
    const articlesClassifies = articles.map((article) => {
      const valeur = parseFloat(article.valeur_stock) || 0;
      valeurCumulee += valeur;
      const pourcentageCumule = (valeurCumulee / valeurTotale) * 100;

      // Classification ABC
      let classe_abc: 'A' | 'B' | 'C';
      if (pourcentageCumule <= 70) {
        classe_abc = 'A';
      } else if (pourcentageCumule <= 95) {
        classe_abc = 'B';
      } else {
        classe_abc = 'C';
      }

      // Classification XYZ (Coefficient de Variation)
      const consoMoyenne = parseFloat(article.conso_moyenne) || 0;
      const ecartConso = parseFloat(article.ecart_conso) || 0;
      const cv = consoMoyenne > 0 ? (ecartConso / consoMoyenne) * 100 : 0;

      let classe_xyz: 'X' | 'Y' | 'Z';
      if (cv < 20) {
        classe_xyz = 'X';
      } else if (cv <= 50) {
        classe_xyz = 'Y';
      } else {
        classe_xyz = 'Z';
      }

      // Classification combinée
      const classe_combinee = `${classe_abc}${classe_xyz}`;

      // Score de priorité (AX=1, AY=2, AZ=3, BX=4, ..., CZ=9)
      const prioriteAbc = { A: 0, B: 3, C: 6 };
      const prioriteXyz = { X: 1, Y: 2, Z: 3 };
      const score_priorite = prioriteAbc[classe_abc] + prioriteXyz[classe_xyz];

      return {
        ...article,
        valeur_stock: valeur,
        conso_moyenne: consoMoyenne,
        pourcentage_cumule: Math.round(pourcentageCumule * 10) / 10,
        coefficient_variation: Math.round(cv * 10) / 10,
        classe_abc,
        classe_xyz,
        classe_combinee,
        score_priorite,
      };
    });

    // Comptage par classe
    const repartitionAbc = {
      A: articlesClassifies.filter((a) => a.classe_abc === 'A').length,
      B: articlesClassifies.filter((a) => a.classe_abc === 'B').length,
      C: articlesClassifies.filter((a) => a.classe_abc === 'C').length,
    };

    const repartitionXyz = {
      X: articlesClassifies.filter((a) => a.classe_xyz === 'X').length,
      Y: articlesClassifies.filter((a) => a.classe_xyz === 'Y').length,
      Z: articlesClassifies.filter((a) => a.classe_xyz === 'Z').length,
    };

    // Matrice ABC/XYZ avec valeurs
    const matrice: Record<string, { count: number; valeur: number; articles: typeof articlesClassifies }> = {};
    ['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ', 'CX', 'CY', 'CZ'].forEach((classe) => {
      const articlesClasse = articlesClassifies.filter((a) => a.classe_combinee === classe);
      matrice[classe] = {
        count: articlesClasse.length,
        valeur: articlesClasse.reduce((sum, a) => sum + a.valeur_stock, 0),
        articles: articlesClasse.slice(0, 5), // Top 5 par classe
      };
    });

    // Valeur par classe ABC
    const valeurParAbc = {
      A: articlesClassifies.filter((a) => a.classe_abc === 'A').reduce((sum, a) => sum + a.valeur_stock, 0),
      B: articlesClassifies.filter((a) => a.classe_abc === 'B').reduce((sum, a) => sum + a.valeur_stock, 0),
      C: articlesClassifies.filter((a) => a.classe_abc === 'C').reduce((sum, a) => sum + a.valeur_stock, 0),
    };

    // Recommandations basées sur l'analyse
    const recommandations: Array<{
      type: string;
      priorite: 'HAUTE' | 'MOYENNE' | 'BASSE';
      classe: string;
      message: string;
      nb_articles: number;
    }> = [];

    // AX: Articles critiques à surveiller de près
    if (matrice['AX'].count > 0) {
      recommandations.push({
        type: 'STOCK_SECURITE',
        priorite: 'HAUTE',
        classe: 'AX',
        message: 'Articles haute valeur / consommation stable: Optimiser le stock de sécurité, négocier contrats cadres',
        nb_articles: matrice['AX'].count,
      });
    }

    // AZ: Articles critiques mais imprévisibles
    if (matrice['AZ'].count > 0) {
      recommandations.push({
        type: 'RISQUE_RUPTURE',
        priorite: 'HAUTE',
        classe: 'AZ',
        message: 'Articles haute valeur / consommation imprévisible: Stock tampon élevé nécessaire, prévoir alternatives',
        nb_articles: matrice['AZ'].count,
      });
    }

    // BZ: Articles à surveiller
    if (matrice['BZ'].count > 0) {
      recommandations.push({
        type: 'SURVEILLANCE',
        priorite: 'MOYENNE',
        classe: 'BZ',
        message: 'Articles valeur moyenne / consommation imprévisible: Envisager commandes à la demande',
        nb_articles: matrice['BZ'].count,
      });
    }

    // CX: Candidats au réapprovisionnement automatique
    if (matrice['CX'].count > 0) {
      recommandations.push({
        type: 'AUTOMATISATION',
        priorite: 'BASSE',
        classe: 'CX',
        message: 'Articles faible valeur / consommation stable: Automatiser les réapprovisionnements (Kanban)',
        nb_articles: matrice['CX'].count,
      });
    }

    // CZ: Candidats à l'élimination
    if (matrice['CZ'].count > 0) {
      recommandations.push({
        type: 'OPTIMISATION',
        priorite: 'BASSE',
        classe: 'CZ',
        message: 'Articles faible valeur / consommation imprévisible: Envisager achat ponctuel ou élimination',
        nb_articles: matrice['CZ'].count,
      });
    }

    return {
      synthese: {
        nb_articles: articles.length,
        valeur_totale: Math.round(valeurTotale),
        repartition_abc: repartitionAbc,
        repartition_xyz: repartitionXyz,
        valeur_par_abc: {
          A: Math.round(valeurParAbc.A),
          B: Math.round(valeurParAbc.B),
          C: Math.round(valeurParAbc.C),
        },
        pourcentage_valeur_abc: {
          A: Math.round((valeurParAbc.A / valeurTotale) * 1000) / 10,
          B: Math.round((valeurParAbc.B / valeurTotale) * 1000) / 10,
          C: Math.round((valeurParAbc.C / valeurTotale) * 1000) / 10,
        },
      },
      matrice,
      articles: articlesClassifies,
      recommandations,
    };
  }

  // ==================== RECOMMANDATIONS RÉAPPROVISIONNEMENT ====================

  /**
   * Génère des recommandations de réapprovisionnement basées sur:
   * - Point de commande (ROP = Reorder Point)
   * - Quantité économique de commande (EOQ)
   * - Stock de sécurité
   * - Délai d'approvisionnement estimé
   */
  async getReorderRecommendations(filter: PeriodeFilterDto) {
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
        's.valeur_stock AS valeur_stock',
        's.prix_moyen_pondere AS pmp',
        's.couverture_jours AS couverture_jours',
        's.rotation_stock AS rotation',
        // Consommation journalière
        'CASE WHEN s.conso_moyenne_mensuelle > 0 THEN s.conso_moyenne_mensuelle / 30 ELSE 0 END AS conso_journaliere',
      ])
      .where('s.date_calcul = (SELECT MAX(date_calcul) FROM gold.agg_stock_element)')
      .andWhere('s.conso_moyenne_mensuelle > 0');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    const articles = await queryBuilder.getRawMany();

    // Paramètres standards BTP
    const DELAI_APPROVISIONNEMENT_JOURS = 14; // 2 semaines
    const COEFFICIENT_SECURITE = 1.5; // Facteur de sécurité
    const COUT_PASSATION_COMMANDE = 50; // en EUR
    const TAUX_POSSESSION = 0.20; // 20% par an

    const recommandations = articles.map((article) => {
      const stockFinal = parseFloat(article.stock_final) || 0;
      const stockMinimum = parseFloat(article.stock_minimum) || 0;
      const consoJournaliere = parseFloat(article.conso_journaliere) || 0;
      const consoMensuelle = parseFloat(article.conso_moyenne) || 0;
      const pmp = parseFloat(article.pmp) || 1;
      const valeurStock = parseFloat(article.valeur_stock) || 0;

      // Stock de sécurité = Coefficient * Conso journalière * Délai
      const stockSecurite = Math.ceil(COEFFICIENT_SECURITE * consoJournaliere * DELAI_APPROVISIONNEMENT_JOURS);

      // Point de commande (ROP) = (Conso journalière * Délai) + Stock sécurité
      const pointCommande = Math.ceil((consoJournaliere * DELAI_APPROVISIONNEMENT_JOURS) + stockSecurite);

      // Quantité économique (EOQ - Wilson)
      // EOQ = sqrt((2 * D * S) / (H))
      // D = demande annuelle, S = coût commande, H = coût possession unitaire
      const demandeAnnuelle = consoMensuelle * 12;
      const coutPossession = pmp * TAUX_POSSESSION;
      const eoq = coutPossession > 0
        ? Math.ceil(Math.sqrt((2 * demandeAnnuelle * COUT_PASSATION_COMMANDE) / coutPossession))
        : Math.ceil(consoMensuelle);

      // Jours avant point de commande
      const joursAvantROP = consoJournaliere > 0
        ? Math.floor((stockFinal - pointCommande) / consoJournaliere)
        : 999;

      // Statut et urgence
      let urgence: 'IMMEDIAT' | 'URGENT' | 'PLANIFIE' | 'OK';
      let action: string;

      if (stockFinal <= stockMinimum) {
        urgence = 'IMMEDIAT';
        action = 'Commander immédiatement';
      } else if (joursAvantROP <= 0) {
        urgence = 'URGENT';
        action = 'Commander sous 48h';
      } else if (joursAvantROP <= 7) {
        urgence = 'PLANIFIE';
        action = 'Planifier commande cette semaine';
      } else {
        urgence = 'OK';
        action = 'Pas d\'action requise';
      }

      // Quantité à commander
      const quantiteACommander = urgence !== 'OK' ? Math.max(eoq, pointCommande - stockFinal + stockSecurite) : 0;

      // Coût estimé
      const coutCommande = quantiteACommander * pmp;

      return {
        id: article.id,
        code: article.code,
        designation: article.designation,
        famille: article.famille,
        stock_actuel: stockFinal,
        stock_minimum: stockMinimum,
        stock_securite: stockSecurite,
        point_commande: pointCommande,
        eoq: eoq,
        conso_journaliere: Math.round(consoJournaliere * 10) / 10,
        jours_avant_rop: joursAvantROP,
        urgence,
        action,
        quantite_recommandee: Math.ceil(quantiteACommander),
        cout_estime: Math.round(coutCommande),
        pmp,
        rotation: parseFloat(article.rotation) || 0,
      };
    });

    // Trier par urgence puis par valeur
    const urgenceOrder = { IMMEDIAT: 0, URGENT: 1, PLANIFIE: 2, OK: 3 };
    recommandations.sort((a, b) => {
      if (urgenceOrder[a.urgence] !== urgenceOrder[b.urgence]) {
        return urgenceOrder[a.urgence] - urgenceOrder[b.urgence];
      }
      return b.cout_estime - a.cout_estime;
    });

    // Filtrer seulement ceux nécessitant une action
    const actionsRequises = recommandations.filter((r) => r.urgence !== 'OK');

    // Synthèse
    const synthese = {
      nb_articles_total: articles.length,
      nb_actions_requises: actionsRequises.length,
      par_urgence: {
        immediat: recommandations.filter((r) => r.urgence === 'IMMEDIAT').length,
        urgent: recommandations.filter((r) => r.urgence === 'URGENT').length,
        planifie: recommandations.filter((r) => r.urgence === 'PLANIFIE').length,
      },
      budget_estime: {
        immediat: recommandations
          .filter((r) => r.urgence === 'IMMEDIAT')
          .reduce((sum, r) => sum + r.cout_estime, 0),
        urgent: recommandations
          .filter((r) => r.urgence === 'URGENT')
          .reduce((sum, r) => sum + r.cout_estime, 0),
        total: actionsRequises.reduce((sum, r) => sum + r.cout_estime, 0),
      },
    };

    return {
      synthese,
      actions_requises: actionsRequises,
      tous_articles: recommandations,
    };
  }
}

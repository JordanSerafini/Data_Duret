import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AggHeuresSalarie, DimSalarie } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@Injectable()
export class RhService {
  constructor(
    @InjectRepository(AggHeuresSalarie)
    private heuresRepository: Repository<AggHeuresSalarie>,
    @InjectRepository(DimSalarie)
    private salarieRepository: Repository<DimSalarie>,
  ) {}

  async getProductivite(filter: PeriodeFilterDto, pagination: PaginationDto) {
    const { page = 1, limit = 20 } = pagination;
    const skip = (page - 1) * limit;

    const queryBuilder = this.heuresRepository
      .createQueryBuilder('h')
      .leftJoin(DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
      .select([
        's.salarie_sk AS id',
        's.matricule',
        's.nom_complet AS nom',
        's.poste',
        's.qualification',
        'h.annee',
        'h.mois',
        'h.heures_total',
        'h.heures_theoriques',
        'h.taux_occupation',
        'h.heures_productives',
        'h.taux_productivite',
        'h.nb_affaires_travaillees',
        'h.cout_horaire_moyen',
        'h.cout_total',
      ]);

    if (filter.annee) {
      queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
    }
    if (filter.mois) {
      queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
    }
    if (filter.societeId) {
      queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
    }

    const total = await queryBuilder.getCount();

    queryBuilder
      .orderBy('h.taux_productivite', 'DESC')
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

  async getHeuresParSalarie(salarieId: number, filter: PeriodeFilterDto) {
    const salarie = await this.salarieRepository.findOne({
      where: { salarieSk: salarieId, isCurrent: true },
    });

    const queryBuilder = this.heuresRepository
      .createQueryBuilder('h')
      .where('h.salarie_sk = :salarieId', { salarieId });

    if (filter.annee) {
      queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
    }

    queryBuilder.orderBy('h.annee', 'DESC').addOrderBy('h.mois', 'DESC');

    const heures = await queryBuilder.getMany();

    return {
      salarie,
      history: await queryBuilder.getRawMany(),
    };
  }

  async getPostes() {
    const queryBuilder = this.salarieRepository
      .createQueryBuilder('s')
      .select('DISTINCT s.poste', 'poste')
      .where('s.is_current = true')
      .andWhere('s.poste IS NOT NULL')
      .orderBy('s.poste', 'ASC');

    const results = await queryBuilder.getRawMany();
    return results.map((r) => r.poste);
  }

  async getQualifications() {
    const queryBuilder = this.salarieRepository
      .createQueryBuilder('s')
      .select('DISTINCT s.qualification', 'qualification')
      .where('s.is_current = true')
      .andWhere('s.qualification IS NOT NULL')
      .orderBy('s.qualification', 'ASC');

    const results = await queryBuilder.getRawMany();
    return results.map((r) => r.qualification);
  }

  async getSyntheseMensuelle(filter: PeriodeFilterDto) {
    const queryBuilder = this.heuresRepository
      .createQueryBuilder('h')
      .select([
        'h.annee',
        'h.mois',
        'COUNT(DISTINCT h.salarie_sk) AS nb_salaries',
        'SUM(h.heures_total) AS heures_totales',
        'SUM(h.heures_productives) AS heures_productives',
        'AVG(h.taux_occupation) AS taux_occupation_moyen',
        'AVG(h.taux_productivite) AS taux_productivite_moyen',
        'SUM(h.cout_total) AS cout_total',
        'AVG(h.cout_horaire_moyen) AS cout_horaire_moyen',
      ])
      .groupBy('h.annee')
      .addGroupBy('h.mois');

    if (filter.annee) {
      queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
    }
    if (filter.societeId) {
      queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('h.annee', 'DESC').addOrderBy('h.mois', 'DESC');

    return queryBuilder.getRawMany();
  }

  async getTopProductifs(filter: PeriodeFilterDto, limit = 10) {
    const queryBuilder = this.heuresRepository
      .createQueryBuilder('h')
      .leftJoin(DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
      .select([
        's.nom_complet AS nom',
        's.poste',
        'h.taux_productivite',
        'h.nb_affaires_travaillees',
        'h.heures_productives',
      ]);

    if (filter.annee) {
      queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
    }
    if (filter.mois) {
      queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
    }
    if (filter.societeId) {
      queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('h.taux_productivite', 'DESC').limit(limit);

    return queryBuilder.getRawMany();
  }

  async getSalariesSousOccupes(filter: PeriodeFilterDto, seuilOccupation = 70) {
    const queryBuilder = this.heuresRepository
      .createQueryBuilder('h')
      .leftJoin(DimSalarie, 's', 'h.salarie_sk = s.salarie_sk AND s.is_current = true')
      .select([
        's.nom_complet AS nom',
        's.poste',
        'h.taux_occupation',
        'h.heures_total',
        'h.heures_theoriques',
      ])
      .where('h.taux_occupation < :seuil', { seuil: seuilOccupation });

    if (filter.annee) {
      queryBuilder.andWhere('h.annee = :annee', { annee: filter.annee });
    }
    if (filter.mois) {
      queryBuilder.andWhere('h.mois = :mois', { mois: filter.mois });
    }
    if (filter.societeId) {
      queryBuilder.andWhere('h.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('h.taux_occupation', 'ASC');

    return queryBuilder.getRawMany();
  }

  async getSalaries(filter: PeriodeFilterDto) {
    const queryBuilder = this.salarieRepository
      .createQueryBuilder('s')
      .where('s.is_current = true')
      .andWhere('s.est_actif = true');

    if (filter.societeId) {
      queryBuilder.andWhere('s.societe_sk = :societeId', { societeId: filter.societeId });
    }

    queryBuilder.orderBy('s.nom_complet', 'ASC');

    return queryBuilder.getMany();
  }
}

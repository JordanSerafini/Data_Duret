import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual, IsNull, Not } from 'typeorm';
import {
  DataQualityRule,
  DataQualityCheck,
  DataAnomaly,
} from '../../database/entities';
import { PaginationDto } from '../../common/dto';

@Injectable()
export class DataQualityService {
  constructor(
    @InjectRepository(DataQualityRule)
    private ruleRepository: Repository<DataQualityRule>,
    @InjectRepository(DataQualityCheck)
    private checkRepository: Repository<DataQualityCheck>,
    @InjectRepository(DataAnomaly)
    private anomalyRepository: Repository<DataAnomaly>,
  ) {}

  // ==================== RULES ====================

  async getRules() {
    return this.ruleRepository.find({
      order: { severity: 'ASC', layer: 'ASC', tableName: 'ASC' },
    });
  }

  async getActiveRules() {
    return this.ruleRepository.find({
      where: { isActive: true },
      order: { severity: 'ASC', layer: 'ASC' },
    });
  }

  async getRulesByLayer(layer: string) {
    return this.ruleRepository.find({
      where: { layer: layer.toUpperCase(), isActive: true },
      order: { severity: 'ASC' },
    });
  }

  // ==================== CHECKS ====================

  async getLatestChecks(pagination: PaginationDto) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const [data, total] = await this.checkRepository.findAndCount({
      order: { executionTime: 'DESC', passed: 'ASC' },
      skip,
      take: limit,
    });

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

  async getChecksByDate(date: Date) {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    return this.checkRepository.find({
      where: { executionTime: MoreThanOrEqual(startOfDay) },
      order: { passed: 'ASC', checkName: 'ASC' },
    });
  }

  async getFailedChecks(pagination: PaginationDto) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const [data, total] = await this.checkRepository.findAndCount({
      where: { passed: false },
      order: { executionTime: 'DESC' },
      skip,
      take: limit,
    });

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

  async getChecksSummary() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [totalChecks, passedToday, failedToday, lastExecution] =
      await Promise.all([
        this.checkRepository.count(),
        this.checkRepository.count({
          where: { passed: true, executionTime: MoreThanOrEqual(today) },
        }),
        this.checkRepository.count({
          where: { passed: false, executionTime: MoreThanOrEqual(today) },
        }),
        this.checkRepository.findOne({
          order: { executionTime: 'DESC' },
          select: ['executionTime'],
        }),
      ]);

    const failedByType = await this.checkRepository
      .createQueryBuilder('c')
      .select(['c.check_type AS type', 'COUNT(*) AS count'])
      .where('c.passed = false')
      .andWhere('c.execution_time >= :today', { today })
      .groupBy('c.check_type')
      .getRawMany();

    return {
      total_checks: totalChecks,
      today: {
        passed: passedToday,
        failed: failedToday,
        total: passedToday + failedToday,
        success_rate:
          passedToday + failedToday > 0
            ? ((passedToday / (passedToday + failedToday)) * 100).toFixed(1)
            : 0,
      },
      last_execution: lastExecution?.executionTime,
      failed_by_type: failedByType,
    };
  }

  // ==================== ANOMALIES ====================

  async getAnomalies(pagination: PaginationDto, severity?: string) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = {};
    if (severity) {
      where.severity = severity.toUpperCase();
    }

    const [data, total] = await this.anomalyRepository.findAndCount({
      where,
      order: {
        resolvedAt: 'ASC',
        detectedAt: 'DESC',
      },
      skip,
      take: limit,
    });

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

  async getUnresolvedAnomalies(pagination: PaginationDto) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const [data, total] = await this.anomalyRepository.findAndCount({
      where: { resolvedAt: IsNull() },
      order: {
        severity: 'ASC',
        detectedAt: 'DESC',
      },
      skip,
      take: limit,
    });

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

  async getAnomaliesByLayer(layer: string) {
    return this.anomalyRepository.find({
      where: { layer: layer.toUpperCase(), resolvedAt: IsNull() },
      order: { severity: 'ASC', detectedAt: 'DESC' },
    });
  }

  async getAnomaliesSummary() {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [total, unresolved, bySeverity, byLayer, byType] = await Promise.all([
      this.anomalyRepository.count({
        where: { detectedAt: MoreThanOrEqual(thirtyDaysAgo) },
      }),
      this.anomalyRepository.count({
        where: { resolvedAt: IsNull() },
      }),
      this.anomalyRepository
        .createQueryBuilder('a')
        .select(['a.severity', 'COUNT(*) AS count'])
        .where('a.resolved_at IS NULL')
        .groupBy('a.severity')
        .getRawMany(),
      this.anomalyRepository
        .createQueryBuilder('a')
        .select(['a.layer', 'COUNT(*) AS count'])
        .where('a.resolved_at IS NULL')
        .groupBy('a.layer')
        .getRawMany(),
      this.anomalyRepository
        .createQueryBuilder('a')
        .select(['a.anomaly_type AS type', 'COUNT(*) AS count'])
        .where('a.resolved_at IS NULL')
        .groupBy('a.anomaly_type')
        .orderBy('count', 'DESC')
        .limit(10)
        .getRawMany(),
    ]);

    return {
      last_30_days: total,
      unresolved: unresolved,
      by_severity: bySeverity.reduce(
        (acc, item) => {
          acc[item.severity.toLowerCase()] = parseInt(item.count);
          return acc;
        },
        {} as Record<string, number>,
      ),
      by_layer: byLayer.reduce(
        (acc, item) => {
          acc[item.layer.toLowerCase()] = parseInt(item.count);
          return acc;
        },
        {} as Record<string, number>,
      ),
      top_types: byType,
    };
  }

  async resolveAnomaly(id: number, comment: string) {
    await this.anomalyRepository.update(id, {
      resolvedAt: new Date(),
      resolutionComment: comment,
    });
    return this.anomalyRepository.findOne({ where: { id } });
  }

  // ==================== DASHBOARD ====================

  async getDashboard() {
    const [checksSummary, anomaliesSummary, rules] = await Promise.all([
      this.getChecksSummary(),
      this.getAnomaliesSummary(),
      this.getActiveRules(),
    ]);

    return {
      checks: checksSummary,
      anomalies: anomaliesSummary,
      rules_count: rules.length,
    };
  }
}

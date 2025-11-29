import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual } from 'typeorm';
import { JobExecution } from '../../database/entities';
import { PaginationDto } from '../../common/dto';

@Injectable()
export class EtlService {
  constructor(
    @InjectRepository(JobExecution)
    private jobRepository: Repository<JobExecution>,
  ) {}

  async getJobs(pagination: PaginationDto, status?: string) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const where: Record<string, unknown> = {};
    if (status) {
      where.status = status.toUpperCase();
    }

    const [data, total] = await this.jobRepository.findAndCount({
      where,
      order: { startTime: 'DESC' },
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

  async getJobById(id: number) {
    return this.jobRepository.findOne({ where: { id } });
  }

  async getRunningJobs() {
    return this.jobRepository.find({
      where: { status: 'RUNNING' },
      order: { startTime: 'DESC' },
    });
  }

  async getFailedJobs(pagination: PaginationDto) {
    const { page = 1, limit = 50 } = pagination;
    const skip = (page - 1) * limit;

    const [data, total] = await this.jobRepository.findAndCount({
      where: { status: 'FAILED' },
      order: { startTime: 'DESC' },
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

  async getJobsByLayer(layer: string) {
    return this.jobRepository.find({
      where: { targetLayer: layer.toUpperCase() },
      order: { startTime: 'DESC' },
      take: 100,
    });
  }

  async getJobStats() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const [
      totalJobs,
      runningJobs,
      todaySuccess,
      todayFailed,
      weekStats,
      lastJob,
      avgDuration,
    ] = await Promise.all([
      this.jobRepository.count(),
      this.jobRepository.count({ where: { status: 'RUNNING' } }),
      this.jobRepository.count({
        where: { status: 'SUCCESS', startTime: MoreThanOrEqual(today) },
      }),
      this.jobRepository.count({
        where: { status: 'FAILED', startTime: MoreThanOrEqual(today) },
      }),
      this.jobRepository
        .createQueryBuilder('j')
        .select([
          'j.status',
          'COUNT(*) AS count',
          'SUM(j.rows_inserted) AS total_inserts',
          'SUM(j.rows_updated) AS total_updates',
        ])
        .where('j.start_time >= :date', { date: sevenDaysAgo })
        .groupBy('j.status')
        .getRawMany(),
      this.jobRepository.find({
        order: { startTime: 'DESC' },
        take: 1,
      }).then(results => results[0] || null),
      this.jobRepository
        .createQueryBuilder('j')
        .select(
          'AVG(EXTRACT(EPOCH FROM (j.end_time - j.start_time)))',
          'avg_seconds',
        )
        .where('j.end_time IS NOT NULL')
        .andWhere('j.start_time >= :date', { date: sevenDaysAgo })
        .getRawOne(),
    ]);

    return {
      total_jobs: totalJobs,
      running: runningJobs,
      today: {
        success: todaySuccess,
        failed: todayFailed,
        total: todaySuccess + todayFailed,
      },
      last_7_days: weekStats.reduce(
        (acc, item) => {
          const status = (item.j_status || item.status || 'unknown').toLowerCase();
          acc[status] = {
            count: parseInt(item.count) || 0,
            inserts: parseInt(item.total_inserts) || 0,
            updates: parseInt(item.total_updates) || 0,
          };
          return acc;
        },
        {} as Record<string, { count: number; inserts: number; updates: number }>,
      ),
      last_job: lastJob,
      avg_duration_seconds: parseFloat(avgDuration?.avg_seconds) || 0,
    };
  }

  async getJobHistory(jobName: string, days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.jobRepository.find({
      where: {
        jobName,
        startTime: MoreThanOrEqual(startDate),
      },
      order: { startTime: 'DESC' },
    });
  }

  async getLayerStats() {
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const stats = await this.jobRepository
      .createQueryBuilder('j')
      .select([
        'j.target_layer AS layer',
        'COUNT(*) AS total_jobs',
        'COUNT(CASE WHEN j.status = \'SUCCESS\' THEN 1 END) AS success',
        'COUNT(CASE WHEN j.status = \'FAILED\' THEN 1 END) AS failed',
        'SUM(j.rows_inserted) AS total_inserts',
        'SUM(j.rows_updated) AS total_updates',
        'MAX(j.start_time) AS last_run',
      ])
      .where('j.start_time >= :date', { date: sevenDaysAgo })
      .groupBy('j.target_layer')
      .getRawMany();

    return stats.map((s) => ({
      layer: s.layer,
      total_jobs: parseInt(s.total_jobs),
      success: parseInt(s.success),
      failed: parseInt(s.failed),
      success_rate:
        parseInt(s.total_jobs) > 0
          ? ((parseInt(s.success) / parseInt(s.total_jobs)) * 100).toFixed(1)
          : 0,
      total_inserts: parseInt(s.total_inserts) || 0,
      total_updates: parseInt(s.total_updates) || 0,
      last_run: s.last_run,
    }));
  }

  async getDashboard() {
    const [stats, layerStats, runningJobs] = await Promise.all([
      this.getJobStats(),
      this.getLayerStats(),
      this.getRunningJobs(),
    ]);

    return {
      ...stats,
      layers: layerStats,
      running_jobs: runningJobs,
    };
  }
}

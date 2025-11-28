import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { EtlService } from './etl.service';
import { PaginationDto } from '../../common/dto';

@ApiTags('etl')
@Controller('api/etl')
export class EtlController {
  constructor(private readonly etlService: EtlService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Dashboard ETL' })
  @ApiResponse({ status: 200, description: 'Vue d\'ensemble ETL' })
  async getDashboard() {
    return this.etlService.getDashboard();
  }

  @Get('stats')
  @ApiOperation({ summary: 'Statistiques des jobs ETL' })
  @ApiResponse({ status: 200, description: 'Stats des jobs' })
  async getJobStats() {
    return this.etlService.getJobStats();
  }

  @Get('jobs')
  @ApiOperation({ summary: 'Liste des jobs ETL' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, description: 'RUNNING, SUCCESS, FAILED, WARNING' })
  @ApiResponse({ status: 200, description: 'Liste des jobs' })
  async getJobs(
    @Query() pagination: PaginationDto,
    @Query('status') status?: string,
  ) {
    return this.etlService.getJobs(pagination, status);
  }

  @Get('jobs/running')
  @ApiOperation({ summary: 'Jobs en cours d\'exécution' })
  @ApiResponse({ status: 200, description: 'Jobs running' })
  async getRunningJobs() {
    return this.etlService.getRunningJobs();
  }

  @Get('jobs/failed')
  @ApiOperation({ summary: 'Jobs en échec' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Jobs failed' })
  async getFailedJobs(@Query() pagination: PaginationDto) {
    return this.etlService.getFailedJobs(pagination);
  }

  @Get('jobs/:id')
  @ApiOperation({ summary: 'Détail d\'un job' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Détail du job' })
  async getJobById(@Param('id', ParseIntPipe) id: number) {
    return this.etlService.getJobById(id);
  }

  @Get('jobs/history/:jobName')
  @ApiOperation({ summary: 'Historique d\'un job' })
  @ApiParam({ name: 'jobName', description: 'Nom du job' })
  @ApiQuery({ name: 'days', required: false, type: Number, description: 'Nombre de jours (défaut: 30)' })
  @ApiResponse({ status: 200, description: 'Historique du job' })
  async getJobHistory(
    @Param('jobName') jobName: string,
    @Query('days') days?: number,
  ) {
    return this.etlService.getJobHistory(jobName, days || 30);
  }

  @Get('layers')
  @ApiOperation({ summary: 'Stats par couche' })
  @ApiResponse({ status: 200, description: 'Stats BRONZE, SILVER, GOLD' })
  async getLayerStats() {
    return this.etlService.getLayerStats();
  }

  @Get('layers/:layer')
  @ApiOperation({ summary: 'Jobs d\'une couche' })
  @ApiParam({ name: 'layer', description: 'BRONZE, SILVER, GOLD' })
  @ApiResponse({ status: 200, description: 'Jobs de la couche' })
  async getJobsByLayer(@Param('layer') layer: string) {
    return this.etlService.getJobsByLayer(layer);
  }
}

import {
  Controller,
  Get,
  Param,
  Query,
  Patch,
  Body,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { DataQualityService } from './data-quality.service';
import { PaginationDto } from '../../common/dto';

@ApiTags('data-quality')
@Controller('data-quality')
export class DataQualityController {
  constructor(private readonly dataQualityService: DataQualityService) {}

  // ==================== DASHBOARD ====================

  @Get('dashboard')
  @ApiOperation({ summary: 'Dashboard qualité des données' })
  @ApiResponse({ status: 200, description: 'Vue d\'ensemble qualité' })
  async getDashboard() {
    return this.dataQualityService.getDashboard();
  }

  // ==================== RULES ====================

  @Get('rules')
  @ApiOperation({ summary: 'Toutes les règles de qualité' })
  @ApiResponse({ status: 200, description: 'Liste des règles' })
  async getRules() {
    return this.dataQualityService.getRules();
  }

  @Get('rules/active')
  @ApiOperation({ summary: 'Règles actives uniquement' })
  @ApiResponse({ status: 200, description: 'Liste des règles actives' })
  async getActiveRules() {
    return this.dataQualityService.getActiveRules();
  }

  @Get('rules/layer/:layer')
  @ApiOperation({ summary: 'Règles par couche' })
  @ApiParam({ name: 'layer', description: 'BRONZE, SILVER, GOLD' })
  @ApiResponse({ status: 200, description: 'Règles de la couche' })
  async getRulesByLayer(@Param('layer') layer: string) {
    return this.dataQualityService.getRulesByLayer(layer);
  }

  // ==================== CHECKS ====================

  @Get('checks')
  @ApiOperation({ summary: 'Derniers contrôles exécutés' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste des contrôles' })
  async getLatestChecks(@Query() pagination: PaginationDto) {
    return this.dataQualityService.getLatestChecks(pagination);
  }

  @Get('checks/summary')
  @ApiOperation({ summary: 'Synthèse des contrôles' })
  @ApiResponse({ status: 200, description: 'Stats des contrôles' })
  async getChecksSummary() {
    return this.dataQualityService.getChecksSummary();
  }

  @Get('checks/failed')
  @ApiOperation({ summary: 'Contrôles en échec' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste des échecs' })
  async getFailedChecks(@Query() pagination: PaginationDto) {
    return this.dataQualityService.getFailedChecks(pagination);
  }

  // ==================== ANOMALIES ====================

  @Get('anomalies')
  @ApiOperation({ summary: 'Toutes les anomalies détectées' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'severity', required: false, description: 'INFO, WARNING, ERROR, CRITICAL' })
  @ApiResponse({ status: 200, description: 'Liste des anomalies' })
  async getAnomalies(
    @Query() pagination: PaginationDto,
    @Query('severity') severity?: string,
  ) {
    return this.dataQualityService.getAnomalies(pagination, severity);
  }

  @Get('anomalies/summary')
  @ApiOperation({ summary: 'Synthèse des anomalies' })
  @ApiResponse({ status: 200, description: 'Stats des anomalies' })
  async getAnomaliesSummary() {
    return this.dataQualityService.getAnomaliesSummary();
  }

  @Get('anomalies/unresolved')
  @ApiOperation({ summary: 'Anomalies non résolues' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Anomalies ouvertes' })
  async getUnresolvedAnomalies(@Query() pagination: PaginationDto) {
    return this.dataQualityService.getUnresolvedAnomalies(pagination);
  }

  @Get('anomalies/layer/:layer')
  @ApiOperation({ summary: 'Anomalies par couche' })
  @ApiParam({ name: 'layer', description: 'BRONZE, SILVER, GOLD' })
  @ApiResponse({ status: 200, description: 'Anomalies de la couche' })
  async getAnomaliesByLayer(@Param('layer') layer: string) {
    return this.dataQualityService.getAnomaliesByLayer(layer);
  }

  @Patch('anomalies/:id/resolve')
  @ApiOperation({ summary: 'Marquer une anomalie comme résolue' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Anomalie mise à jour' })
  async resolveAnomaly(
    @Param('id', ParseIntPipe) id: number,
    @Body('comment') comment: string,
  ) {
    return this.dataQualityService.resolveAnomaly(id, comment);
  }
}

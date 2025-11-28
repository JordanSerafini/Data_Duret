import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { KpiService } from './kpi.service';
import { PeriodeFilterDto } from '../../common/dto';

@ApiTags('kpi')
@Controller('api/kpi')
export class KpiController {
  constructor(private readonly kpiService: KpiService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Tableau de bord direction avec tous les KPIs' })
  @ApiResponse({ status: 200, description: 'KPIs du dashboard direction' })
  async getDashboard(@Query() filter: PeriodeFilterDto) {
    return this.kpiService.getDashboard(filter);
  }

  @Get('summary')
  @ApiOperation({ summary: 'Résumé consolidé des KPIs les plus récents' })
  @ApiResponse({ status: 200, description: 'Résumé des KPIs' })
  async getSummary() {
    return this.kpiService.getSummary();
  }

  @Get('latest')
  @ApiOperation({ summary: 'KPIs de la dernière période disponible' })
  @ApiResponse({ status: 200, description: 'Derniers KPIs' })
  async getLatestKpis() {
    return this.kpiService.getLatestKpis();
  }

  @Get('evolution')
  @ApiOperation({ summary: 'Évolution des KPIs dans le temps' })
  @ApiQuery({ name: 'annee', required: false, type: Number })
  @ApiQuery({ name: 'societeId', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Évolution temporelle des KPIs' })
  async getEvolution(@Query() filter: PeriodeFilterDto) {
    return this.kpiService.getEvolution(filter);
  }

  @Get('societes')
  @ApiOperation({ summary: 'Liste des sociétés disponibles' })
  @ApiResponse({ status: 200, description: 'Liste des sociétés' })
  async getSocietes() {
    return this.kpiService.getSocietes();
  }

  @Get('societe/:id')
  @ApiOperation({ summary: 'KPIs détaillés pour une société' })
  @ApiParam({ name: 'id', type: Number, description: 'ID de la société' })
  @ApiResponse({ status: 200, description: 'KPIs de la société' })
  async getKpisBySociete(
    @Param('id', ParseIntPipe) id: number,
    @Query() filter: PeriodeFilterDto,
  ) {
    return this.kpiService.getKpisBySociete(id, filter);
  }
}

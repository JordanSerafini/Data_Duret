import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { CommercialService } from './commercial.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@ApiTags('commercial')
@Controller('commercial')
export class CommercialController {
  constructor(private readonly commercialService: CommercialService) {}

  // ==================== CA ====================

  @Get('ca')
  @ApiOperation({ summary: 'CA par période (mois, trimestre, année)' })
  @ApiResponse({ status: 200, description: 'CA agrégé par période' })
  async getCaByPeriode(@Query() filter: PeriodeFilterDto) {
    return this.commercialService.getCaByPeriode(filter);
  }

  @Get('ca/evolution')
  @ApiOperation({ summary: 'Évolution du CA dans le temps' })
  @ApiResponse({ status: 200, description: 'Évolution mensuelle du CA' })
  async getCaEvolution(@Query() filter: PeriodeFilterDto) {
    return this.commercialService.getCaEvolution(filter);
  }

  @Get('ca/forecast')
  @ApiOperation({ summary: 'Prévision CA 3 mois (régression linéaire)' })
  @ApiResponse({ status: 200, description: 'Prévision avec historique et tendance' })
  async getCaForecast(@Query() filter: PeriodeFilterDto) {
    return this.commercialService.getCaForecast(filter);
  }

  @Get('segments')
  @ApiOperation({ summary: 'Liste des segments de CA' })
  @ApiResponse({ status: 200, description: 'Liste des segments' })
  async getSegments() {
    return this.commercialService.getSegments();
  }

  // ==================== CLIENTS ====================

  @Get('clients')
  @ApiOperation({ summary: 'Liste des clients avec KPIs' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste paginée des clients' })
  async getClients(
    @Query() filter: PeriodeFilterDto,
    @Query() pagination: PaginationDto,
  ) {
    return this.commercialService.getClients(filter, pagination);
  }

  @Get('clients/top')
  @ApiOperation({ summary: 'Top clients par CA' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Nombre de clients (défaut: 10)' })
  @ApiResponse({ status: 200, description: 'Top clients' })
  async getTopClients(
    @Query() filter: PeriodeFilterDto,
    @Query('limit') limit?: number,
  ) {
    return this.commercialService.getTopClients(filter, limit || 10);
  }

  @Get('clients/:id')
  @ApiOperation({ summary: 'Détail d\'un client' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Détail du client avec historique CA' })
  async getClientById(
    @Param('id', ParseIntPipe) id: number,
    @Query() filter: PeriodeFilterDto,
  ) {
    return this.commercialService.getClientById(id, filter);
  }

  // ==================== AFFAIRES ====================

  @Get('affaires')
  @ApiOperation({ summary: 'Liste des affaires avec KPIs' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste paginée des affaires' })
  async getAffaires(
    @Query() filter: PeriodeFilterDto,
    @Query() pagination: PaginationDto,
  ) {
    return this.commercialService.getAffaires(filter, pagination);
  }

  @Get('affaires/retard')
  @ApiOperation({ summary: 'Affaires en retard' })
  @ApiResponse({ status: 200, description: 'Liste des affaires en retard' })
  async getAffairesEnRetard(@Query() filter: PeriodeFilterDto) {
    return this.commercialService.getAffairesEnRetard(filter);
  }

  @Get('affaires/depassement')
  @ApiOperation({ summary: 'Affaires en dépassement de budget' })
  @ApiResponse({ status: 200, description: 'Liste des affaires en dépassement' })
  async getAffairesEnDepassement(@Query() filter: PeriodeFilterDto) {
    return this.commercialService.getAffairesEnDepassement(filter);
  }

  @Get('affaires/:id')
  @ApiOperation({ summary: 'Détail d\'une affaire' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Détail de l\'affaire' })
  async getAffaireById(@Param('id', ParseIntPipe) id: number) {
    return this.commercialService.getAffaireById(id);
  }
}

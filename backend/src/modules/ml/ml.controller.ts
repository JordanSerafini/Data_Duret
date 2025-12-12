import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { MlService } from './ml.service';
import { PaginationDto } from '../../common/dto';

@ApiTags('ml')
@Controller('ml')
export class MlController {
  constructor(private readonly mlService: MlService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Statistiques globales ML' })
  @ApiResponse({ status: 200, description: 'Stats clients et affaires' })
  async getStatistiquesML() {
    return this.mlService.getStatistiquesML();
  }

  // ==================== CLIENTS ====================

  @Get('clients/segmentation')
  @ApiOperation({ summary: 'Segmentation RFM des clients' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste des clients avec segmentation' })
  async getClientSegmentation(@Query() pagination: PaginationDto) {
    return this.mlService.getClientSegmentation(pagination);
  }

  @Get('clients/segmentation/synthese')
  @ApiOperation({ summary: 'Synthèse de la segmentation' })
  @ApiResponse({ status: 200, description: 'Stats par segment' })
  async getSegmentationSynthese() {
    return this.mlService.getSegmentationSynthese();
  }

  @Get('clients/segment/:segment')
  @ApiOperation({ summary: 'Clients d\'un segment' })
  @ApiParam({ name: 'segment', description: 'VIP, PREMIUM, STANDARD, PETIT' })
  @ApiResponse({ status: 200, description: 'Clients du segment' })
  async getClientsParSegment(
    @Param('segment') segment: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.mlService.getClientsParSegment(segment.toUpperCase(), pagination);
  }

  @Get('clients/churn-risk')
  @ApiOperation({ summary: 'Clients à risque de churn' })
  @ApiQuery({ name: 'seuil', required: false, type: Number, description: 'Seuil probabilité (défaut: 0.3)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Clients avec probabilité churn élevée' })
  async getClientChurnRisk(
    @Query('seuil') seuil: number,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.mlService.getClientChurnRisk(seuil || 0.3, { page, limit });
  }

  @Get('clients/fort-potentiel')
  @ApiOperation({ summary: 'Clients à fort potentiel' })
  @ApiQuery({ name: 'seuil', required: false, type: Number, description: 'Seuil score potentiel (défaut: 70)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Clients avec fort potentiel' })
  async getClientsFortPotentiel(
    @Query('seuil') seuil: number,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.mlService.getClientsFortPotentiel(seuil || 70, { page, limit });
  }

  @Get('clients/:id/features')
  @ApiOperation({ summary: 'Features ML d\'un client' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Détail features du client' })
  async getClientFeatures(@Param('id', ParseIntPipe) id: number) {
    return this.mlService.getClientFeatures(id);
  }

  // ==================== AFFAIRES ====================

  @Get('affaires/predictions')
  @ApiOperation({ summary: 'Prédictions sur les affaires' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Affaires avec prédictions marge' })
  async getAffairePredictions(@Query() pagination: PaginationDto) {
    return this.mlService.getAffairePredictions(pagination);
  }

  @Get('affaires/risque-depassement')
  @ApiOperation({ summary: 'Affaires à risque de dépassement' })
  @ApiQuery({ name: 'seuil', required: false, type: Number, description: 'Seuil score (défaut: 50)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Affaires à risque' })
  async getAffairesRisqueDepassement(
    @Query('seuil') seuil: number,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.mlService.getAffairesRisqueDepassement(seuil || 50, { page, limit });
  }

  @Get('affaires/:id/features')
  @ApiOperation({ summary: 'Features ML d\'une affaire' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Détail features de l\'affaire' })
  async getAffaireFeatures(@Param('id', ParseIntPipe) id: number) {
    return this.mlService.getAffaireFeatures(id);
  }
}

import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AnomaliesService } from './anomalies.service';
import { PeriodeFilterDto } from '../../common/dto';

@ApiTags('anomalies')
@Controller('api/anomalies')
export class AnomaliesController {
  constructor(private readonly anomaliesService: AnomaliesService) {}

  @Get()
  @ApiOperation({ summary: 'Toutes les anomalies détectées' })
  @ApiResponse({ status: 200, description: 'Liste des anomalies triées par sévérité' })
  async getAllAnomalies(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getAllAnomalies(filter);
  }

  @Get('synthese')
  @ApiOperation({ summary: 'Synthèse des anomalies' })
  @ApiResponse({ status: 200, description: 'Comptage par sévérité et catégorie' })
  async getSynthese(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getSynthese(filter);
  }

  @Get('ecarts-budget')
  @ApiOperation({ summary: 'Affaires en dépassement de budget' })
  @ApiResponse({ status: 200, description: 'Liste des écarts budgétaires' })
  async getEcartsBudget(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getEcartsBudget(filter);
  }

  @Get('retards')
  @ApiOperation({ summary: 'Affaires en retard' })
  @ApiResponse({ status: 200, description: 'Liste des affaires en retard' })
  async getAffairesRetard(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getAffairesRetard(filter);
  }

  @Get('impayes')
  @ApiOperation({ summary: 'Clients avec impayés' })
  @ApiResponse({ status: 200, description: 'Liste des impayés par client' })
  async getImpayes(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getImpayes(filter);
  }

  @Get('risque-credit')
  @ApiOperation({ summary: 'Clients à risque crédit élevé' })
  @ApiResponse({ status: 200, description: 'Liste des clients à risque' })
  async getRisqueCredit(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getRisqueCredit(filter);
  }

  @Get('stock')
  @ApiOperation({ summary: 'Alertes stock (ruptures et surstocks)' })
  @ApiResponse({ status: 200, description: 'Liste des alertes stock' })
  async getAlertesStock(@Query() filter: PeriodeFilterDto) {
    return this.anomaliesService.getAlertesStock(filter);
  }
}

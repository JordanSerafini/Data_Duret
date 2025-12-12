import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { TresorerieService } from './tresorerie.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@ApiTags('tresorerie')
@Controller('tresorerie')
export class TresorerieController {
  constructor(private readonly tresorerieService: TresorerieService) {}

  @Get('solde')
  @ApiOperation({ summary: 'Solde de trésorerie' })
  @ApiResponse({ status: 200, description: 'Solde et flux de trésorerie' })
  async getSolde(@Query() filter: PeriodeFilterDto) {
    return this.tresorerieService.getSolde(filter);
  }

  @Get('evolution')
  @ApiOperation({ summary: 'Évolution de la trésorerie' })
  @ApiResponse({ status: 200, description: 'Évolution mensuelle' })
  async getEvolution(@Query() filter: PeriodeFilterDto) {
    return this.tresorerieService.getEvolution(filter);
  }

  @Get('bfr')
  @ApiOperation({ summary: 'BFR - Besoin en Fonds de Roulement' })
  @ApiResponse({ status: 200, description: 'BFR par période' })
  async getBfr(@Query() filter: PeriodeFilterDto) {
    return this.tresorerieService.getBfr(filter);
  }

  @Get('balance-agee')
  @ApiOperation({ summary: 'Balance âgée par client' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Balance âgée paginée' })
  async getBalanceAgee(
    @Query() filter: PeriodeFilterDto,
    @Query() pagination: PaginationDto,
  ) {
    return this.tresorerieService.getBalanceAgee(filter, pagination);
  }

  @Get('balance-agee/synthese')
  @ApiOperation({ summary: 'Synthèse de la balance âgée' })
  @ApiResponse({ status: 200, description: 'Totaux par tranche d\'âge' })
  async getBalanceAgeeSynthese(@Query() filter: PeriodeFilterDto) {
    return this.tresorerieService.getBalanceAgeeSynthese(filter);
  }

  @Get('risque-credit')
  @ApiOperation({ summary: 'Clients à risque crédit élevé' })
  @ApiQuery({ name: 'seuil', required: false, type: Number, description: 'Seuil de risque (défaut: 60)' })
  @ApiResponse({ status: 200, description: 'Liste des clients à risque' })
  async getClientsRisqueCredit(
    @Query() filter: PeriodeFilterDto,
    @Query('seuil') seuil?: number,
  ) {
    return this.tresorerieService.getClientsRisqueCredit(filter, seuil || 60);
  }
}

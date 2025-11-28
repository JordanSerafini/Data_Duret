import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { StockService } from './stock.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

import { StockFilterDto } from './dto/stock-filter.dto';

@ApiTags('stock')
@Controller('api/stock')
export class StockController {
  constructor(private readonly stockService: StockService) {}

  @Get('')
  @ApiOperation({ summary: 'Liste des stocks avec filtres et pagination' })
  @ApiResponse({ status: 200, description: 'Liste paginée des stocks' })
  async getStocks(@Query() filter: StockFilterDto) {
    return this.stockService.findAll(filter);
  }

  @Get('familles')
  @ApiOperation({ summary: 'Liste des familles d\'articles' })
  @ApiResponse({ status: 200, description: 'Liste des familles' })
  async getFamilles() {
    return this.stockService.getFamilles();
  }

  @Get('alertes')
  @ApiOperation({ summary: 'Toutes les alertes stock (ruptures + surstocks)' })
  @ApiResponse({ status: 200, description: 'Liste des alertes' })
  async getAlertes(@Query() filter: PeriodeFilterDto) {
    return this.stockService.getAlertes(filter);
  }

  @Get('alertes/rupture')
  @ApiOperation({ summary: 'Articles en rupture imminente' })
  @ApiResponse({ status: 200, description: 'Articles sous stock minimum' })
  async getAlertesRupture(@Query() filter: PeriodeFilterDto) {
    return this.stockService.getAlertesRupture(filter);
  }

  @Get('alertes/surstock')
  @ApiOperation({ summary: 'Articles en surstock' })
  @ApiResponse({ status: 200, description: 'Articles en surstock' })
  async getAlertesSurstock(@Query() filter: PeriodeFilterDto) {
    return this.stockService.getAlertesSurstock(filter);
  }

  @Get('rotation')
  @ApiOperation({ summary: 'Rotation des stocks par article' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Rotation des stocks paginée' })
  async getRotation(
    @Query() filter: PeriodeFilterDto,
    @Query() pagination: PaginationDto,
  ) {
    return this.stockService.getRotation(filter, pagination);
  }

  @Get('synthese')
  @ApiOperation({ summary: 'Synthèse globale des stocks' })
  @ApiResponse({ status: 200, description: 'Valeur totale et indicateurs' })
  async getSynthese(@Query() filter: PeriodeFilterDto) {
    return this.stockService.getSynthese(filter);
  }

  @Get('valeur-famille')
  @ApiOperation({ summary: 'Valeur stock par famille d\'articles' })
  @ApiResponse({ status: 200, description: 'Répartition par famille' })
  async getValeurParFamille(@Query() filter: PeriodeFilterDto) {
    return this.stockService.getValeurParFamille(filter);
  }
}

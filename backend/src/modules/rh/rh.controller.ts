import { Controller, Get, Param, Query, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { RhService } from './rh.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';

@ApiTags('rh')
@Controller('api/rh')
export class RhController {
  constructor(private readonly rhService: RhService) {}

  @Get('productivite')
  @ApiOperation({ summary: 'Productivité des salariés' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Liste des salariés avec productivité' })
  async getProductivite(
    @Query() filter: PeriodeFilterDto,
    @Query() pagination: PaginationDto,
  ) {
    return this.rhService.getProductivite(filter, pagination);
  }

  @Get('synthese')
  @ApiOperation({ summary: 'Synthèse mensuelle RH' })
  @ApiResponse({ status: 200, description: 'Synthèse des heures et coûts' })
  async getSyntheseMensuelle(@Query() filter: PeriodeFilterDto) {
    return this.rhService.getSyntheseMensuelle(filter);
  }

  @Get('top-productifs')
  @ApiOperation({ summary: 'Top salariés les plus productifs' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Top salariés' })
  async getTopProductifs(
    @Query() filter: PeriodeFilterDto,
    @Query('limit') limit?: number,
  ) {
    return this.rhService.getTopProductifs(filter, limit || 10);
  }

  @Get('sous-occupes')
  @ApiOperation({ summary: 'Salariés sous-occupés' })
  @ApiQuery({ name: 'seuil', required: false, type: Number, description: 'Seuil occupation (défaut: 70%)' })
  @ApiResponse({ status: 200, description: 'Salariés avec taux d\'occupation faible' })
  async getSalariesSousOccupes(
    @Query() filter: PeriodeFilterDto,
    @Query('seuil') seuil?: number,
  ) {
    return this.rhService.getSalariesSousOccupes(filter, seuil || 70);
  }



  @Get('postes')
  @ApiOperation({ summary: 'Liste des postes' })
  @ApiResponse({ status: 200, description: 'Liste des postes' })
  async getPostes() {
    return this.rhService.getPostes();
  }

  @Get('qualifications')
  @ApiOperation({ summary: 'Liste des qualifications' })
  @ApiResponse({ status: 200, description: 'Liste des qualifications' })
  async getQualifications() {
    return this.rhService.getQualifications();
  }

  @Get('synthese-mensuelle')
  @ApiOperation({ summary: 'Détail heures d\'un salarié' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Historique heures du salarié' })
  async getHeuresParSalarie(
    @Param('id', ParseIntPipe) id: number,
    @Query() filter: PeriodeFilterDto,
  ) {
    return this.rhService.getHeuresParSalarie(id, filter);
  }
}

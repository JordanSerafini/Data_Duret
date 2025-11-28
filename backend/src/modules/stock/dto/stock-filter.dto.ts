import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsEnum, IsInt } from 'class-validator';
import { PaginationDto } from '../../../common/dto';

export enum SortOrder {
  ASC = 'ASC',
  DESC = 'DESC',
}

export class StockFilterDto extends PaginationDto {
  @ApiPropertyOptional({ description: 'Recherche par code ou désignation' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Filtrer par famille' })
  @IsOptional()
  @IsString()
  famille?: string;

  @ApiPropertyOptional({ description: 'Champ de tri', default: 'valeur_stock' })
  @IsOptional()
  @IsString()
  sortField?: string;

  @ApiPropertyOptional({ enum: SortOrder, description: 'Ordre de tri', default: SortOrder.DESC })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder;

  @ApiPropertyOptional({ description: 'ID Société' })
  @IsOptional()
  @IsInt()
  societeId?: number;
}

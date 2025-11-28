import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsInt, Min, Max, IsEnum } from 'class-validator';
import { Transform } from 'class-transformer';

export enum NiveauAgregation {
  JOUR = 'JOUR',
  SEMAINE = 'SEMAINE',
  MOIS = 'MOIS',
  TRIMESTRE = 'TRIMESTRE',
  ANNEE = 'ANNEE',
}

export class PeriodeFilterDto {
  @ApiPropertyOptional({ description: 'Année', example: 2024 })
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(2020)
  @Max(2030)
  annee?: number;

  @ApiPropertyOptional({ description: 'Mois (1-12)', example: 6 })
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  @Max(12)
  mois?: number;

  @ApiPropertyOptional({ description: 'Trimestre (1-4)', example: 2 })
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  @Max(4)
  trimestre?: number;

  @ApiPropertyOptional({ description: 'ID Société', example: 1 })
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  societeId?: number;

  @ApiPropertyOptional({
    enum: NiveauAgregation,
    description: "Niveau d'agrégation",
  })
  @IsOptional()
  @IsEnum(NiveauAgregation)
  niveau?: NiveauAgregation;
}

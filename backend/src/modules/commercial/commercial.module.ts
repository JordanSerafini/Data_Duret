import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommercialController } from './commercial.controller';
import { CommercialService } from './commercial.service';
import {
  AggCaPeriode,
  AggCaClient,
  AggCaAffaire,
  DimClient,
  DimAffaire,
} from '../../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AggCaPeriode,
      AggCaClient,
      AggCaAffaire,
      DimClient,
      DimAffaire,
    ]),
  ],
  controllers: [CommercialController],
  providers: [CommercialService],
  exports: [CommercialService],
})
export class CommercialModule {}

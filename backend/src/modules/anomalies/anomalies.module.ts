import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AnomaliesController } from './anomalies.controller';
import { AnomaliesService } from './anomalies.service';
import {
  AggCaAffaire,
  AggCaClient,
  AggBalanceAgeeClient,
  AggStockElement,
  AggHeuresSalarie,
  DimAffaire,
  DimClient,
  DimSalarie,
  MlFeaturesClient,
  MlFeaturesAffaire,
} from '../../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AggCaAffaire,
      AggCaClient,
      AggBalanceAgeeClient,
      AggStockElement,
      AggHeuresSalarie,
      DimAffaire,
      DimClient,
      DimSalarie,
      MlFeaturesClient,
      MlFeaturesAffaire,
    ]),
  ],
  controllers: [AnomaliesController],
  providers: [AnomaliesService],
  exports: [AnomaliesService],
})
export class AnomaliesModule {}

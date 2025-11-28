import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MlController } from './ml.controller';
import { MlService } from './ml.service';
import { MlFeaturesClient, MlFeaturesAffaire, DimClient, DimAffaire } from '../../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      MlFeaturesClient,
      MlFeaturesAffaire,
      DimClient,
      DimAffaire,
    ]),
  ],
  controllers: [MlController],
  providers: [MlService],
  exports: [MlService],
})
export class MlModule {}

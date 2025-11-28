import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataQualityController } from './data-quality.controller';
import { DataQualityService } from './data-quality.service';
import {
  DataQualityRule,
  DataQualityCheck,
  DataAnomaly,
} from '../../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([DataQualityRule, DataQualityCheck, DataAnomaly]),
  ],
  controllers: [DataQualityController],
  providers: [DataQualityService],
  exports: [DataQualityService],
})
export class DataQualityModule {}

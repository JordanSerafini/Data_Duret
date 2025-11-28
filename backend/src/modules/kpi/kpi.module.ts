import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { KpiController } from './kpi.controller';
import { KpiService } from './kpi.service';
import { KpiGlobal, DimSociete } from '../../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([KpiGlobal, DimSociete])],
  controllers: [KpiController],
  providers: [KpiService],
  exports: [KpiService],
})
export class KpiModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RhController } from './rh.controller';
import { RhService } from './rh.service';
import { AggHeuresSalarie, DimSalarie } from '../../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([AggHeuresSalarie, DimSalarie])],
  controllers: [RhController],
  providers: [RhService],
  exports: [RhService],
})
export class RhModule {}

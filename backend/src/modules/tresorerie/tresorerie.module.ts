import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TresorerieController } from './tresorerie.controller';
import { TresorerieService } from './tresorerie.service';
import { AggTresorerie, AggBalanceAgeeClient, DimClient } from '../../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([AggTresorerie, AggBalanceAgeeClient, DimClient])],
  controllers: [TresorerieController],
  providers: [TresorerieService],
  exports: [TresorerieService],
})
export class TresorerieModule {}

import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StockController } from './stock.controller';
import { StockService } from './stock.service';
import { AggStockElement, DimElement } from '../../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([AggStockElement, DimElement])],
  controllers: [StockController],
  providers: [StockService],
  exports: [StockService],
})
export class StockModule {}

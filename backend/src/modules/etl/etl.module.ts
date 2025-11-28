import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EtlController } from './etl.controller';
import { EtlService } from './etl.service';
import { JobExecution } from '../../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([JobExecution])],
  controllers: [EtlController],
  providers: [EtlService],
  exports: [EtlService],
})
export class EtlModule {}

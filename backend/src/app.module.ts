import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { KpiModule } from './modules/kpi/kpi.module';
import { CommercialModule } from './modules/commercial/commercial.module';
import { TresorerieModule } from './modules/tresorerie/tresorerie.module';
import { RhModule } from './modules/rh/rh.module';
import { StockModule } from './modules/stock/stock.module';
import { AnomaliesModule } from './modules/anomalies/anomalies.module';
import { MlModule } from './modules/ml/ml.module';
import { DataQualityModule } from './modules/data-quality/data-quality.module';
import { EtlModule } from './modules/etl/etl.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Database - DWH Groupe DURET
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST', 'localhost'),
        port: configService.get<number>('DB_PORT', 5432),
        username: configService.get('DB_USERNAME', 'postgres'),
        password: configService.get('DB_PASSWORD', 'postgres'),
        database: configService.get('DB_DATABASE', 'dwh_groupe_duret'),
        entities: [__dirname + '/database/entities/**/*.entity{.ts,.js}'],
        synchronize: false, // Never sync in production with existing DB
        logging: configService.get('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),

    // Feature Modules
    KpiModule,
    CommercialModule,
    TresorerieModule,
    RhModule,
    StockModule,
    AnomaliesModule,
    MlModule,
    DataQualityModule,
    EtlModule,
  ],
})
export class AppModule {}

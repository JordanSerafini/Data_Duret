"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const kpi_module_1 = require("./modules/kpi/kpi.module");
const commercial_module_1 = require("./modules/commercial/commercial.module");
const tresorerie_module_1 = require("./modules/tresorerie/tresorerie.module");
const rh_module_1 = require("./modules/rh/rh.module");
const stock_module_1 = require("./modules/stock/stock.module");
const anomalies_module_1 = require("./modules/anomalies/anomalies.module");
const ml_module_1 = require("./modules/ml/ml.module");
const data_quality_module_1 = require("./modules/data-quality/data-quality.module");
const etl_module_1 = require("./modules/etl/etl.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                envFilePath: '.env',
            }),
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_1.ConfigModule],
                useFactory: (configService) => ({
                    type: 'postgres',
                    host: configService.get('DB_HOST', 'localhost'),
                    port: configService.get('DB_PORT', 5432),
                    username: configService.get('DB_USERNAME', 'postgres'),
                    password: configService.get('DB_PASSWORD', 'postgres'),
                    database: configService.get('DB_DATABASE', 'mde_erp'),
                    entities: [__dirname + '/database/entities/**/*.entity{.ts,.js}'],
                    synchronize: false,
                    logging: configService.get('NODE_ENV') === 'development',
                }),
                inject: [config_1.ConfigService],
            }),
            kpi_module_1.KpiModule,
            commercial_module_1.CommercialModule,
            tresorerie_module_1.TresorerieModule,
            rh_module_1.RhModule,
            stock_module_1.StockModule,
            anomalies_module_1.AnomaliesModule,
            ml_module_1.MlModule,
            data_quality_module_1.DataQualityModule,
            etl_module_1.EtlModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map
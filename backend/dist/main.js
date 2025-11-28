"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const app_module_1 = require("./app.module");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
    }));
    app.enableCors({
        origin: '*',
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
        credentials: true,
    });
    const config = new swagger_1.DocumentBuilder()
        .setTitle(process.env.SWAGGER_TITLE || 'DWH Groupe DURET API')
        .setDescription(process.env.SWAGGER_DESCRIPTION ||
        'API Backend pour Dashboard KPI, Anomalies et ML')
        .setVersion(process.env.SWAGGER_VERSION || '1.0')
        .addTag('kpi', 'KPIs et Dashboard Direction')
        .addTag('commercial', 'CA, Clients, Affaires')
        .addTag('tresorerie', 'Trésorerie et Balance Âgée')
        .addTag('rh', 'Productivité et Heures')
        .addTag('stock', 'Alertes Stock')
        .addTag('anomalies', 'Détection Anomalies et Erreurs')
        .addTag('ml', 'Machine Learning Features et Prédictions')
        .build();
    const document = swagger_1.SwaggerModule.createDocument(app, config);
    swagger_1.SwaggerModule.setup('api/docs', app, document);
    const port = process.env.PORT || 3000;
    await app.listen(port);
    console.log(`🚀 Application running on: http://localhost:${port}`);
    console.log(`📚 Swagger documentation: http://localhost:${port}/api/docs`);
}
bootstrap();
//# sourceMappingURL=main.js.map
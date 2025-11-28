import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  // CORS
  app.enableCors({
    origin: '*',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    credentials: true,
  });

  // Swagger Configuration
  const config = new DocumentBuilder()
    .setTitle(process.env.SWAGGER_TITLE || 'DWH Groupe DURET API')
    .setDescription(
      process.env.SWAGGER_DESCRIPTION ||
        'API Backend pour Dashboard KPI, Anomalies et ML',
    )
    .setVersion(process.env.SWAGGER_VERSION || '1.0')
    .addTag('kpi', 'KPIs et Dashboard Direction')
    .addTag('commercial', 'CA, Clients, Affaires')
    .addTag('tresorerie', 'Trésorerie et Balance Âgée')
    .addTag('rh', 'Productivité et Heures')
    .addTag('stock', 'Alertes Stock')
    .addTag('anomalies', 'Détection Anomalies et Erreurs')
    .addTag('ml', 'Machine Learning Features et Prédictions')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);

  console.log(`🚀 Application running on: http://localhost:${port}`);
  console.log(`📚 Swagger documentation: http://localhost:${port}/api/docs`);
}

bootstrap();

"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AnomaliesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const anomalies_service_1 = require("./anomalies.service");
const dto_1 = require("../../common/dto");
let AnomaliesController = class AnomaliesController {
    constructor(anomaliesService) {
        this.anomaliesService = anomaliesService;
    }
    async getAllAnomalies(filter) {
        return this.anomaliesService.getAllAnomalies(filter);
    }
    async getSynthese(filter) {
        return this.anomaliesService.getSynthese(filter);
    }
    async getEcartsBudget(filter) {
        return this.anomaliesService.getEcartsBudget(filter);
    }
    async getAffairesRetard(filter) {
        return this.anomaliesService.getAffairesRetard(filter);
    }
    async getImpayes(filter) {
        return this.anomaliesService.getImpayes(filter);
    }
    async getRisqueCredit(filter) {
        return this.anomaliesService.getRisqueCredit(filter);
    }
    async getAlertesStock(filter) {
        return this.anomaliesService.getAlertesStock(filter);
    }
    async getAnomalyPatterns(filter) {
        return this.anomaliesService.getAnomalyPatterns(filter);
    }
    async getRiskHeatmap(filter) {
        return this.anomaliesService.getRiskHeatmap(filter);
    }
    async getAnomalyTrends(filter) {
        return this.anomaliesService.getAnomalyTrends(filter);
    }
};
exports.AnomaliesController = AnomaliesController;
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: 'Toutes les anomalies détectées' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des anomalies triées par sévérité' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getAllAnomalies", null);
__decorate([
    (0, common_1.Get)('synthese'),
    (0, swagger_1.ApiOperation)({ summary: 'Synthèse des anomalies' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Comptage par sévérité et catégorie' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getSynthese", null);
__decorate([
    (0, common_1.Get)('ecarts-budget'),
    (0, swagger_1.ApiOperation)({ summary: 'Affaires en dépassement de budget' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des écarts budgétaires' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getEcartsBudget", null);
__decorate([
    (0, common_1.Get)('retards'),
    (0, swagger_1.ApiOperation)({ summary: 'Affaires en retard' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des affaires en retard' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getAffairesRetard", null);
__decorate([
    (0, common_1.Get)('impayes'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients avec impayés' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des impayés par client' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getImpayes", null);
__decorate([
    (0, common_1.Get)('risque-credit'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients à risque crédit élevé' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des clients à risque' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getRisqueCredit", null);
__decorate([
    (0, common_1.Get)('stock'),
    (0, swagger_1.ApiOperation)({ summary: 'Alertes stock (ruptures et surstocks)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des alertes stock' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getAlertesStock", null);
__decorate([
    (0, common_1.Get)('patterns'),
    (0, swagger_1.ApiOperation)({ summary: 'Détection de patterns d\'anomalies récurrentes' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Patterns identifiés avec corrélations et recommandations' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getAnomalyPatterns", null);
__decorate([
    (0, common_1.Get)('heatmap'),
    (0, swagger_1.ApiOperation)({ summary: 'Heatmap de risque multi-dimensionnelle' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Matrice de risque par catégorie et sévérité' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getRiskHeatmap", null);
__decorate([
    (0, common_1.Get)('trends'),
    (0, swagger_1.ApiOperation)({ summary: 'Analyse des tendances d\'anomalies' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Tendances, projections et actions prioritaires' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], AnomaliesController.prototype, "getAnomalyTrends", null);
exports.AnomaliesController = AnomaliesController = __decorate([
    (0, swagger_1.ApiTags)('anomalies'),
    (0, common_1.Controller)('anomalies'),
    __metadata("design:paramtypes", [anomalies_service_1.AnomaliesService])
], AnomaliesController);
//# sourceMappingURL=anomalies.controller.js.map
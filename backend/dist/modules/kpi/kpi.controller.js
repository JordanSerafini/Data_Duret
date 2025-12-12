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
exports.KpiController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const kpi_service_1 = require("./kpi.service");
const dto_1 = require("../../common/dto");
let KpiController = class KpiController {
    constructor(kpiService) {
        this.kpiService = kpiService;
    }
    async getDashboard(filter) {
        return this.kpiService.getDashboard(filter);
    }
    async getSummary() {
        return this.kpiService.getSummary();
    }
    async getLatestKpis() {
        return this.kpiService.getLatestKpis();
    }
    async getEvolution(filter) {
        return this.kpiService.getEvolution(filter);
    }
    async getSocietes() {
        return this.kpiService.getSocietes();
    }
    async getKpisBySociete(id, filter) {
        return this.kpiService.getKpisBySociete(id, filter);
    }
    async getHealthScore(filter) {
        return this.kpiService.getHealthScore(filter);
    }
    async getDsoDpoAnalysis(filter) {
        return this.kpiService.getDsoDpoAnalysis(filter);
    }
    async getBenchmarkSocietes(filter) {
        return this.kpiService.getBenchmarkSocietes(filter);
    }
};
exports.KpiController = KpiController;
__decorate([
    (0, common_1.Get)('dashboard'),
    (0, swagger_1.ApiOperation)({ summary: 'Tableau de bord direction avec tous les KPIs' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'KPIs du dashboard direction' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getDashboard", null);
__decorate([
    (0, common_1.Get)('summary'),
    (0, swagger_1.ApiOperation)({ summary: 'Résumé consolidé des KPIs les plus récents' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Résumé des KPIs' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getSummary", null);
__decorate([
    (0, common_1.Get)('latest'),
    (0, swagger_1.ApiOperation)({ summary: 'KPIs de la dernière période disponible' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Derniers KPIs' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getLatestKpis", null);
__decorate([
    (0, common_1.Get)('evolution'),
    (0, swagger_1.ApiOperation)({ summary: 'Évolution des KPIs dans le temps' }),
    (0, swagger_1.ApiQuery)({ name: 'annee', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'societeId', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Évolution temporelle des KPIs' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getEvolution", null);
__decorate([
    (0, common_1.Get)('societes'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des sociétés disponibles' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des sociétés' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getSocietes", null);
__decorate([
    (0, common_1.Get)('societe/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'KPIs détaillés pour une société' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number, description: 'ID de la société' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'KPIs de la société' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getKpisBySociete", null);
__decorate([
    (0, common_1.Get)('health-score'),
    (0, swagger_1.ApiOperation)({ summary: 'Score de santé global de l\'entreprise' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Score composite avec détails par dimension' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getHealthScore", null);
__decorate([
    (0, common_1.Get)('dso-dpo'),
    (0, swagger_1.ApiOperation)({ summary: 'Analyse DSO/DPO avec recommandations BFR' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Analyse des délais de paiement et recommandations' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getDsoDpoAnalysis", null);
__decorate([
    (0, common_1.Get)('benchmark'),
    (0, swagger_1.ApiOperation)({ summary: 'Benchmark multi-sociétés' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Comparaison des KPIs entre sociétés du groupe' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], KpiController.prototype, "getBenchmarkSocietes", null);
exports.KpiController = KpiController = __decorate([
    (0, swagger_1.ApiTags)('kpi'),
    (0, common_1.Controller)('kpi'),
    __metadata("design:paramtypes", [kpi_service_1.KpiService])
], KpiController);
//# sourceMappingURL=kpi.controller.js.map
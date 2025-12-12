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
exports.MlController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const ml_service_1 = require("./ml.service");
const dto_1 = require("../../common/dto");
let MlController = class MlController {
    constructor(mlService) {
        this.mlService = mlService;
    }
    async getStatistiquesML() {
        return this.mlService.getStatistiquesML();
    }
    async getClientSegmentation(pagination) {
        return this.mlService.getClientSegmentation(pagination);
    }
    async getSegmentationSynthese() {
        return this.mlService.getSegmentationSynthese();
    }
    async getClientsParSegment(segment, pagination) {
        return this.mlService.getClientsParSegment(segment.toUpperCase(), pagination);
    }
    async getClientChurnRisk(seuil, page, limit) {
        return this.mlService.getClientChurnRisk(seuil || 0.3, { page, limit });
    }
    async getClientsFortPotentiel(seuil, page, limit) {
        return this.mlService.getClientsFortPotentiel(seuil || 70, { page, limit });
    }
    async getClientFeatures(id) {
        return this.mlService.getClientFeatures(id);
    }
    async getAffairePredictions(pagination) {
        return this.mlService.getAffairePredictions(pagination);
    }
    async getAffairesRisqueDepassement(seuil, page, limit) {
        return this.mlService.getAffairesRisqueDepassement(seuil || 50, { page, limit });
    }
    async getAffaireFeatures(id) {
        return this.mlService.getAffaireFeatures(id);
    }
};
exports.MlController = MlController;
__decorate([
    (0, common_1.Get)('stats'),
    (0, swagger_1.ApiOperation)({ summary: 'Statistiques globales ML' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Stats clients et affaires' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getStatistiquesML", null);
__decorate([
    (0, common_1.Get)('clients/segmentation'),
    (0, swagger_1.ApiOperation)({ summary: 'Segmentation RFM des clients' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des clients avec segmentation' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getClientSegmentation", null);
__decorate([
    (0, common_1.Get)('clients/segmentation/synthese'),
    (0, swagger_1.ApiOperation)({ summary: 'Synthèse de la segmentation' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Stats par segment' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getSegmentationSynthese", null);
__decorate([
    (0, common_1.Get)('clients/segment/:segment'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients d\'un segment' }),
    (0, swagger_1.ApiParam)({ name: 'segment', description: 'VIP, PREMIUM, STANDARD, PETIT' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Clients du segment' }),
    __param(0, (0, common_1.Param)('segment')),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getClientsParSegment", null);
__decorate([
    (0, common_1.Get)('clients/churn-risk'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients à risque de churn' }),
    (0, swagger_1.ApiQuery)({ name: 'seuil', required: false, type: Number, description: 'Seuil probabilité (défaut: 0.3)' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Clients avec probabilité churn élevée' }),
    __param(0, (0, common_1.Query)('seuil')),
    __param(1, (0, common_1.Query)('page')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Number]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getClientChurnRisk", null);
__decorate([
    (0, common_1.Get)('clients/fort-potentiel'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients à fort potentiel' }),
    (0, swagger_1.ApiQuery)({ name: 'seuil', required: false, type: Number, description: 'Seuil score potentiel (défaut: 70)' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Clients avec fort potentiel' }),
    __param(0, (0, common_1.Query)('seuil')),
    __param(1, (0, common_1.Query)('page')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Number]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getClientsFortPotentiel", null);
__decorate([
    (0, common_1.Get)('clients/:id/features'),
    (0, swagger_1.ApiOperation)({ summary: 'Features ML d\'un client' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Détail features du client' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getClientFeatures", null);
__decorate([
    (0, common_1.Get)('affaires/predictions'),
    (0, swagger_1.ApiOperation)({ summary: 'Prédictions sur les affaires' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Affaires avec prédictions marge' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getAffairePredictions", null);
__decorate([
    (0, common_1.Get)('affaires/risque-depassement'),
    (0, swagger_1.ApiOperation)({ summary: 'Affaires à risque de dépassement' }),
    (0, swagger_1.ApiQuery)({ name: 'seuil', required: false, type: Number, description: 'Seuil score (défaut: 50)' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Affaires à risque' }),
    __param(0, (0, common_1.Query)('seuil')),
    __param(1, (0, common_1.Query)('page')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Number]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getAffairesRisqueDepassement", null);
__decorate([
    (0, common_1.Get)('affaires/:id/features'),
    (0, swagger_1.ApiOperation)({ summary: 'Features ML d\'une affaire' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Détail features de l\'affaire' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], MlController.prototype, "getAffaireFeatures", null);
exports.MlController = MlController = __decorate([
    (0, swagger_1.ApiTags)('ml'),
    (0, common_1.Controller)('ml'),
    __metadata("design:paramtypes", [ml_service_1.MlService])
], MlController);
//# sourceMappingURL=ml.controller.js.map
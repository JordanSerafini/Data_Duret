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
exports.CommercialController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const commercial_service_1 = require("./commercial.service");
const dto_1 = require("../../common/dto");
let CommercialController = class CommercialController {
    constructor(commercialService) {
        this.commercialService = commercialService;
    }
    async getCaByPeriode(filter) {
        return this.commercialService.getCaByPeriode(filter);
    }
    async getCaEvolution(filter) {
        return this.commercialService.getCaEvolution(filter);
    }
    async getSegments() {
        return this.commercialService.getSegments();
    }
    async getClients(filter, pagination) {
        return this.commercialService.getClients(filter, pagination);
    }
    async getTopClients(filter, limit) {
        return this.commercialService.getTopClients(filter, limit || 10);
    }
    async getClientById(id, filter) {
        return this.commercialService.getClientById(id, filter);
    }
    async getAffaires(filter, pagination) {
        return this.commercialService.getAffaires(filter, pagination);
    }
    async getAffairesEnRetard(filter) {
        return this.commercialService.getAffairesEnRetard(filter);
    }
    async getAffairesEnDepassement(filter) {
        return this.commercialService.getAffairesEnDepassement(filter);
    }
    async getAffaireById(id) {
        return this.commercialService.getAffaireById(id);
    }
};
exports.CommercialController = CommercialController;
__decorate([
    (0, common_1.Get)('ca'),
    (0, swagger_1.ApiOperation)({ summary: 'CA par période (mois, trimestre, année)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'CA agrégé par période' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getCaByPeriode", null);
__decorate([
    (0, common_1.Get)('ca/evolution'),
    (0, swagger_1.ApiOperation)({ summary: 'Évolution du CA dans le temps' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Évolution mensuelle du CA' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getCaEvolution", null);
__decorate([
    (0, common_1.Get)('segments'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des segments de CA' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des segments' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getSegments", null);
__decorate([
    (0, common_1.Get)('clients'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des clients avec KPIs' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste paginée des clients' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto,
        dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getClients", null);
__decorate([
    (0, common_1.Get)('clients/top'),
    (0, swagger_1.ApiOperation)({ summary: 'Top clients par CA' }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number, description: 'Nombre de clients (défaut: 10)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Top clients' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto, Number]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getTopClients", null);
__decorate([
    (0, common_1.Get)('clients/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Détail d\'un client' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Détail du client avec historique CA' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getClientById", null);
__decorate([
    (0, common_1.Get)('affaires'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des affaires avec KPIs' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste paginée des affaires' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto,
        dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getAffaires", null);
__decorate([
    (0, common_1.Get)('affaires/retard'),
    (0, swagger_1.ApiOperation)({ summary: 'Affaires en retard' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des affaires en retard' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getAffairesEnRetard", null);
__decorate([
    (0, common_1.Get)('affaires/depassement'),
    (0, swagger_1.ApiOperation)({ summary: 'Affaires en dépassement de budget' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des affaires en dépassement' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getAffairesEnDepassement", null);
__decorate([
    (0, common_1.Get)('affaires/:id'),
    (0, swagger_1.ApiOperation)({ summary: 'Détail d\'une affaire' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Détail de l\'affaire' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", Promise)
], CommercialController.prototype, "getAffaireById", null);
exports.CommercialController = CommercialController = __decorate([
    (0, swagger_1.ApiTags)('commercial'),
    (0, common_1.Controller)('commercial'),
    __metadata("design:paramtypes", [commercial_service_1.CommercialService])
], CommercialController);
//# sourceMappingURL=commercial.controller.js.map
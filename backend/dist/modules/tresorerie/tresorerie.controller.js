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
exports.TresorerieController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const tresorerie_service_1 = require("./tresorerie.service");
const dto_1 = require("../../common/dto");
let TresorerieController = class TresorerieController {
    constructor(tresorerieService) {
        this.tresorerieService = tresorerieService;
    }
    async getSolde(filter) {
        return this.tresorerieService.getSolde(filter);
    }
    async getEvolution(filter) {
        return this.tresorerieService.getEvolution(filter);
    }
    async getBfr(filter) {
        return this.tresorerieService.getBfr(filter);
    }
    async getBalanceAgee(filter, pagination) {
        return this.tresorerieService.getBalanceAgee(filter, pagination);
    }
    async getBalanceAgeeSynthese(filter) {
        return this.tresorerieService.getBalanceAgeeSynthese(filter);
    }
    async getClientsRisqueCredit(filter, seuil) {
        return this.tresorerieService.getClientsRisqueCredit(filter, seuil || 60);
    }
    async getTensionScore(filter) {
        return this.tresorerieService.getTensionScore(filter);
    }
    async getTresorerieForecast(filter) {
        return this.tresorerieService.getTresorerieForecast(filter);
    }
};
exports.TresorerieController = TresorerieController;
__decorate([
    (0, common_1.Get)('solde'),
    (0, swagger_1.ApiOperation)({ summary: 'Solde de trésorerie' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Solde et flux de trésorerie' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getSolde", null);
__decorate([
    (0, common_1.Get)('evolution'),
    (0, swagger_1.ApiOperation)({ summary: 'Évolution de la trésorerie' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Évolution mensuelle' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getEvolution", null);
__decorate([
    (0, common_1.Get)('bfr'),
    (0, swagger_1.ApiOperation)({ summary: 'BFR - Besoin en Fonds de Roulement' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'BFR par période' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getBfr", null);
__decorate([
    (0, common_1.Get)('balance-agee'),
    (0, swagger_1.ApiOperation)({ summary: 'Balance âgée par client' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Balance âgée paginée' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto,
        dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getBalanceAgee", null);
__decorate([
    (0, common_1.Get)('balance-agee/synthese'),
    (0, swagger_1.ApiOperation)({ summary: 'Synthèse de la balance âgée' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Totaux par tranche d\'âge' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getBalanceAgeeSynthese", null);
__decorate([
    (0, common_1.Get)('risque-credit'),
    (0, swagger_1.ApiOperation)({ summary: 'Clients à risque crédit élevé' }),
    (0, swagger_1.ApiQuery)({ name: 'seuil', required: false, type: Number, description: 'Seuil de risque (défaut: 60)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des clients à risque' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('seuil')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto, Number]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getClientsRisqueCredit", null);
__decorate([
    (0, common_1.Get)('tension'),
    (0, swagger_1.ApiOperation)({ summary: 'Score de tension de trésorerie' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Score composite avec ratios et alertes' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getTensionScore", null);
__decorate([
    (0, common_1.Get)('forecast'),
    (0, swagger_1.ApiOperation)({ summary: 'Prévision de trésorerie 3 mois' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Prévision avec historique et tendance' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], TresorerieController.prototype, "getTresorerieForecast", null);
exports.TresorerieController = TresorerieController = __decorate([
    (0, swagger_1.ApiTags)('tresorerie'),
    (0, common_1.Controller)('tresorerie'),
    __metadata("design:paramtypes", [tresorerie_service_1.TresorerieService])
], TresorerieController);
//# sourceMappingURL=tresorerie.controller.js.map
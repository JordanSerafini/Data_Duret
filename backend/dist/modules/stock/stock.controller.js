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
exports.StockController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const stock_service_1 = require("./stock.service");
const dto_1 = require("../../common/dto");
const stock_filter_dto_1 = require("./dto/stock-filter.dto");
let StockController = class StockController {
    constructor(stockService) {
        this.stockService = stockService;
    }
    async getStocks(filter) {
        return this.stockService.findAll(filter);
    }
    async getFamilles() {
        return this.stockService.getFamilles();
    }
    async getAlertes(filter) {
        return this.stockService.getAlertes(filter);
    }
    async getAlertesRupture(filter) {
        return this.stockService.getAlertesRupture(filter);
    }
    async getAlertesSurstock(filter) {
        return this.stockService.getAlertesSurstock(filter);
    }
    async getRotation(filter, pagination) {
        return this.stockService.getRotation(filter, pagination);
    }
    async getSynthese(filter) {
        return this.stockService.getSynthese(filter);
    }
    async getValeurParFamille(filter) {
        return this.stockService.getValeurParFamille(filter);
    }
};
exports.StockController = StockController;
__decorate([
    (0, common_1.Get)(''),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des stocks avec filtres et pagination' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste paginée des stocks' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [stock_filter_dto_1.StockFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getStocks", null);
__decorate([
    (0, common_1.Get)('familles'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des familles d\'articles' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des familles' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getFamilles", null);
__decorate([
    (0, common_1.Get)('alertes'),
    (0, swagger_1.ApiOperation)({ summary: 'Toutes les alertes stock (ruptures + surstocks)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des alertes' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getAlertes", null);
__decorate([
    (0, common_1.Get)('alertes/rupture'),
    (0, swagger_1.ApiOperation)({ summary: 'Articles en rupture imminente' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Articles sous stock minimum' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getAlertesRupture", null);
__decorate([
    (0, common_1.Get)('alertes/surstock'),
    (0, swagger_1.ApiOperation)({ summary: 'Articles en surstock' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Articles en surstock' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getAlertesSurstock", null);
__decorate([
    (0, common_1.Get)('rotation'),
    (0, swagger_1.ApiOperation)({ summary: 'Rotation des stocks par article' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Rotation des stocks paginée' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto,
        dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getRotation", null);
__decorate([
    (0, common_1.Get)('synthese'),
    (0, swagger_1.ApiOperation)({ summary: 'Synthèse globale des stocks' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Valeur totale et indicateurs' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getSynthese", null);
__decorate([
    (0, common_1.Get)('valeur-famille'),
    (0, swagger_1.ApiOperation)({ summary: 'Valeur stock par famille d\'articles' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Répartition par famille' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], StockController.prototype, "getValeurParFamille", null);
exports.StockController = StockController = __decorate([
    (0, swagger_1.ApiTags)('stock'),
    (0, common_1.Controller)('stock'),
    __metadata("design:paramtypes", [stock_service_1.StockService])
], StockController);
//# sourceMappingURL=stock.controller.js.map
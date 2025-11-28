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
exports.RhController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const rh_service_1 = require("./rh.service");
const dto_1 = require("../../common/dto");
let RhController = class RhController {
    constructor(rhService) {
        this.rhService = rhService;
    }
    async getProductivite(filter, pagination) {
        return this.rhService.getProductivite(filter, pagination);
    }
    async getSyntheseMensuelle(filter) {
        return this.rhService.getSyntheseMensuelle(filter);
    }
    async getTopProductifs(filter, limit) {
        return this.rhService.getTopProductifs(filter, limit || 10);
    }
    async getSalariesSousOccupes(filter, seuil) {
        return this.rhService.getSalariesSousOccupes(filter, seuil || 70);
    }
    async getPostes() {
        return this.rhService.getPostes();
    }
    async getQualifications() {
        return this.rhService.getQualifications();
    }
    async getHeuresParSalarie(id, filter) {
        return this.rhService.getHeuresParSalarie(id, filter);
    }
};
exports.RhController = RhController;
__decorate([
    (0, common_1.Get)('productivite'),
    (0, swagger_1.ApiOperation)({ summary: 'Productivité des salariés' }),
    (0, swagger_1.ApiQuery)({ name: 'page', required: false, type: Number }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des salariés avec productivité' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto,
        dto_1.PaginationDto]),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getProductivite", null);
__decorate([
    (0, common_1.Get)('synthese'),
    (0, swagger_1.ApiOperation)({ summary: 'Synthèse mensuelle RH' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Synthèse des heures et coûts' }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getSyntheseMensuelle", null);
__decorate([
    (0, common_1.Get)('top-productifs'),
    (0, swagger_1.ApiOperation)({ summary: 'Top salariés les plus productifs' }),
    (0, swagger_1.ApiQuery)({ name: 'limit', required: false, type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Top salariés' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto, Number]),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getTopProductifs", null);
__decorate([
    (0, common_1.Get)('sous-occupes'),
    (0, swagger_1.ApiOperation)({ summary: 'Salariés sous-occupés' }),
    (0, swagger_1.ApiQuery)({ name: 'seuil', required: false, type: Number, description: 'Seuil occupation (défaut: 70%)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Salariés avec taux d\'occupation faible' }),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Query)('seuil')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [dto_1.PeriodeFilterDto, Number]),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getSalariesSousOccupes", null);
__decorate([
    (0, common_1.Get)('postes'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des postes' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des postes' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getPostes", null);
__decorate([
    (0, common_1.Get)('qualifications'),
    (0, swagger_1.ApiOperation)({ summary: 'Liste des qualifications' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Liste des qualifications' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getQualifications", null);
__decorate([
    (0, common_1.Get)('synthese-mensuelle'),
    (0, swagger_1.ApiOperation)({ summary: 'Détail heures d\'un salarié' }),
    (0, swagger_1.ApiParam)({ name: 'id', type: Number }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'Historique heures du salarié' }),
    __param(0, (0, common_1.Param)('id', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, dto_1.PeriodeFilterDto]),
    __metadata("design:returntype", Promise)
], RhController.prototype, "getHeuresParSalarie", null);
exports.RhController = RhController = __decorate([
    (0, swagger_1.ApiTags)('rh'),
    (0, common_1.Controller)('api/rh'),
    __metadata("design:paramtypes", [rh_service_1.RhService])
], RhController);
//# sourceMappingURL=rh.controller.js.map
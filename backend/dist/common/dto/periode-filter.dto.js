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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PeriodeFilterDto = exports.NiveauAgregation = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
var NiveauAgregation;
(function (NiveauAgregation) {
    NiveauAgregation["JOUR"] = "JOUR";
    NiveauAgregation["SEMAINE"] = "SEMAINE";
    NiveauAgregation["MOIS"] = "MOIS";
    NiveauAgregation["TRIMESTRE"] = "TRIMESTRE";
    NiveauAgregation["ANNEE"] = "ANNEE";
})(NiveauAgregation || (exports.NiveauAgregation = NiveauAgregation = {}));
class PeriodeFilterDto {
}
exports.PeriodeFilterDto = PeriodeFilterDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Année', example: 2024 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(2020),
    (0, class_validator_1.Max)(2030),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "annee", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Mois (1-12)', example: 6 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(12),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "mois", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Trimestre (1-4)', example: 2 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(4),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "trimestre", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'ID Société', example: 1 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "societeId", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        enum: NiveauAgregation,
        description: "Niveau d'agrégation",
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(NiveauAgregation),
    __metadata("design:type", String)
], PeriodeFilterDto.prototype, "niveau", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Seuil de risque (défaut: 60)', example: 60 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(0),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "seuil", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: 'Limite de résultats', example: 10 }),
    (0, class_validator_1.IsOptional)(),
    (0, class_transformer_1.Transform)(({ value }) => parseInt(value)),
    (0, class_validator_1.IsInt)(),
    (0, class_validator_1.Min)(1),
    (0, class_validator_1.Max)(100),
    __metadata("design:type", Number)
], PeriodeFilterDto.prototype, "limit", void 0);
//# sourceMappingURL=periode-filter.dto.js.map
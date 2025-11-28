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
exports.DimSociete = void 0;
const typeorm_1 = require("typeorm");
let DimSociete = class DimSociete {
};
exports.DimSociete = DimSociete;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)({ name: 'societe_sk' }),
    __metadata("design:type", Number)
], DimSociete.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_nk', length: 20 }),
    __metadata("design:type", String)
], DimSociete.prototype, "societeNk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_system', length: 20 }),
    __metadata("design:type", String)
], DimSociete.prototype, "sourceSystem", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_id', nullable: true }),
    __metadata("design:type", Number)
], DimSociete.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 10, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'raison_sociale', length: 100, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "raisonSociale", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 14, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "siret", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "adresse", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'code_postal', length: 10, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "codePostal", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "ville", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 3, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "departement", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "region", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "telephone", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 100, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "email", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'regime_tva', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimSociete.prototype, "regimeTva", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'is_current', default: true }),
    __metadata("design:type", Boolean)
], DimSociete.prototype, "isCurrent", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_from', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimSociete.prototype, "validFrom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_to', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimSociete.prototype, "validTo", void 0);
exports.DimSociete = DimSociete = __decorate([
    (0, typeorm_1.Entity)({ name: 'dim_societe', schema: 'silver' }),
    (0, typeorm_1.Index)(['societeNk', 'isCurrent'])
], DimSociete);
//# sourceMappingURL=dim-societe.entity.js.map
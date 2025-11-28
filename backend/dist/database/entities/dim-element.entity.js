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
exports.DimElement = void 0;
const typeorm_1 = require("typeorm");
let DimElement = class DimElement {
};
exports.DimElement = DimElement;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)({ name: 'element_sk' }),
    __metadata("design:type", Number)
], DimElement.prototype, "elementSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'element_nk', length: 40 }),
    __metadata("design:type", String)
], DimElement.prototype, "elementNk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_system', length: 20, default: 'MDE_ERP' }),
    __metadata("design:type", String)
], DimElement.prototype, "sourceSystem", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_id', nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 30, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 200, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "designation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'type_element', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "typeElement", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "famille", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'sous_famille', length: 50, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "sousFamille", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 10, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "unite", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'prix_achat_standard', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "prixAchatStandard", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'prix_vente_standard', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "prixVenteStandard", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_standard_pct', type: 'numeric', precision: 6, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "margeStandardPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'temps_unitaire_heures', type: 'numeric', precision: 10, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "tempsUnitaireHeures", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'compte_achat', length: 13, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "compteAchat", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'compte_vente', length: 13, nullable: true }),
    __metadata("design:type", String)
], DimElement.prototype, "compteVente", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'fournisseur_principal_sk', nullable: true }),
    __metadata("design:type", Number)
], DimElement.prototype, "fournisseurPrincipalSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_actif', nullable: true }),
    __metadata("design:type", Boolean)
], DimElement.prototype, "estActif", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'is_current', default: true }),
    __metadata("design:type", Boolean)
], DimElement.prototype, "isCurrent", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_from', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimElement.prototype, "validFrom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_to', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimElement.prototype, "validTo", void 0);
exports.DimElement = DimElement = __decorate([
    (0, typeorm_1.Entity)({ name: 'dim_element', schema: 'silver' }),
    (0, typeorm_1.Index)(['elementNk', 'isCurrent']),
    (0, typeorm_1.Index)(['typeElement']),
    (0, typeorm_1.Index)(['famille'])
], DimElement);
//# sourceMappingURL=dim-element.entity.js.map
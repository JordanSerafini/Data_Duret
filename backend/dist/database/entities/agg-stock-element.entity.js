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
exports.AggStockElement = void 0;
const typeorm_1 = require("typeorm");
let AggStockElement = class AggStockElement {
};
exports.AggStockElement = AggStockElement;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggStockElement.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'element_sk', nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "elementSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'depot_code', length: 20, nullable: true }),
    __metadata("design:type", String)
], AggStockElement.prototype, "depotCode", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_calcul', type: 'date' }),
    __metadata("design:type", Date)
], AggStockElement.prototype, "dateCalcul", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'stock_initial', type: 'numeric', precision: 15, scale: 4, default: 0 }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "stockInitial", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'entrees', type: 'numeric', precision: 15, scale: 4, default: 0 }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "entrees", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'sorties', type: 'numeric', precision: 15, scale: 4, default: 0 }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "sorties", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'stock_final', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "stockFinal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valeur_stock', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "valeurStock", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'prix_moyen_pondere', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "prixMoyenPondere", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'rotation_stock', type: 'numeric', precision: 6, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "rotationStock", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'couverture_jours', nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "couvertureJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'stock_minimum', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "stockMinimum", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_sous_stock_mini', default: false }),
    __metadata("design:type", Boolean)
], AggStockElement.prototype, "estSousStockMini", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_surstock', default: false }),
    __metadata("design:type", Boolean)
], AggStockElement.prototype, "estSurstock", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'conso_moyenne_mensuelle', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "consoMoyenneMensuelle", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'conso_dernier_mois', type: 'numeric', precision: 15, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], AggStockElement.prototype, "consoDernierMois", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggStockElement.prototype, "lastUpdated", void 0);
exports.AggStockElement = AggStockElement = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_stock_element', schema: 'gold' }),
    (0, typeorm_1.Index)(['elementSk']),
    (0, typeorm_1.Index)(['estSousStockMini', 'estSurstock'])
], AggStockElement);
//# sourceMappingURL=agg-stock-element.entity.js.map
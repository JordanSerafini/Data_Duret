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
exports.AggTresorerie = void 0;
const typeorm_1 = require("typeorm");
let AggTresorerie = class AggTresorerie {
};
exports.AggTresorerie = AggTresorerie;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "annee", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "mois", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "jour", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'niveau_agregation', length: 20 }),
    __metadata("design:type", String)
], AggTresorerie.prototype, "niveauAgregation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'solde_banque', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "soldeBanque", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'solde_caisse', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "soldeCaisse", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'solde_total', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "soldeTotal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'encaissements', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "encaissements", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'decaissements', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "decaissements", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'flux_net', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "fluxNet", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'creances_clients', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "creancesClients", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'creances_echues', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "creancesEchues", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'dettes_fournisseurs', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "dettesFournisseurs", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'dettes_echues', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "dettesEchues", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'bfr_estime', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggTresorerie.prototype, "bfrEstime", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggTresorerie.prototype, "lastUpdated", void 0);
exports.AggTresorerie = AggTresorerie = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_tresorerie', schema: 'gold' }),
    (0, typeorm_1.Index)(['societeSk']),
    (0, typeorm_1.Index)(['annee', 'mois'])
], AggTresorerie);
//# sourceMappingURL=agg-tresorerie.entity.js.map
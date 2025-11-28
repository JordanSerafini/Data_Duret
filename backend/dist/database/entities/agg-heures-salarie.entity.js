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
exports.AggHeuresSalarie = void 0;
const typeorm_1 = require("typeorm");
let AggHeuresSalarie = class AggHeuresSalarie {
};
exports.AggHeuresSalarie = AggHeuresSalarie;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'salarie_sk', nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "salarieSk", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "annee", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "mois", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_normales', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresNormales", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_supplementaires', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresSupplementaires", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_total', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresTotal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_theoriques', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresTheoriques", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_occupation', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "tauxOccupation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_productives', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresProductives", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_non_productives', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "heuresNonProductives", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_productivite', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "tauxProductivite", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_affaires_travaillees', default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "nbAffairesTravaillees", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_brut', type: 'numeric', precision: 12, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "coutBrut", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_charge', type: 'numeric', precision: 12, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "coutCharge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'indemnites', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "indemnites", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_total', type: 'numeric', precision: 12, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "coutTotal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_horaire_moyen', type: 'numeric', precision: 8, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggHeuresSalarie.prototype, "coutHoraireMoyen", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggHeuresSalarie.prototype, "lastUpdated", void 0);
exports.AggHeuresSalarie = AggHeuresSalarie = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_heures_salarie', schema: 'gold' }),
    (0, typeorm_1.Index)(['salarieSk']),
    (0, typeorm_1.Index)(['annee', 'mois'])
], AggHeuresSalarie);
//# sourceMappingURL=agg-heures-salarie.entity.js.map
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
exports.DimSalarie = void 0;
const typeorm_1 = require("typeorm");
let DimSalarie = class DimSalarie {
};
exports.DimSalarie = DimSalarie;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)({ name: 'salarie_sk' }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "salarieSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'salarie_nk', length: 30 }),
    __metadata("design:type", String)
], DimSalarie.prototype, "salarieNk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_system', length: 20, default: 'MDE_ERP' }),
    __metadata("design:type", String)
], DimSalarie.prototype, "sourceSystem", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_id', nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "matricule", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "nom", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "prenom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nom_complet', length: 100, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "nomComplet", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_naissance', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimSalarie.prototype, "dateNaissance", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "age", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_entree', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimSalarie.prototype, "dateEntree", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_sortie', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimSalarie.prototype, "dateSortie", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'anciennete_mois', nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "ancienneteMois", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "poste", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'categorie_poste', length: 30, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "categoriePoste", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 30, nullable: true }),
    __metadata("design:type", String)
], DimSalarie.prototype, "qualification", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "coefficient", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_horaire', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "tauxHoraire", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_horaire_charge', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "coutHoraireCharge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'responsable_sk', nullable: true }),
    __metadata("design:type", Number)
], DimSalarie.prototype, "responsableSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_actif', nullable: true }),
    __metadata("design:type", Boolean)
], DimSalarie.prototype, "estActif", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'is_current', default: true }),
    __metadata("design:type", Boolean)
], DimSalarie.prototype, "isCurrent", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_from', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimSalarie.prototype, "validFrom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_to', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimSalarie.prototype, "validTo", void 0);
exports.DimSalarie = DimSalarie = __decorate([
    (0, typeorm_1.Entity)({ name: 'dim_salarie', schema: 'silver' }),
    (0, typeorm_1.Index)(['salarieNk', 'isCurrent']),
    (0, typeorm_1.Index)(['matricule'])
], DimSalarie);
//# sourceMappingURL=dim-salarie.entity.js.map
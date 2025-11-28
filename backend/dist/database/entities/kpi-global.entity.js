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
exports.KpiGlobal = void 0;
const typeorm_1 = require("typeorm");
let KpiGlobal = class KpiGlobal {
};
exports.KpiGlobal = KpiGlobal;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "annee", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "mois", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_mensuel', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaMensuel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_cumul', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaCumul", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_objectif', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaObjectif", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_realisation_pct', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaRealisationPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_variation_n1_pct', type: 'numeric', precision: 6, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaVariationN1Pct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiPanierMoyen", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_nb_nouveaux_clients', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiNbNouveauxClients", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_taux_transformation', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiTauxTransformation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_marge_brute', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiMargeBrute", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_taux_marge', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiTauxMarge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_marge_objectif', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiMargeObjectif", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_tresorerie_nette', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiTresorerieNette", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_bfr', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiBfr", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_dso_jours', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiDsoJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_dpo_jours', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiDpoJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_effectif_moyen', type: 'numeric', precision: 6, scale: 1, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiEffectifMoyen", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_heures_productives', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiHeuresProductives", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_taux_occupation', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiTauxOccupation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_cout_mo_par_heure', type: 'numeric', precision: 8, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCoutMoParHeure", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_ca_par_salarie', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCaParSalarie", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_nb_affaires_en_cours', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiNbAffairesEnCours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_nb_affaires_en_retard', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiNbAffairesEnRetard", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_nb_affaires_en_depassement', nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiNbAffairesEnDepassement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_carnet_commandes', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiCarnetCommandes", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'kpi_reste_a_facturer', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], KpiGlobal.prototype, "kpiResteAFacturer", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'calcul_date', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], KpiGlobal.prototype, "calculDate", void 0);
exports.KpiGlobal = KpiGlobal = __decorate([
    (0, typeorm_1.Entity)({ name: 'kpi_global', schema: 'gold' }),
    (0, typeorm_1.Index)(['societeSk', 'annee', 'mois'])
], KpiGlobal);
//# sourceMappingURL=kpi-global.entity.js.map
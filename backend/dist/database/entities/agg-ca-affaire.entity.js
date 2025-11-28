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
exports.AggCaAffaire = void 0;
const typeorm_1 = require("typeorm");
let AggCaAffaire = class AggCaAffaire {
};
exports.AggCaAffaire = AggCaAffaire;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'affaire_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "affaireSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_devis', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "montantDevis", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "montantCommande", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_facture', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "montantFacture", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_avoir', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "montantAvoir", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_reste_a_facturer', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "montantResteAFacturer", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_mo_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutMoPrevu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_mo_reel', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutMoReel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_achats_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutAchatsPrevu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_achats_reel', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutAchatsReel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_sous_traitance_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutSousTraitancePrevu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_sous_traitance_reel', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutSousTraitanceReel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_total_prevu', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutTotalPrevu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'cout_total_reel', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "coutTotalReel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_prevue', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "margePrevue", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_reelle', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "margeReelle", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_marge_prevu', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "tauxMargePrevu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_marge_reel', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "tauxMargeReel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ecart_marge', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "ecartMarge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_budget', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "heuresBudget", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_realisees', type: 'numeric', precision: 10, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "heuresRealisees", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ecart_heures', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "ecartHeures", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'productivite_pct', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "productivitePct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'avancement_facturation_pct', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "avancementFacturationPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'avancement_travaux_pct', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaAffaire.prototype, "avancementTravauxPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_en_depassement_budget', default: false }),
    __metadata("design:type", Boolean)
], AggCaAffaire.prototype, "estEnDepassementBudget", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'est_en_retard', default: false }),
    __metadata("design:type", Boolean)
], AggCaAffaire.prototype, "estEnRetard", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'niveau_risque', length: 20, nullable: true }),
    __metadata("design:type", String)
], AggCaAffaire.prototype, "niveauRisque", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggCaAffaire.prototype, "lastUpdated", void 0);
exports.AggCaAffaire = AggCaAffaire = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_ca_affaire', schema: 'gold' }),
    (0, typeorm_1.Index)(['societeSk']),
    (0, typeorm_1.Index)(['clientSk']),
    (0, typeorm_1.Index)(['niveauRisque'])
], AggCaAffaire);
//# sourceMappingURL=agg-ca-affaire.entity.js.map
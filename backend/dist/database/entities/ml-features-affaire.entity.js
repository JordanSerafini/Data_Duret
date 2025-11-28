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
exports.MlFeaturesAffaire = void 0;
const typeorm_1 = require("typeorm");
let MlFeaturesAffaire = class MlFeaturesAffaire {
};
exports.MlFeaturesAffaire = MlFeaturesAffaire;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'affaire_sk', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "affaireSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_extraction', type: 'date' }),
    __metadata("design:type", Date)
], MlFeaturesAffaire.prototype, "dateExtraction", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'type_affaire', length: 30, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesAffaire.prototype, "typeAffaire", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "montantCommande", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_log', type: 'numeric', precision: 10, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "montantLog", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'duree_prevue_jours', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "dureePrevueJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_lots', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "nbLots", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_anciennete_mois', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "clientAncienneteMois", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_ca_historique', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "clientCaHistorique", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_nb_affaires_historique', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "clientNbAffairesHistorique", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_marge_moyenne_historique', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "clientMargeMoyenneHistorique", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'distance_siege_km', type: 'numeric', precision: 8, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "distanceSiegeKm", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'departement', length: 3, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesAffaire.prototype, "departement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'zone_geographique', length: 20, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesAffaire.prototype, "zoneGeographique", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'mois_demarrage', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "moisDemarrage", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'trimestre_demarrage', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "trimestreDemarrage", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_salaries_affectes', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "nbSalariesAffectes", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'heures_budget', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "heuresBudget", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ratio_mo_montant', type: 'numeric', precision: 8, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "ratioMoMontant", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_reelle_pct', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "margeReellePct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ecart_budget_heures_pct', type: 'numeric', precision: 6, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "ecartBudgetHeuresPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'retard_jours', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "retardJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_predite_pct', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "margePreditePct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'risque_depassement_score', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesAffaire.prototype, "risqueDepassementScore", void 0);
exports.MlFeaturesAffaire = MlFeaturesAffaire = __decorate([
    (0, typeorm_1.Entity)({ name: 'ml_features_affaire', schema: 'gold' }),
    (0, typeorm_1.Index)(['affaireSk'])
], MlFeaturesAffaire);
//# sourceMappingURL=ml-features-affaire.entity.js.map
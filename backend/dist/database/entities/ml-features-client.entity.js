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
exports.MlFeaturesClient = void 0;
const typeorm_1 = require("typeorm");
let MlFeaturesClient = class MlFeaturesClient {
};
exports.MlFeaturesClient = MlFeaturesClient;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_sk', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_extraction', type: 'date' }),
    __metadata("design:type", Date)
], MlFeaturesClient.prototype, "dateExtraction", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_12m', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "ca12m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_6m', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "ca6m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_3m', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "ca3m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_1m', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "ca1m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'tendance_ca', length: 20, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesClient.prototype, "tendanceCa", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'volatilite_ca', type: 'numeric', precision: 8, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "volatiliteCa", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_commandes_12m', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "nbCommandes12m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'frequence_commande_jours', type: 'numeric', precision: 6, scale: 1, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "frequenceCommandeJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'recence_derniere_commande_jours', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "recenceDerniereCommandeJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "panierMoyen", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'panier_max', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "panierMax", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'panier_min', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "panierMin", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'delai_paiement_moyen_jours', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "delaiPaiementMoyenJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_retards_paiement_12m', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "nbRetardsPaiement12m", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_impayes', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "tauxImpayes", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'anciennete_mois', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "ancienneteMois", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_affaires_total', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "nbAffairesTotal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'type_affaires_principal', length: 30, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesClient.prototype, "typeAffairesPrincipal", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_rfm', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "scoreRfm", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_risque', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "scoreRisque", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_potentiel', nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "scorePotentiel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'segment_valeur', length: 20, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesClient.prototype, "segmentValeur", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'segment_comportement', length: 20, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesClient.prototype, "segmentComportement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'segment_risque', length: 20, nullable: true }),
    __metadata("design:type", String)
], MlFeaturesClient.prototype, "segmentRisque", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'probabilite_churn', type: 'numeric', precision: 5, scale: 4, nullable: true }),
    __metadata("design:type", Number)
], MlFeaturesClient.prototype, "probabiliteChurn", void 0);
exports.MlFeaturesClient = MlFeaturesClient = __decorate([
    (0, typeorm_1.Entity)({ name: 'ml_features_client', schema: 'gold' }),
    (0, typeorm_1.Index)(['clientSk']),
    (0, typeorm_1.Index)(['segmentValeur', 'segmentComportement'])
], MlFeaturesClient);
//# sourceMappingURL=ml-features-client.entity.js.map
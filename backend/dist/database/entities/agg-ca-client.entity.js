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
exports.AggCaClient = void 0;
const typeorm_1 = require("typeorm");
let AggCaClient = class AggCaClient {
};
exports.AggCaClient = AggCaClient;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggCaClient.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], AggCaClient.prototype, "annee", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_cumule', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "caCumule", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_n_moins_1', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "caNMoins1", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'variation_ca_pct', type: 'numeric', precision: 6, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "variationCaPct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_affaires', default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "nbAffaires", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_factures', default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "nbFactures", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_avoirs', default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "nbAvoirs", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_brute', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "margeBrute", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_marge', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "tauxMarge", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'encours_actuel', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "encoursActuel", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'retard_paiement_moyen_jours', nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "retardPaiementMoyenJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_impayes', default: 0 }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "nbImpayes", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'segment_ca', length: 20, nullable: true }),
    __metadata("design:type", String)
], AggCaClient.prototype, "segmentCa", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_fidelite', nullable: true }),
    __metadata("design:type", Number)
], AggCaClient.prototype, "scoreFidelite", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'potentiel_croissance', length: 20, nullable: true }),
    __metadata("design:type", String)
], AggCaClient.prototype, "potentielCroissance", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggCaClient.prototype, "lastUpdated", void 0);
exports.AggCaClient = AggCaClient = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_ca_client', schema: 'gold' }),
    (0, typeorm_1.Index)(['clientSk']),
    (0, typeorm_1.Index)(['segmentCa'])
], AggCaClient);
//# sourceMappingURL=agg-ca-client.entity.js.map
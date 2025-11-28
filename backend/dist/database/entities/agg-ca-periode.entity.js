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
exports.AggCaPeriode = void 0;
const typeorm_1 = require("typeorm");
let AggCaPeriode = class AggCaPeriode {
};
exports.AggCaPeriode = AggCaPeriode;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "annee", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "mois", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "trimestre", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'semaine_iso', nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "semaineIso", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'niveau_agregation', length: 20 }),
    __metadata("design:type", String)
], AggCaPeriode.prototype, "niveauAgregation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_debut', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], AggCaPeriode.prototype, "dateDebut", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_fin', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], AggCaPeriode.prototype, "dateFin", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_devis', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "caDevis", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_commande', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "caCommande", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_facture', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "caFacture", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_avoir', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "caAvoir", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ca_net', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "caNet", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_devis', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbDevis", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_commandes', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbCommandes", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_factures', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbFactures", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_avoirs', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbAvoirs", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_clients_actifs', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbClientsActifs", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'nb_affaires_actives', default: 0 }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "nbAffairesActives", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "panierMoyen", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_transformation', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggCaPeriode.prototype, "tauxTransformation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggCaPeriode.prototype, "lastUpdated", void 0);
exports.AggCaPeriode = AggCaPeriode = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_ca_periode', schema: 'gold' }),
    (0, typeorm_1.Index)(['societeSk', 'annee', 'mois'])
], AggCaPeriode);
//# sourceMappingURL=agg-ca-periode.entity.js.map
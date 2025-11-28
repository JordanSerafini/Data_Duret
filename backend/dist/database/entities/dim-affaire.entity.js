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
exports.DimAffaire = void 0;
const typeorm_1 = require("typeorm");
let DimAffaire = class DimAffaire {
};
exports.DimAffaire = DimAffaire;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)({ name: 'affaire_sk' }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "affaireSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'affaire_nk', length: 30 }),
    __metadata("design:type", String)
], DimAffaire.prototype, "affaireNk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_system', length: 20, default: 'MDE_ERP' }),
    __metadata("design:type", String)
], DimAffaire.prototype, "sourceSystem", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_id', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_sk', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'commercial_sk', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "commercialSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'responsable_sk', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "responsableSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 200, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "libelle", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "etat", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'etat_groupe', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "etatGroupe", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'type_affaire', length: 30, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "typeAffaire", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_creation', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "dateCreation", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_debut_prevue', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "dateDebutPrevue", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_fin_prevue', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "dateFinPrevue", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_debut_reelle', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "dateDebutReelle", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_fin_reelle', type: 'date', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "dateFinReelle", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'duree_prevue_jours', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "dureePrevueJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'duree_reelle_jours', nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "dureeReelleJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'adresse_chantier', type: 'text', nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "adresseChantier", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'code_postal_chantier', length: 10, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "codePostalChantier", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'ville_chantier', length: 100, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "villeChantier", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'departement_chantier', length: 3, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "departementChantier", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'region_chantier', length: 50, nullable: true }),
    __metadata("design:type", String)
], DimAffaire.prototype, "regionChantier", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_devis', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "montantDevis", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "montantCommande", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'budget_heures', type: 'numeric', precision: 10, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "budgetHeures", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'marge_prevue_pct', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimAffaire.prototype, "margePrevuePct", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'is_current', default: true }),
    __metadata("design:type", Boolean)
], DimAffaire.prototype, "isCurrent", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_from', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "validFrom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_to', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimAffaire.prototype, "validTo", void 0);
exports.DimAffaire = DimAffaire = __decorate([
    (0, typeorm_1.Entity)({ name: 'dim_affaire', schema: 'silver' }),
    (0, typeorm_1.Index)(['affaireNk', 'isCurrent']),
    (0, typeorm_1.Index)(['code']),
    (0, typeorm_1.Index)(['etat']),
    (0, typeorm_1.Index)(['clientSk'])
], DimAffaire);
//# sourceMappingURL=dim-affaire.entity.js.map
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
exports.DimClient = void 0;
const typeorm_1 = require("typeorm");
let DimClient = class DimClient {
};
exports.DimClient = DimClient;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)({ name: 'client_sk' }),
    __metadata("design:type", Number)
], DimClient.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_nk', length: 30 }),
    __metadata("design:type", String)
], DimClient.prototype, "clientNk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_system', length: 20 }),
    __metadata("design:type", String)
], DimClient.prototype, "sourceSystem", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'source_id', nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "sourceId", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "code", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'raison_sociale', length: 150, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "raisonSociale", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'type_client', length: 30, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "typeClient", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 14, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "siret", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'tva_intracom', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "tvaIntracom", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "adresse", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'code_postal', length: 10, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "codePostal", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 100, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "ville", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 3, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "departement", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "region", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 50, nullable: true, default: 'FRANCE' }),
    __metadata("design:type", String)
], DimClient.prototype, "pays", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "telephone", void 0);
__decorate([
    (0, typeorm_1.Column)({ length: 150, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "email", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'mode_reglement', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "modeReglement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'conditions_paiement', nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "conditionsPaiement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'encours_max', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "encoursMax", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_remise', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "tauxRemise", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'segment_client', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "segmentClient", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_risque', nullable: true }),
    __metadata("design:type", Number)
], DimClient.prototype, "scoreRisque", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'sage_code', length: 17, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "sageCode", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'mde_code', length: 20, nullable: true }),
    __metadata("design:type", String)
], DimClient.prototype, "mdeCode", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'is_current', default: true }),
    __metadata("design:type", Boolean)
], DimClient.prototype, "isCurrent", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_from', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimClient.prototype, "validFrom", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'valid_to', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], DimClient.prototype, "validTo", void 0);
exports.DimClient = DimClient = __decorate([
    (0, typeorm_1.Entity)({ name: 'dim_client', schema: 'silver' }),
    (0, typeorm_1.Index)(['clientNk', 'isCurrent']),
    (0, typeorm_1.Index)(['siret']),
    (0, typeorm_1.Index)(['ville'])
], DimClient);
//# sourceMappingURL=dim-client.entity.js.map
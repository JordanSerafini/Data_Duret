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
exports.AggBalanceAgeeClient = void 0;
const typeorm_1 = require("typeorm");
let AggBalanceAgeeClient = class AggBalanceAgeeClient {
};
exports.AggBalanceAgeeClient = AggBalanceAgeeClient;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'societe_sk', nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "societeSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'client_sk', nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "clientSk", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'date_calcul', type: 'date' }),
    __metadata("design:type", Date)
], AggBalanceAgeeClient.prototype, "dateCalcul", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'non_echu', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "nonEchu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'echu_0_30j', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "echu0_30j", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'echu_31_60j', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "echu31_60j", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'echu_61_90j', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "echu61_90j", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'echu_plus_90j', type: 'numeric', precision: 15, scale: 2, default: 0 }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "echuPlus90j", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'total_creances', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "totalCreances", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'total_echu', type: 'numeric', precision: 15, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "totalEchu", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'dso_jours', nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "dsoJours", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'taux_recouvrement', type: 'numeric', precision: 5, scale: 2, nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "tauxRecouvrement", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'score_risque_credit', nullable: true }),
    __metadata("design:type", Number)
], AggBalanceAgeeClient.prototype, "scoreRisqueCredit", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'last_updated', type: 'timestamp', nullable: true }),
    __metadata("design:type", Date)
], AggBalanceAgeeClient.prototype, "lastUpdated", void 0);
exports.AggBalanceAgeeClient = AggBalanceAgeeClient = __decorate([
    (0, typeorm_1.Entity)({ name: 'agg_balance_agee_client', schema: 'gold' }),
    (0, typeorm_1.Index)(['clientSk'])
], AggBalanceAgeeClient);
//# sourceMappingURL=agg-balance-agee-client.entity.js.map
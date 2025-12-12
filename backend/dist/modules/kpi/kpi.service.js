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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.KpiService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const entities_1 = require("../../database/entities");
let KpiService = class KpiService {
    constructor(kpiRepository, societeRepository) {
        this.kpiRepository = kpiRepository;
        this.societeRepository = societeRepository;
    }
    async getDashboard(filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .leftJoin(entities_1.DimSociete, 's', 'k.societe_sk = s.societe_sk AND s.is_current = true')
            .select([
            's.raison_sociale AS societe',
            'k.annee',
            'k.mois',
            'k.kpi_ca_mensuel AS ca_mensuel',
            'k.kpi_ca_cumul AS ca_cumul',
            'k.kpi_ca_realisation_pct AS ca_realisation_pct',
            'k.kpi_ca_variation_n1_pct AS ca_variation_n1_pct',
            'k.kpi_marge_brute AS marge_brute',
            'k.kpi_taux_marge AS taux_marge',
            'k.kpi_tresorerie_nette AS tresorerie_nette',
            'k.kpi_bfr AS bfr',
            'k.kpi_dso_jours AS dso_jours',
            'k.kpi_carnet_commandes AS carnet_commandes',
            'k.kpi_reste_a_facturer AS reste_a_facturer',
            'k.kpi_nb_affaires_en_cours AS nb_affaires_en_cours',
            'k.kpi_nb_affaires_en_retard AS nb_affaires_en_retard',
            'k.kpi_nb_affaires_en_depassement AS nb_affaires_en_depassement',
            'k.kpi_effectif_moyen AS effectif_moyen',
            'k.kpi_taux_occupation AS taux_occupation',
            'k.calcul_date',
        ]);
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('k.mois = :mois', { mois: filter.mois });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('k.societe_sk = :societeId', {
                societeId: filter.societeId,
            });
        }
        queryBuilder.orderBy('k.annee', 'DESC').addOrderBy('k.mois', 'DESC');
        return queryBuilder.getRawMany();
    }
    async getKpisBySociete(societeId, filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .where('k.societe_sk = :societeId', { societeId });
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.mois) {
            queryBuilder.andWhere('k.mois = :mois', { mois: filter.mois });
        }
        queryBuilder.orderBy('k.annee', 'DESC').addOrderBy('k.mois', 'DESC');
        return queryBuilder.getMany();
    }
    async getEvolution(filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .select([
            'k.annee',
            'k.mois',
            'SUM(k.kpi_ca_mensuel) AS ca_total',
            'SUM(k.kpi_marge_brute) AS marge_totale',
            'AVG(k.kpi_taux_marge) AS taux_marge_moyen',
            'SUM(k.kpi_tresorerie_nette) AS tresorerie_totale',
            'SUM(k.kpi_nb_affaires_en_cours) AS nb_affaires_total',
        ])
            .groupBy('k.annee')
            .addGroupBy('k.mois');
        if (filter.annee) {
            queryBuilder.andWhere('k.annee = :annee', { annee: filter.annee });
        }
        if (filter.societeId) {
            queryBuilder.andWhere('k.societe_sk = :societeId', {
                societeId: filter.societeId,
            });
        }
        queryBuilder.orderBy('k.annee', 'ASC').addOrderBy('k.mois', 'ASC');
        return queryBuilder.getRawMany();
    }
    async getSocietes() {
        return this.societeRepository.find({
            where: { isCurrent: true },
            select: ['societeSk', 'code', 'raisonSociale', 'ville'],
            order: { raisonSociale: 'ASC' },
        });
    }
    async getLatestKpis() {
        const subQuery = this.kpiRepository
            .createQueryBuilder('sub')
            .select('MAX(sub.annee * 100 + sub.mois)', 'max_periode');
        const latestPeriode = await subQuery.getRawOne();
        if (!latestPeriode?.max_periode) {
            return [];
        }
        const annee = Math.floor(latestPeriode.max_periode / 100);
        const mois = latestPeriode.max_periode % 100;
        return this.getDashboard({ annee, mois });
    }
    async getSummary() {
        const latest = await this.getLatestKpis();
        if (!latest.length) {
            return {
                periode: null,
                totaux: null,
                alertes: null,
            };
        }
        const totaux = latest.reduce((acc, kpi) => ({
            ca_total: acc.ca_total + (parseFloat(kpi.ca_mensuel) || 0),
            marge_totale: acc.marge_totale + (parseFloat(kpi.marge_brute) || 0),
            tresorerie_totale: acc.tresorerie_totale + (parseFloat(kpi.tresorerie_nette) || 0),
            carnet_total: acc.carnet_total + (parseFloat(kpi.carnet_commandes) || 0),
            nb_affaires: acc.nb_affaires + (parseInt(kpi.nb_affaires_en_cours) || 0),
            nb_retards: acc.nb_retards + (parseInt(kpi.nb_affaires_en_retard) || 0),
            nb_depassements: acc.nb_depassements + (parseInt(kpi.nb_affaires_en_depassement) || 0),
        }), {
            ca_total: 0,
            marge_totale: 0,
            tresorerie_totale: 0,
            carnet_total: 0,
            nb_affaires: 0,
            nb_retards: 0,
            nb_depassements: 0,
        });
        return {
            periode: {
                annee: latest[0].annee,
                mois: latest[0].mois,
            },
            totaux,
            alertes: {
                affaires_en_retard: totaux.nb_retards,
                affaires_en_depassement: totaux.nb_depassements,
            },
            nb_societes: latest.length,
        };
    }
    async getHealthScore(filter) {
        const latest = await this.getLatestKpis();
        if (!latest.length) {
            return { score: 0, status: 'INSUFFISANT', details: null };
        }
        const totaux = {
            ca_mensuel: 0,
            ca_cumul: 0,
            ca_realisation_pct: 0,
            marge_brute: 0,
            taux_marge: 0,
            tresorerie_nette: 0,
            bfr: 0,
            dso_jours: 0,
            nb_affaires_en_cours: 0,
            nb_affaires_en_retard: 0,
            nb_affaires_en_depassement: 0,
            taux_occupation: 0,
        };
        let count = 0;
        latest.forEach((kpi) => {
            totaux.ca_mensuel += parseFloat(kpi.ca_mensuel) || 0;
            totaux.ca_cumul += parseFloat(kpi.ca_cumul) || 0;
            totaux.ca_realisation_pct += parseFloat(kpi.ca_realisation_pct) || 0;
            totaux.marge_brute += parseFloat(kpi.marge_brute) || 0;
            totaux.taux_marge += parseFloat(kpi.taux_marge) || 0;
            totaux.tresorerie_nette += parseFloat(kpi.tresorerie_nette) || 0;
            totaux.bfr += parseFloat(kpi.bfr) || 0;
            totaux.dso_jours += parseFloat(kpi.dso_jours) || 0;
            totaux.nb_affaires_en_cours += parseInt(kpi.nb_affaires_en_cours) || 0;
            totaux.nb_affaires_en_retard += parseInt(kpi.nb_affaires_en_retard) || 0;
            totaux.nb_affaires_en_depassement += parseInt(kpi.nb_affaires_en_depassement) || 0;
            totaux.taux_occupation += parseFloat(kpi.taux_occupation) || 0;
            count++;
        });
        const moyennes = {
            ca_realisation_pct: count > 0 ? totaux.ca_realisation_pct / count : 0,
            taux_marge: count > 0 ? totaux.taux_marge / count : 0,
            dso_jours: count > 0 ? totaux.dso_jours / count : 0,
            taux_occupation: count > 0 ? totaux.taux_occupation / count : 0,
        };
        const scoreCommercial = Math.min(100, moyennes.ca_realisation_pct);
        const scoreRentabilite = Math.min(100, (moyennes.taux_marge / 20) * 100);
        let scoreTresorerie = totaux.tresorerie_nette > 0 ? 70 : 30;
        if (moyennes.dso_jours > 0 && moyennes.dso_jours <= 45)
            scoreTresorerie += 30;
        else if (moyennes.dso_jours > 45 && moyennes.dso_jours <= 60)
            scoreTresorerie += 15;
        const tauxRetard = totaux.nb_affaires_en_cours > 0
            ? ((totaux.nb_affaires_en_retard + totaux.nb_affaires_en_depassement) / totaux.nb_affaires_en_cours) * 100
            : 0;
        const scoreOperationnel = Math.max(0, 100 - tauxRetard * 2);
        const scoreGlobal = Math.round(scoreCommercial * 0.25 +
            scoreRentabilite * 0.25 +
            scoreTresorerie * 0.25 +
            scoreOperationnel * 0.25);
        let status;
        if (scoreGlobal >= 80)
            status = 'EXCELLENT';
        else if (scoreGlobal >= 60)
            status = 'BON';
        else if (scoreGlobal >= 40)
            status = 'ATTENTION';
        else
            status = 'CRITIQUE';
        const alertes = [];
        if (moyennes.ca_realisation_pct < 80)
            alertes.push('CA en dessous des objectifs');
        if (moyennes.taux_marge < 15)
            alertes.push('Marge insuffisante');
        if (totaux.tresorerie_nette < 0)
            alertes.push('Tresorerie negative');
        if (moyennes.dso_jours > 60)
            alertes.push('Delai paiement clients trop long');
        if (tauxRetard > 20)
            alertes.push('Trop d\'affaires en retard ou depassement');
        return {
            score: scoreGlobal,
            status,
            scores_details: {
                commercial: Math.round(scoreCommercial),
                rentabilite: Math.round(scoreRentabilite),
                tresorerie: Math.round(scoreTresorerie),
                operationnel: Math.round(scoreOperationnel),
            },
            indicateurs: {
                ca_realisation_pct: moyennes.ca_realisation_pct,
                taux_marge: moyennes.taux_marge,
                tresorerie_nette: totaux.tresorerie_nette,
                dso_jours: moyennes.dso_jours,
                taux_retard_affaires: tauxRetard,
                taux_occupation: moyennes.taux_occupation,
            },
            totaux: {
                ca_mensuel: totaux.ca_mensuel,
                marge_brute: totaux.marge_brute,
                nb_affaires_en_cours: totaux.nb_affaires_en_cours,
                nb_affaires_en_retard: totaux.nb_affaires_en_retard,
                nb_affaires_en_depassement: totaux.nb_affaires_en_depassement,
            },
            alertes,
            periode: {
                annee: latest[0].annee,
                mois: latest[0].mois,
            },
        };
    }
    async getDsoDpoAnalysis(filter) {
        const queryBuilder = this.kpiRepository
            .createQueryBuilder('k')
            .select([
            'k.annee',
            'k.mois',
            'AVG(k.kpi_dso_jours) AS dso_moyen',
            'AVG(k.kpi_dpo_jours) AS dpo_moyen',
            'SUM(k.kpi_bfr) AS bfr_total',
            'SUM(k.kpi_tresorerie_nette) AS tresorerie_totale',
            'SUM(k.kpi_ca_mensuel) AS ca_total',
        ])
            .groupBy('k.annee')
            .addGroupBy('k.mois')
            .orderBy('k.annee', 'ASC')
            .addOrderBy('k.mois', 'ASC');
        if (filter.societeId) {
            queryBuilder.andWhere('k.societe_sk = :societeId', { societeId: filter.societeId });
        }
        const historique = await queryBuilder.getRawMany();
        if (historique.length === 0) {
            return { status: 'INSUFFISANT', data: null };
        }
        const dernierMois = historique[historique.length - 1];
        const dsoActuel = parseFloat(dernierMois.dso_moyen) || 0;
        const dpoActuel = parseFloat(dernierMois.dpo_moyen) || 0;
        const bfrActuel = parseFloat(dernierMois.bfr_total) || 0;
        const caActuel = parseFloat(dernierMois.ca_total) || 0;
        const recent = historique.slice(-3);
        const precedent = historique.slice(-6, -3);
        const dsoRecent = recent.reduce((acc, m) => acc + parseFloat(m.dso_moyen) || 0, 0) / (recent.length || 1);
        const dsoPrecedent = precedent.length > 0
            ? precedent.reduce((acc, m) => acc + parseFloat(m.dso_moyen) || 0, 0) / precedent.length
            : dsoRecent;
        const dpoRecent = recent.reduce((acc, m) => acc + parseFloat(m.dpo_moyen) || 0, 0) / (recent.length || 1);
        const dpoPrecedent = precedent.length > 0
            ? precedent.reduce((acc, m) => acc + parseFloat(m.dpo_moyen) || 0, 0) / precedent.length
            : dpoRecent;
        const dsoTendance = dsoPrecedent > 0 ? ((dsoRecent - dsoPrecedent) / dsoPrecedent) * 100 : 0;
        const dpoTendance = dpoPrecedent > 0 ? ((dpoRecent - dpoPrecedent) / dpoPrecedent) * 100 : 0;
        let scoreDso;
        if (dsoActuel <= 30)
            scoreDso = 100;
        else if (dsoActuel <= 45)
            scoreDso = 80;
        else if (dsoActuel <= 60)
            scoreDso = 60;
        else if (dsoActuel <= 90)
            scoreDso = 40;
        else
            scoreDso = 20;
        let scoreDpo;
        if (dpoActuel >= 45 && dpoActuel <= 60)
            scoreDpo = 100;
        else if (dpoActuel >= 30 && dpoActuel < 45)
            scoreDpo = 80;
        else if (dpoActuel > 60 && dpoActuel <= 90)
            scoreDpo = 70;
        else if (dpoActuel < 30)
            scoreDpo = 50;
        else
            scoreDpo = 40;
        const ccc = dsoActuel - dpoActuel;
        const recommandations = [];
        if (dsoActuel > 45) {
            const impactDso = caActuel > 0 ? (caActuel / 365) * (dsoActuel - 45) : 0;
            recommandations.push({
                type: 'RECOUVREMENT',
                priorite: dsoActuel > 60 ? 'haute' : 'moyenne',
                description: `Reduire le DSO de ${Math.round(dsoActuel)} a 45 jours pour liberer de la tresorerie`,
                impact_estime: Math.round(impactDso),
            });
        }
        if (dpoActuel < 30) {
            const impactDpo = caActuel > 0 ? (caActuel / 365) * (30 - dpoActuel) : 0;
            recommandations.push({
                type: 'FOURNISSEURS',
                priorite: 'moyenne',
                description: `Negocier des delais fournisseurs de ${Math.round(dpoActuel)} a 30+ jours`,
                impact_estime: Math.round(impactDpo),
            });
        }
        if (ccc > 30) {
            recommandations.push({
                type: 'BFR',
                priorite: 'haute',
                description: `Cycle de conversion (${Math.round(ccc)}j) trop long, optimiser le BFR`,
                impact_estime: Math.round(bfrActuel * 0.1),
            });
        }
        if (dsoTendance > 10) {
            recommandations.push({
                type: 'ALERTE',
                priorite: 'haute',
                description: `DSO en augmentation de ${dsoTendance.toFixed(1)}% - action corrective requise`,
            });
        }
        let status;
        const scoreGlobal = (scoreDso + scoreDpo) / 2;
        if (scoreGlobal >= 80)
            status = 'OPTIMAL';
        else if (scoreGlobal >= 60)
            status = 'BON';
        else if (scoreGlobal >= 40)
            status = 'A_AMELIORER';
        else
            status = 'CRITIQUE';
        return {
            status,
            score_global: Math.round(scoreGlobal),
            dso: {
                actuel: Math.round(dsoActuel),
                objectif: 45,
                score: scoreDso,
                tendance_pct: Math.round(dsoTendance * 10) / 10,
                status: dsoActuel <= 45 ? 'BON' : dsoActuel <= 60 ? 'ATTENTION' : 'CRITIQUE',
            },
            dpo: {
                actuel: Math.round(dpoActuel),
                objectif_min: 30,
                objectif_max: 60,
                score: scoreDpo,
                tendance_pct: Math.round(dpoTendance * 10) / 10,
                status: dpoActuel >= 30 && dpoActuel <= 60 ? 'BON' : 'A_AJUSTER',
            },
            ccc: {
                actuel: Math.round(ccc),
                interpretation: ccc <= 0 ? 'Excellent - tresorerie auto-financee' :
                    ccc <= 30 ? 'Bon - cycle court' :
                        ccc <= 60 ? 'Attention - BFR a surveiller' : 'Critique - BFR eleve',
            },
            bfr: {
                actuel: bfrActuel,
                optimisation_potentielle: recommandations.reduce((acc, r) => acc + (r.impact_estime || 0), 0),
            },
            recommandations,
            historique: historique.map(h => ({
                annee: h.annee,
                mois: h.mois,
                dso: Math.round(parseFloat(h.dso_moyen) || 0),
                dpo: Math.round(parseFloat(h.dpo_moyen) || 0),
                bfr: parseFloat(h.bfr_total) || 0,
            })),
            periode: {
                annee: dernierMois.annee,
                mois: dernierMois.mois,
            },
        };
    }
    async getBenchmarkSocietes(filter) {
        const latest = await this.getLatestKpis();
        if (!latest.length) {
            return { status: 'INSUFFISANT', data: null };
        }
        const moyennesGlobales = {
            ca_mensuel: 0,
            taux_marge: 0,
            dso_jours: 0,
            taux_occupation: 0,
            taux_retard: 0,
        };
        let totalCa = 0;
        let count = 0;
        latest.forEach((kpi) => {
            moyennesGlobales.ca_mensuel += parseFloat(kpi.ca_mensuel) || 0;
            moyennesGlobales.taux_marge += parseFloat(kpi.taux_marge) || 0;
            moyennesGlobales.dso_jours += parseFloat(kpi.dso_jours) || 0;
            moyennesGlobales.taux_occupation += parseFloat(kpi.taux_occupation) || 0;
            const nbAffaires = parseInt(kpi.nb_affaires_en_cours) || 0;
            const nbRetards = (parseInt(kpi.nb_affaires_en_retard) || 0) + (parseInt(kpi.nb_affaires_en_depassement) || 0);
            moyennesGlobales.taux_retard += nbAffaires > 0 ? (nbRetards / nbAffaires) * 100 : 0;
            totalCa += parseFloat(kpi.ca_mensuel) || 0;
            count++;
        });
        if (count > 0) {
            moyennesGlobales.taux_marge /= count;
            moyennesGlobales.dso_jours /= count;
            moyennesGlobales.taux_occupation /= count;
            moyennesGlobales.taux_retard /= count;
        }
        const societes = latest.map((kpi) => {
            const caMensuel = parseFloat(kpi.ca_mensuel) || 0;
            const tauxMarge = parseFloat(kpi.taux_marge) || 0;
            const dsoJours = parseFloat(kpi.dso_jours) || 0;
            const tauxOccupation = parseFloat(kpi.taux_occupation) || 0;
            const nbAffaires = parseInt(kpi.nb_affaires_en_cours) || 0;
            const nbRetards = (parseInt(kpi.nb_affaires_en_retard) || 0) + (parseInt(kpi.nb_affaires_en_depassement) || 0);
            const tauxRetard = nbAffaires > 0 ? (nbRetards / nbAffaires) * 100 : 0;
            const scoreCa = totalCa > 0 ? (caMensuel / totalCa) * 100 : 0;
            const scoreMarge = Math.min(100, (tauxMarge / 20) * 100);
            const scoreDso = dsoJours <= 45 ? 100 : dsoJours <= 60 ? 70 : dsoJours <= 90 ? 40 : 20;
            const scoreOccupation = Math.min(100, tauxOccupation);
            const scoreOperationnel = Math.max(0, 100 - tauxRetard * 2);
            const scoreGlobal = Math.round(scoreCa * 0.30 +
                scoreMarge * 0.25 +
                scoreDso * 0.15 +
                scoreOccupation * 0.15 +
                scoreOperationnel * 0.15);
            const comparaison = {
                ca: caMensuel > moyennesGlobales.ca_mensuel / count ? 'superieur' : 'inferieur',
                marge: tauxMarge > moyennesGlobales.taux_marge ? 'superieur' : 'inferieur',
                dso: dsoJours < moyennesGlobales.dso_jours ? 'superieur' : 'inferieur',
                occupation: tauxOccupation > moyennesGlobales.taux_occupation ? 'superieur' : 'inferieur',
            };
            return {
                societe: kpi.societe || 'Non defini',
                score_global: scoreGlobal,
                rang: 0,
                indicateurs: {
                    ca_mensuel: caMensuel,
                    ca_part_groupe: totalCa > 0 ? Math.round((caMensuel / totalCa) * 1000) / 10 : 0,
                    taux_marge: Math.round(tauxMarge * 10) / 10,
                    dso_jours: Math.round(dsoJours),
                    taux_occupation: Math.round(tauxOccupation * 10) / 10,
                    nb_affaires_en_cours: nbAffaires,
                    taux_retard: Math.round(tauxRetard * 10) / 10,
                },
                scores: {
                    ca: Math.round(scoreCa),
                    marge: Math.round(scoreMarge),
                    dso: Math.round(scoreDso),
                    occupation: Math.round(scoreOccupation),
                    operationnel: Math.round(scoreOperationnel),
                },
                comparaison_moyenne: comparaison,
            };
        });
        societes.sort((a, b) => b.score_global - a.score_global);
        societes.forEach((s, idx) => {
            s.rang = idx + 1;
        });
        const meilleurPerformeur = societes[0];
        const aAmeliorer = societes[societes.length - 1];
        return {
            periode: {
                annee: latest[0].annee,
                mois: latest[0].mois,
            },
            nb_societes: societes.length,
            moyennes_groupe: {
                ca_total: totalCa,
                ca_moyen: Math.round(moyennesGlobales.ca_mensuel / count),
                taux_marge_moyen: Math.round(moyennesGlobales.taux_marge * 10) / 10,
                dso_moyen: Math.round(moyennesGlobales.dso_jours),
                taux_occupation_moyen: Math.round(moyennesGlobales.taux_occupation * 10) / 10,
                taux_retard_moyen: Math.round(moyennesGlobales.taux_retard * 10) / 10,
            },
            classement: societes,
            insights: {
                meilleur_performeur: meilleurPerformeur?.societe,
                a_ameliorer: aAmeliorer?.societe,
                ecart_score: meilleurPerformeur && aAmeliorer
                    ? meilleurPerformeur.score_global - aAmeliorer.score_global
                    : 0,
            },
        };
    }
};
exports.KpiService = KpiService;
exports.KpiService = KpiService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(entities_1.KpiGlobal)),
    __param(1, (0, typeorm_1.InjectRepository)(entities_1.DimSociete)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], KpiService);
//# sourceMappingURL=kpi.service.js.map
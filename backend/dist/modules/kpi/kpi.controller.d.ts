import { KpiService } from './kpi.service';
import { PeriodeFilterDto } from '../../common/dto';
export declare class KpiController {
    private readonly kpiService;
    constructor(kpiService: KpiService);
    getDashboard(filter: PeriodeFilterDto): Promise<any[]>;
    getSummary(): Promise<{
        periode: null;
        totaux: null;
        alertes: null;
        nb_societes?: undefined;
    } | {
        periode: {
            annee: any;
            mois: any;
        };
        totaux: any;
        alertes: {
            affaires_en_retard: any;
            affaires_en_depassement: any;
        };
        nb_societes: number;
    }>;
    getLatestKpis(): Promise<any[]>;
    getEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getSocietes(): Promise<import("../../database/entities").DimSociete[]>;
    getKpisBySociete(id: number, filter: PeriodeFilterDto): Promise<import("../../database/entities").KpiGlobal[]>;
    getHealthScore(filter: PeriodeFilterDto): Promise<{
        score: number;
        status: string;
        details: null;
        scores_details?: undefined;
        indicateurs?: undefined;
        totaux?: undefined;
        alertes?: undefined;
        periode?: undefined;
    } | {
        score: number;
        status: "EXCELLENT" | "BON" | "ATTENTION" | "CRITIQUE";
        scores_details: {
            commercial: number;
            rentabilite: number;
            tresorerie: number;
            operationnel: number;
        };
        indicateurs: {
            ca_realisation_pct: number;
            taux_marge: number;
            tresorerie_nette: number;
            dso_jours: number;
            taux_retard_affaires: number;
            taux_occupation: number;
        };
        totaux: {
            ca_mensuel: number;
            marge_brute: number;
            nb_affaires_en_cours: number;
            nb_affaires_en_retard: number;
            nb_affaires_en_depassement: number;
        };
        alertes: string[];
        periode: {
            annee: any;
            mois: any;
        };
        details?: undefined;
    }>;
    getDsoDpoAnalysis(filter: PeriodeFilterDto): Promise<{
        status: string;
        data: null;
        score_global?: undefined;
        dso?: undefined;
        dpo?: undefined;
        ccc?: undefined;
        bfr?: undefined;
        recommandations?: undefined;
        historique?: undefined;
        periode?: undefined;
    } | {
        status: "BON" | "CRITIQUE" | "OPTIMAL" | "A_AMELIORER";
        score_global: number;
        dso: {
            actuel: number;
            objectif: number;
            score: number;
            tendance_pct: number;
            status: string;
        };
        dpo: {
            actuel: number;
            objectif_min: number;
            objectif_max: number;
            score: number;
            tendance_pct: number;
            status: string;
        };
        ccc: {
            actuel: number;
            interpretation: string;
        };
        bfr: {
            actuel: number;
            optimisation_potentielle: number;
        };
        recommandations: {
            type: string;
            priorite: "haute" | "moyenne" | "basse";
            description: string;
            impact_estime?: number;
        }[];
        historique: {
            annee: any;
            mois: any;
            dso: number;
            dpo: number;
            bfr: number;
        }[];
        periode: {
            annee: any;
            mois: any;
        };
        data?: undefined;
    }>;
    getBenchmarkSocietes(filter: PeriodeFilterDto): Promise<{
        status: string;
        data: null;
        periode?: undefined;
        nb_societes?: undefined;
        moyennes_groupe?: undefined;
        classement?: undefined;
        insights?: undefined;
    } | {
        periode: {
            annee: any;
            mois: any;
        };
        nb_societes: number;
        moyennes_groupe: {
            ca_total: number;
            ca_moyen: number;
            taux_marge_moyen: number;
            dso_moyen: number;
            taux_occupation_moyen: number;
            taux_retard_moyen: number;
        };
        classement: {
            societe: any;
            score_global: number;
            rang: number;
            indicateurs: {
                ca_mensuel: number;
                ca_part_groupe: number;
                taux_marge: number;
                dso_jours: number;
                taux_occupation: number;
                nb_affaires_en_cours: number;
                taux_retard: number;
            };
            scores: {
                ca: number;
                marge: number;
                dso: number;
                occupation: number;
                operationnel: number;
            };
            comparaison_moyenne: {
                ca: string;
                marge: string;
                dso: string;
                occupation: string;
            };
        }[];
        insights: {
            meilleur_performeur: any;
            a_ameliorer: any;
            ecart_score: number;
        };
        status?: undefined;
        data?: undefined;
    }>;
}

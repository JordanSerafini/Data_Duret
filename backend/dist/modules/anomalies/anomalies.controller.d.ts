import { AnomaliesService } from './anomalies.service';
import { PeriodeFilterDto } from '../../common/dto';
export declare class AnomaliesController {
    private readonly anomaliesService;
    constructor(anomaliesService: AnomaliesService);
    getAllAnomalies(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getSynthese(filter: PeriodeFilterDto): Promise<{
        total: number;
        par_severite: {
            critique: number;
            haute: number;
            moyenne: number;
            basse: number;
        };
        par_categorie: {
            affaires: number;
            clients: number;
            stock: number;
        };
        par_type: Record<string, number>;
    }>;
    getEcartsBudget(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getAffairesRetard(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getImpayes(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getRisqueCredit(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getAlertesStock(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getAnomalyPatterns(filter: PeriodeFilterDto): Promise<{
        nb_patterns: number;
        nb_anomalies_total: number;
        patterns: {
            id: string;
            type: string;
            description: string;
            frequence: number;
            severite_dominante: import("./anomalies.service").Anomalie["severite"];
            tendance: "CROISSANTE" | "STABLE" | "DECROISSANTE";
            correlation: string[];
            recommandation: string;
        }[];
        synthese_types: {
            type: string;
            count: number;
            severite_max: "CRITIQUE" | "HAUTE" | "MOYENNE" | "BASSE";
        }[];
    }>;
    getRiskHeatmap(filter: PeriodeFilterDto): Promise<{
        score_global: number;
        niveau_global: "CRITIQUE" | "ELEVE" | "MODERE" | "FAIBLE";
        nb_anomalies_total: number;
        heatmap: {
            categorie: string;
            severite: import("./anomalies.service").Anomalie["severite"];
            count: number;
            score_risque: number;
            types: string[];
        }[];
        par_categorie: {
            categorie: string;
            score_risque: number;
            nb_anomalies: number;
            niveau_risque: "CRITIQUE" | "ELEVE" | "MODERE" | "FAIBLE";
            repartition: {
                critique: number;
                haute: number;
                moyenne: number;
                basse: number;
            };
        }[];
        top_risques: {
            type: string;
            categorie: string;
            severite: "CRITIQUE" | "HAUTE" | "MOYENNE" | "BASSE";
            description: string;
            entite: string | undefined;
        }[];
        recommandations: {
            categorie: string;
            priorite: "IMMEDIATE" | "HAUTE" | "MOYENNE";
            action: string;
        }[];
    }>;
    getAnomalyTrends(filter: PeriodeFilterDto): Promise<{
        synthese_actuelle: {
            total: number;
            score_risque: number;
            distribution: {
                par_severite: {
                    critique: number;
                    haute: number;
                    moyenne: number;
                    basse: number;
                };
                par_categorie: {
                    affaires: number;
                    clients: number;
                    stock: number;
                };
                par_type: Record<string, number>;
            };
        };
        zones_vigilance: {
            zone: string;
            indicateur: string;
            valeur: number;
            seuil: number;
            status: "ALERTE" | "ATTENTION" | "OK";
        }[];
        projections: {
            scenario_optimiste: {
                description: string;
                nb_anomalies_prevu: number;
                score_risque_prevu: number;
            };
            scenario_stable: {
                description: string;
                nb_anomalies_prevu: number;
                score_risque_prevu: number;
            };
            scenario_degradation: {
                description: string;
                nb_anomalies_prevu: number;
                score_risque_prevu: number;
            };
        };
        actions_prioritaires: {
            priorite: number;
            categorie: string;
            action: string;
            impact_estime: string;
        }[];
    }>;
}

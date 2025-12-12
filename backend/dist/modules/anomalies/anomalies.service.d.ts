import { Repository } from 'typeorm';
import { AggCaAffaire, AggCaClient, AggBalanceAgeeClient, AggStockElement, AggHeuresSalarie, DimAffaire, DimClient, DimSalarie, MlFeaturesClient, MlFeaturesAffaire } from '../../database/entities';
import { PeriodeFilterDto } from '../../common/dto';
export interface Anomalie {
    type: string;
    severite: 'CRITIQUE' | 'HAUTE' | 'MOYENNE' | 'BASSE';
    categorie: string;
    description: string;
    valeur?: number;
    seuil?: number;
    entite?: string;
    details?: Record<string, unknown>;
}
export declare class AnomaliesService {
    private affaireRepository;
    private clientRepository;
    private balanceRepository;
    private stockRepository;
    private dimAffaireRepository;
    private dimClientRepository;
    private heuresRepository;
    private salarieRepository;
    private mlClientRepository;
    private mlAffaireRepository;
    constructor(affaireRepository: Repository<AggCaAffaire>, clientRepository: Repository<AggCaClient>, balanceRepository: Repository<AggBalanceAgeeClient>, stockRepository: Repository<AggStockElement>, dimAffaireRepository: Repository<DimAffaire>, dimClientRepository: Repository<DimClient>, heuresRepository: Repository<AggHeuresSalarie>, salarieRepository: Repository<DimSalarie>, mlClientRepository: Repository<MlFeaturesClient>, mlAffaireRepository: Repository<MlFeaturesAffaire>);
    getAllAnomalies(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getChurnAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAffaireRiskAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getSousOccupationAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getEcartsBudget(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAffairesRetard(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getImpayes(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getRisqueCredit(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAlertesStock(filter: PeriodeFilterDto): Promise<Anomalie[]>;
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
    private getSeveriteFromRisque;
    private getSeveriteImpayes;
    private getSeveriteRisqueCredit;
    getAnomalyPatterns(filter: PeriodeFilterDto): Promise<{
        nb_patterns: number;
        nb_anomalies_total: number;
        patterns: {
            id: string;
            type: string;
            description: string;
            frequence: number;
            severite_dominante: Anomalie["severite"];
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
            severite: Anomalie["severite"];
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

import { CommercialService } from './commercial.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class CommercialController {
    private readonly commercialService;
    constructor(commercialService: CommercialService);
    getCaByPeriode(filter: PeriodeFilterDto): Promise<any[]>;
    getCaEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getCaForecast(filter: PeriodeFilterDto): Promise<{
        historical: any[];
        forecast: never[];
        trend: string;
        slope?: undefined;
        variation_pct?: undefined;
        ca_prevu_total?: undefined;
    } | {
        historical: any[];
        forecast: {
            annee: number;
            mois: number;
            ca_prevu: number;
            confidence_low: number;
            confidence_high: number;
        }[];
        trend: string;
        slope: number;
        variation_pct: number;
        ca_prevu_total: number;
    }>;
    getSegments(): Promise<any[]>;
    getClients(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getTopClients(filter: PeriodeFilterDto, limit?: number): Promise<any[]>;
    getClientSatisfactionScore(filter: PeriodeFilterDto): Promise<{
        synthese: {
            nb_clients: number;
            score_moyen: number;
            repartition: {
                tres_satisfaits: number;
                satisfaits: number;
                neutres: number;
                a_risque: number;
            };
            clients_risque_churn: number;
            taux_satisfaction: number;
        };
        clients_prioritaires: {
            client_sk: any;
            code: any;
            raison_sociale: any;
            ville: any;
            segment: any;
            score_satisfaction: number;
            status: string;
            risque_churn: string;
            scores_details: {
                fidelite: number;
                paiement: number;
                croissance: number;
                engagement: number;
            };
            indicateurs: {
                ca_cumule: number;
                variation_ca_pct: number;
                nb_affaires: number;
                retard_paiement_jours: number;
                nb_impayes: number;
                taux_avoir_pct: number;
            };
            recommandations: string[];
        }[];
        clients_fideles: {
            client_sk: any;
            code: any;
            raison_sociale: any;
            ville: any;
            segment: any;
            score_satisfaction: number;
            status: string;
            risque_churn: string;
            scores_details: {
                fidelite: number;
                paiement: number;
                croissance: number;
                engagement: number;
            };
            indicateurs: {
                ca_cumule: number;
                variation_ca_pct: number;
                nb_affaires: number;
                retard_paiement_jours: number;
                nb_impayes: number;
                taux_avoir_pct: number;
            };
            recommandations: string[];
        }[];
    }>;
    getClientById(id: number, filter: PeriodeFilterDto): Promise<{
        client: import("../../database/entities").DimClient | null;
        historique_ca: import("../../database/entities").AggCaClient[];
    }>;
    getAffaires(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getAffairesEnRetard(filter: PeriodeFilterDto): Promise<any[]>;
    getAffairesEnDepassement(filter: PeriodeFilterDto): Promise<any[]>;
    getSpiCpiAnalysis(filter: PeriodeFilterDto): Promise<{
        status: string;
        synthese: {
            nb_affaires: number;
            spi_moyen: number;
            cpi_moyen: number;
            affaires_retard_critique: number;
            affaires_depassement_critique: number;
            score_performance_global: number;
        };
        interpretation: {
            spi: string;
            cpi: string;
        };
        affaires: {
            affaire_sk: any;
            code: any;
            libelle: any;
            client: any;
            spi: number;
            cpi: number;
            status_spi: string;
            status_cpi: string;
            score_performance: number;
            avancement: {
                travaux: number;
                facturation: number;
                temporel_prevu: number;
            };
            estimations: {
                budget_initial: number;
                estimation_achèvement: number;
                variance: number;
            };
            alertes: {
                retard: any;
                depassement: any;
                niveau_risque: any;
            };
        }[];
    }>;
    getEarlyWarningAffaires(filter: PeriodeFilterDto): Promise<{
        synthese: {
            total_affaires: number;
            affaires_avec_alertes: number;
            taux_alertes: number;
            repartition_risque: {
                critique: number;
                eleve: number;
                modere: number;
            };
            montant_a_risque: any;
        };
        alertes_prioritaires: any[];
        types_alertes: {
            retard_planning: number;
            depassement_budget: number;
            erosion_marge: number;
            deadline_proche: number;
        };
    }>;
    getAffaireById(id: number): Promise<{
        affaire: import("../../database/entities").DimAffaire | null;
        kpis: import("../../database/entities").AggCaAffaire | null;
    }>;
}

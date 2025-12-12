import { Repository } from 'typeorm';
import { AggCaPeriode, AggCaClient, AggCaAffaire, DimClient, DimAffaire } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class CommercialService {
    private caPeriodeRepository;
    private caClientRepository;
    private caAffaireRepository;
    private clientRepository;
    private affaireRepository;
    constructor(caPeriodeRepository: Repository<AggCaPeriode>, caClientRepository: Repository<AggCaClient>, caAffaireRepository: Repository<AggCaAffaire>, clientRepository: Repository<DimClient>, affaireRepository: Repository<DimAffaire>);
    getCaByPeriode(filter: PeriodeFilterDto): Promise<any[]>;
    getCaEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getClients(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientById(clientId: number, filter: PeriodeFilterDto): Promise<{
        client: DimClient | null;
        historique_ca: AggCaClient[];
    }>;
    getTopClients(filter: PeriodeFilterDto, limit?: number): Promise<any[]>;
    getAffaires(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getAffaireById(affaireId: number): Promise<{
        affaire: DimAffaire | null;
        kpis: AggCaAffaire | null;
    }>;
    getAffairesEnRetard(filter: PeriodeFilterDto): Promise<any[]>;
    getAffairesEnDepassement(filter: PeriodeFilterDto): Promise<any[]>;
    getSegments(): Promise<any[]>;
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
}

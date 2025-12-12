import { TresorerieService } from './tresorerie.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class TresorerieController {
    private readonly tresorerieService;
    constructor(tresorerieService: TresorerieService);
    getSolde(filter: PeriodeFilterDto): Promise<any[]>;
    getEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getBfr(filter: PeriodeFilterDto): Promise<any[]>;
    getBalanceAgee(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getBalanceAgeeSynthese(filter: PeriodeFilterDto): Promise<any>;
    getClientsRisqueCredit(filter: PeriodeFilterDto, seuil?: number): Promise<any[]>;
    getTensionScore(filter: PeriodeFilterDto): Promise<{
        score: number;
        status: string;
        message: string;
        couleur?: undefined;
        alertes?: undefined;
        details?: undefined;
        ratios?: undefined;
        scores_details?: undefined;
        periode?: undefined;
    } | {
        score: number;
        status: string;
        couleur: string;
        alertes: string[];
        details: {
            solde_total: number;
            flux_net: number;
            encaissements: number;
            decaissements: number;
            creances_echues: number;
            dettes_echues: number;
        };
        ratios: {
            liquidite: number;
            couverture_mois: number;
            flux_decaissements: number;
        };
        scores_details: {
            liquidite: number;
            couverture: number;
            flux: number;
            tendance: number;
        };
        periode: {
            annee: any;
            mois: any;
        };
        message?: undefined;
    }>;
    getTresorerieForecast(filter: PeriodeFilterDto): Promise<{
        historical: any[];
        forecast: never[];
        trend: string;
        slope_flux?: undefined;
        variation_pct?: undefined;
        solde_prevu_3m?: undefined;
    } | {
        historical: any[];
        forecast: {
            annee: number;
            mois: number;
            flux_prevu: number;
            solde_prevu: number;
            confidence_low: number;
            confidence_high: number;
        }[];
        trend: string;
        slope_flux: number;
        variation_pct: number;
        solde_prevu_3m: number;
    }>;
}

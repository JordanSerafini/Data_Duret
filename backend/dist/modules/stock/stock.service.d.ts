import { Repository } from 'typeorm';
import { AggStockElement, DimElement } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
import { StockFilterDto } from './dto/stock-filter.dto';
export declare class StockService {
    private stockRepository;
    private elementRepository;
    constructor(stockRepository: Repository<AggStockElement>, elementRepository: Repository<DimElement>);
    getAlertes(filter: PeriodeFilterDto): Promise<any[]>;
    getAlertesRupture(filter: PeriodeFilterDto): Promise<any[]>;
    getAlertesSurstock(filter: PeriodeFilterDto): Promise<any[]>;
    getRotation(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getSynthese(filter: PeriodeFilterDto): Promise<any>;
    getValeurParFamille(filter: PeriodeFilterDto): Promise<any[]>;
    findAll(filter: StockFilterDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getFamilles(): Promise<any[]>;
    getStockPrevisions(filter: PeriodeFilterDto): Promise<{
        alertes: any[];
        synthese: {
            nb_rupture: number;
            nb_critique: number;
            nb_attention: number;
            nb_surveillance: number;
            valeur_a_risque: any;
        };
        par_niveau: {
            rupture: any[];
            critique: any[];
            attention: any[];
            surveillance: any[];
        };
    }>;
    getStockHealthScore(filter: PeriodeFilterDto): Promise<{
        score: number;
        status: string;
        details: {
            nb_total: number;
            nb_ruptures: number;
            nb_surstocks: number;
            nb_risque_15j: number;
            valeur_totale: number;
            valeur_ruptures: number;
            valeur_surstocks: number;
            rotation_moyenne: number;
            couverture_moyenne: number;
        };
        indicateurs: {
            taux_rupture: number;
            taux_surstock: number;
            taux_risque_15j: number;
            taux_valeur_risque: number;
        };
    }>;
}

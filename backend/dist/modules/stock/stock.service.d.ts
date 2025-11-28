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
}

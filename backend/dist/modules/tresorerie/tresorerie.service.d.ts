import { Repository } from 'typeorm';
import { AggTresorerie, AggBalanceAgeeClient, DimClient } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class TresorerieService {
    private tresorerieRepository;
    private balanceAgeeRepository;
    private clientRepository;
    constructor(tresorerieRepository: Repository<AggTresorerie>, balanceAgeeRepository: Repository<AggBalanceAgeeClient>, clientRepository: Repository<DimClient>);
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
    getClientsRisqueCredit(filter: PeriodeFilterDto, seuilRisque?: number): Promise<any[]>;
}

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
}

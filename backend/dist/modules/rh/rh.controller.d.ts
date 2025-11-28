import { RhService } from './rh.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class RhController {
    private readonly rhService;
    constructor(rhService: RhService);
    getProductivite(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getSyntheseMensuelle(filter: PeriodeFilterDto): Promise<any[]>;
    getTopProductifs(filter: PeriodeFilterDto, limit?: number): Promise<any[]>;
    getSalariesSousOccupes(filter: PeriodeFilterDto, seuil?: number): Promise<any[]>;
    getPostes(): Promise<any[]>;
    getQualifications(): Promise<any[]>;
    getHeuresParSalarie(id: number, filter: PeriodeFilterDto): Promise<{
        salarie: import("../../database/entities").DimSalarie | null;
        history: any[];
    }>;
}

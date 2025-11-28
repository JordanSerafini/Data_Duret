import { Repository } from 'typeorm';
import { AggHeuresSalarie, DimSalarie } from '../../database/entities';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class RhService {
    private heuresRepository;
    private salarieRepository;
    constructor(heuresRepository: Repository<AggHeuresSalarie>, salarieRepository: Repository<DimSalarie>);
    getProductivite(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getHeuresParSalarie(salarieId: number, filter: PeriodeFilterDto): Promise<{
        salarie: DimSalarie | null;
        history: any[];
    }>;
    getPostes(): Promise<any[]>;
    getQualifications(): Promise<any[]>;
    getSyntheseMensuelle(filter: PeriodeFilterDto): Promise<any[]>;
    getTopProductifs(filter: PeriodeFilterDto, limit?: number): Promise<any[]>;
    getSalariesSousOccupes(filter: PeriodeFilterDto, seuilOccupation?: number): Promise<any[]>;
    getSalaries(filter: PeriodeFilterDto): Promise<DimSalarie[]>;
}

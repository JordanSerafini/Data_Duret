import { CommercialService } from './commercial.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
export declare class CommercialController {
    private readonly commercialService;
    constructor(commercialService: CommercialService);
    getCaByPeriode(filter: PeriodeFilterDto): Promise<any[]>;
    getCaEvolution(filter: PeriodeFilterDto): Promise<any[]>;
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
    getAffaireById(id: number): Promise<{
        affaire: import("../../database/entities").DimAffaire | null;
        kpis: import("../../database/entities").AggCaAffaire | null;
    }>;
}

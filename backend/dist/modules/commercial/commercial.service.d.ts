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
}

import { Repository } from 'typeorm';
import { MlFeaturesClient, MlFeaturesAffaire, DimClient, DimAffaire } from '../../database/entities';
import { PaginationDto } from '../../common/dto';
export declare class MlService {
    private clientFeaturesRepository;
    private affaireFeaturesRepository;
    private clientRepository;
    private affaireRepository;
    constructor(clientFeaturesRepository: Repository<MlFeaturesClient>, affaireFeaturesRepository: Repository<MlFeaturesAffaire>, clientRepository: Repository<DimClient>, affaireRepository: Repository<DimAffaire>);
    getClientSegmentation(pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientChurnRisk(seuilRisque: number | undefined, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientsFortPotentiel(seuilPotentiel: number | undefined, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientFeatures(clientId: number): Promise<{
        client: DimClient | null;
        features: MlFeaturesClient | null;
    }>;
    getSegmentationSynthese(): Promise<any[]>;
    getClientsParSegment(segment: string, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getAffairePredictions(pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getAffaireFeatures(affaireId: number): Promise<{
        affaire: DimAffaire | null;
        features: MlFeaturesAffaire | null;
    }>;
    getAffairesRisqueDepassement(seuilRisque: number | undefined, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getStatistiquesML(): Promise<{
        clients: any;
        affaires: any;
    }>;
    getClientsWithHealthScore(pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getHealthScoreSummary(): Promise<any>;
}

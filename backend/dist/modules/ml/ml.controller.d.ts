import { MlService } from './ml.service';
import { PaginationDto } from '../../common/dto';
export declare class MlController {
    private readonly mlService;
    constructor(mlService: MlService);
    getStatistiquesML(): Promise<{
        clients: any;
        affaires: any;
    }>;
    getClientSegmentation(pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
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
    getClientChurnRisk(seuil: number, page?: number, limit?: number): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientsFortPotentiel(seuil: number, page?: number, limit?: number): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getClientFeatures(id: number): Promise<{
        client: import("../../database/entities").DimClient | null;
        features: import("../../database/entities").MlFeaturesClient | null;
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
    getAffairesRisqueDepassement(seuil: number, page?: number, limit?: number): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getAffaireFeatures(id: number): Promise<{
        affaire: import("../../database/entities").DimAffaire | null;
        features: import("../../database/entities").MlFeaturesAffaire | null;
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

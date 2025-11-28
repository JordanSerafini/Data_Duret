import { AnomaliesService } from './anomalies.service';
import { PeriodeFilterDto } from '../../common/dto';
export declare class AnomaliesController {
    private readonly anomaliesService;
    constructor(anomaliesService: AnomaliesService);
    getAllAnomalies(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getSynthese(filter: PeriodeFilterDto): Promise<{
        total: number;
        par_severite: {
            critique: number;
            haute: number;
            moyenne: number;
            basse: number;
        };
        par_categorie: {
            affaires: number;
            clients: number;
            stock: number;
        };
        par_type: Record<string, number>;
    }>;
    getEcartsBudget(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getAffairesRetard(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getImpayes(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getRisqueCredit(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
    getAlertesStock(filter: PeriodeFilterDto): Promise<import("./anomalies.service").Anomalie[]>;
}

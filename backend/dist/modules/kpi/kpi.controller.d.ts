import { KpiService } from './kpi.service';
import { PeriodeFilterDto } from '../../common/dto';
export declare class KpiController {
    private readonly kpiService;
    constructor(kpiService: KpiService);
    getDashboard(filter: PeriodeFilterDto): Promise<any[]>;
    getSummary(): Promise<{
        periode: null;
        totaux: null;
        alertes: null;
        nb_societes?: undefined;
    } | {
        periode: {
            annee: any;
            mois: any;
        };
        totaux: any;
        alertes: {
            affaires_en_retard: any;
            affaires_en_depassement: any;
        };
        nb_societes: number;
    }>;
    getLatestKpis(): Promise<any[]>;
    getEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getSocietes(): Promise<import("../../database/entities").DimSociete[]>;
    getKpisBySociete(id: number, filter: PeriodeFilterDto): Promise<import("../../database/entities").KpiGlobal[]>;
}

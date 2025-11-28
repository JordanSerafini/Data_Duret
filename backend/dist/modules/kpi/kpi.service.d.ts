import { Repository } from 'typeorm';
import { KpiGlobal, DimSociete } from '../../database/entities';
import { PeriodeFilterDto } from '../../common/dto';
export declare class KpiService {
    private kpiRepository;
    private societeRepository;
    constructor(kpiRepository: Repository<KpiGlobal>, societeRepository: Repository<DimSociete>);
    getDashboard(filter: PeriodeFilterDto): Promise<any[]>;
    getKpisBySociete(societeId: number, filter: PeriodeFilterDto): Promise<KpiGlobal[]>;
    getEvolution(filter: PeriodeFilterDto): Promise<any[]>;
    getSocietes(): Promise<DimSociete[]>;
    getLatestKpis(): Promise<any[]>;
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
}

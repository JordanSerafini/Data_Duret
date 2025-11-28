import { Repository } from 'typeorm';
import { AggCaAffaire, AggCaClient, AggBalanceAgeeClient, AggStockElement, AggHeuresSalarie, DimAffaire, DimClient, DimSalarie, MlFeaturesClient, MlFeaturesAffaire } from '../../database/entities';
import { PeriodeFilterDto } from '../../common/dto';
export interface Anomalie {
    type: string;
    severite: 'CRITIQUE' | 'HAUTE' | 'MOYENNE' | 'BASSE';
    categorie: string;
    description: string;
    valeur?: number;
    seuil?: number;
    entite?: string;
    details?: Record<string, unknown>;
}
export declare class AnomaliesService {
    private affaireRepository;
    private clientRepository;
    private balanceRepository;
    private stockRepository;
    private dimAffaireRepository;
    private dimClientRepository;
    private heuresRepository;
    private salarieRepository;
    private mlClientRepository;
    private mlAffaireRepository;
    constructor(affaireRepository: Repository<AggCaAffaire>, clientRepository: Repository<AggCaClient>, balanceRepository: Repository<AggBalanceAgeeClient>, stockRepository: Repository<AggStockElement>, dimAffaireRepository: Repository<DimAffaire>, dimClientRepository: Repository<DimClient>, heuresRepository: Repository<AggHeuresSalarie>, salarieRepository: Repository<DimSalarie>, mlClientRepository: Repository<MlFeaturesClient>, mlAffaireRepository: Repository<MlFeaturesAffaire>);
    getAllAnomalies(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getChurnAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAffaireRiskAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getSousOccupationAlerts(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getEcartsBudget(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAffairesRetard(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getImpayes(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getRisqueCredit(filter: PeriodeFilterDto): Promise<Anomalie[]>;
    getAlertesStock(filter: PeriodeFilterDto): Promise<Anomalie[]>;
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
    private getSeveriteFromRisque;
    private getSeveriteImpayes;
    private getSeveriteRisqueCredit;
}

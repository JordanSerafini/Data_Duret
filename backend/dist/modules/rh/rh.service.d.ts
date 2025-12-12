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
    getWorkforceEfficiencyScore(filter: PeriodeFilterDto): Promise<{
        score_global: number;
        status: string;
        synthese: {
            nb_salaries: number;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
        };
        distribution: {};
        salaries: never[];
        recommandations: never[];
        top_performers?: undefined;
        a_accompagner?: undefined;
    } | {
        score_global: number;
        status: "EXCELLENT" | "BON" | "MOYEN" | "A_AMELIORER";
        synthese: {
            cout_par_heure_productive: number;
            nb_salaries: number;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            taux_productivite_moyen: number;
            taux_occupation_moyen: number;
        };
        distribution: {
            excellent: number;
            bon: number;
            moyen: number;
            a_ameliorer: number;
        };
        salaries: {
            id: any;
            matricule: any;
            nom: any;
            poste: any;
            qualification: any;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            cout_horaire_moyen: number;
            nb_affaires: number;
            scores: {
                productivite: number;
                occupation: number;
                polyvalence: number;
                regularite: number;
                global: number;
            };
            status: "EXCELLENT" | "BON" | "MOYEN" | "A_AMELIORER";
            indicateurs: {
                taux_occupation: number;
                taux_productivite: number;
                polyvalence_mensuelle: number;
                variation_pct: number;
            };
        }[];
        top_performers: {
            id: any;
            matricule: any;
            nom: any;
            poste: any;
            qualification: any;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            cout_horaire_moyen: number;
            nb_affaires: number;
            scores: {
                productivite: number;
                occupation: number;
                polyvalence: number;
                regularite: number;
                global: number;
            };
            status: "EXCELLENT" | "BON" | "MOYEN" | "A_AMELIORER";
            indicateurs: {
                taux_occupation: number;
                taux_productivite: number;
                polyvalence_mensuelle: number;
                variation_pct: number;
            };
        }[];
        a_accompagner: {
            id: any;
            matricule: any;
            nom: any;
            poste: any;
            qualification: any;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            cout_horaire_moyen: number;
            nb_affaires: number;
            scores: {
                productivite: number;
                occupation: number;
                polyvalence: number;
                regularite: number;
                global: number;
            };
            status: "EXCELLENT" | "BON" | "MOYEN" | "A_AMELIORER";
            indicateurs: {
                taux_occupation: number;
                taux_productivite: number;
                polyvalence_mensuelle: number;
                variation_pct: number;
            };
        }[];
        recommandations: {
            type: string;
            priorite: "HAUTE" | "MOYENNE" | "BASSE";
            message: string;
            impact: string;
        }[];
    }>;
    getCostAnalysis(filter: PeriodeFilterDto): Promise<{
        synthese: {
            cout_total: number;
            heures_productives: number;
            cout_par_heure_productive: number;
            nb_postes: number;
            nb_qualifications: number;
        };
        par_poste: {
            poste: any;
            nb_salaries: number;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            cout_horaire_moyen: number;
            cout_par_heure_productive: number;
            productivite_moyenne: number;
            efficience: number;
        }[];
        par_qualification: {
            qualification: any;
            nb_salaries: number;
            heures_totales: number;
            cout_total: number;
            cout_horaire_moyen: number;
            productivite_moyenne: number;
        }[];
        evolution: {
            annee: any;
            mois: any;
            nb_salaries: number;
            heures_totales: number;
            heures_productives: number;
            cout_total: number;
            productivite_moyenne: number;
        }[];
    }>;
}

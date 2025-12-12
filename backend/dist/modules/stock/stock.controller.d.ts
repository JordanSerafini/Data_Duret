import { StockService } from './stock.service';
import { PeriodeFilterDto, PaginationDto } from '../../common/dto';
import { StockFilterDto } from './dto/stock-filter.dto';
export declare class StockController {
    private readonly stockService;
    constructor(stockService: StockService);
    getStocks(filter: StockFilterDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getFamilles(): Promise<any[]>;
    getAlertes(filter: PeriodeFilterDto): Promise<any[]>;
    getAlertesRupture(filter: PeriodeFilterDto): Promise<any[]>;
    getAlertesSurstock(filter: PeriodeFilterDto): Promise<any[]>;
    getRotation(filter: PeriodeFilterDto, pagination: PaginationDto): Promise<{
        data: any[];
        meta: {
            total: number;
            page: number;
            limit: number;
            totalPages: number;
        };
    }>;
    getSynthese(filter: PeriodeFilterDto): Promise<any>;
    getValeurParFamille(filter: PeriodeFilterDto): Promise<any[]>;
    getStockPrevisions(filter: PeriodeFilterDto): Promise<{
        alertes: any[];
        synthese: {
            nb_rupture: number;
            nb_critique: number;
            nb_attention: number;
            nb_surveillance: number;
            valeur_a_risque: any;
        };
        par_niveau: {
            rupture: any[];
            critique: any[];
            attention: any[];
            surveillance: any[];
        };
    }>;
    getStockHealthScore(filter: PeriodeFilterDto): Promise<{
        score: number;
        status: string;
        details: {
            nb_total: number;
            nb_ruptures: number;
            nb_surstocks: number;
            nb_risque_15j: number;
            valeur_totale: number;
            valeur_ruptures: number;
            valeur_surstocks: number;
            rotation_moyenne: number;
            couverture_moyenne: number;
        };
        indicateurs: {
            taux_rupture: number;
            taux_surstock: number;
            taux_risque_15j: number;
            taux_valeur_risque: number;
        };
    }>;
    getAbcXyzAnalysis(filter: PeriodeFilterDto): Promise<{
        synthese: {
            nb_articles: number;
            valeur_totale: number;
            repartition_abc: {
                A: number;
                B: number;
                C: number;
            };
            repartition_xyz: {
                X: number;
                Y: number;
                Z: number;
            };
            valeur_par_abc?: undefined;
            pourcentage_valeur_abc?: undefined;
        };
        matrice: {};
        articles: never[];
        recommandations: never[];
    } | {
        synthese: {
            nb_articles: number;
            valeur_totale: number;
            repartition_abc: {
                A: number;
                B: number;
                C: number;
            };
            repartition_xyz: {
                X: number;
                Y: number;
                Z: number;
            };
            valeur_par_abc: {
                A: number;
                B: number;
                C: number;
            };
            pourcentage_valeur_abc: {
                A: number;
                B: number;
                C: number;
            };
        };
        matrice: Record<string, {
            count: number;
            valeur: number;
            articles: any[];
        }>;
        articles: any[];
        recommandations: {
            type: string;
            priorite: "HAUTE" | "MOYENNE" | "BASSE";
            classe: string;
            message: string;
            nb_articles: number;
        }[];
    }>;
    getReorderRecommendations(filter: PeriodeFilterDto): Promise<{
        synthese: {
            nb_articles_total: number;
            nb_actions_requises: number;
            par_urgence: {
                immediat: number;
                urgent: number;
                planifie: number;
            };
            budget_estime: {
                immediat: number;
                urgent: number;
                total: number;
            };
        };
        actions_requises: {
            id: any;
            code: any;
            designation: any;
            famille: any;
            stock_actuel: number;
            stock_minimum: number;
            stock_securite: number;
            point_commande: number;
            eoq: number;
            conso_journaliere: number;
            jours_avant_rop: number;
            urgence: "IMMEDIAT" | "URGENT" | "PLANIFIE" | "OK";
            action: string;
            quantite_recommandee: number;
            cout_estime: number;
            pmp: number;
            rotation: number;
        }[];
        tous_articles: {
            id: any;
            code: any;
            designation: any;
            famille: any;
            stock_actuel: number;
            stock_minimum: number;
            stock_securite: number;
            point_commande: number;
            eoq: number;
            conso_journaliere: number;
            jours_avant_rop: number;
            urgence: "IMMEDIAT" | "URGENT" | "PLANIFIE" | "OK";
            action: string;
            quantite_recommandee: number;
            cout_estime: number;
            pmp: number;
            rotation: number;
        }[];
    }>;
}

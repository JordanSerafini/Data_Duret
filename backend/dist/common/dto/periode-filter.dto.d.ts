export declare enum NiveauAgregation {
    JOUR = "JOUR",
    SEMAINE = "SEMAINE",
    MOIS = "MOIS",
    TRIMESTRE = "TRIMESTRE",
    ANNEE = "ANNEE"
}
export declare class PeriodeFilterDto {
    annee?: number;
    mois?: number;
    trimestre?: number;
    societeId?: number;
    niveau?: NiveauAgregation;
    seuil?: number;
    limit?: number;
}

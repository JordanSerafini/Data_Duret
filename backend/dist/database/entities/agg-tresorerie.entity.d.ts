export declare class AggTresorerie {
    id: number;
    societeSk: number;
    annee: number;
    mois: number;
    jour: number;
    niveauAgregation: string;
    soldeBanque: number;
    soldeCaisse: number;
    soldeTotal: number;
    encaissements: number;
    decaissements: number;
    fluxNet: number;
    creancesClients: number;
    creancesEchues: number;
    dettesFournisseurs: number;
    dettesEchues: number;
    bfrEstime: number;
    lastUpdated: Date;
}

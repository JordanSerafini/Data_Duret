import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'ml_features_affaire', schema: 'gold' })
@Index(['affaireSk'])
export class MlFeaturesAffaire {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'affaire_sk', nullable: true })
  affaireSk: number;

  @Column({ name: 'date_extraction', type: 'date' })
  dateExtraction: Date;

  // Features Affaire
  @Column({ name: 'type_affaire', length: 30, nullable: true })
  typeAffaire: string;

  @Column({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, nullable: true })
  montantCommande: number;

  @Column({ name: 'montant_log', type: 'numeric', precision: 10, scale: 4, nullable: true })
  montantLog: number;

  @Column({ name: 'duree_prevue_jours', nullable: true })
  dureePrevueJours: number;

  @Column({ name: 'nb_lots', nullable: true })
  nbLots: number;

  // Features Client
  @Column({ name: 'client_anciennete_mois', nullable: true })
  clientAncienneteMois: number;

  @Column({ name: 'client_ca_historique', type: 'numeric', precision: 15, scale: 2, nullable: true })
  clientCaHistorique: number;

  @Column({ name: 'client_nb_affaires_historique', nullable: true })
  clientNbAffairesHistorique: number;

  @Column({ name: 'client_marge_moyenne_historique', type: 'numeric', precision: 5, scale: 2, nullable: true })
  clientMargeMoyenneHistorique: number;

  // Features Localisation
  @Column({ name: 'distance_siege_km', type: 'numeric', precision: 8, scale: 2, nullable: true })
  distanceSiegeKm: number;

  @Column({ name: 'departement', length: 3, nullable: true })
  departement: string;

  @Column({ name: 'zone_geographique', length: 20, nullable: true })
  zoneGeographique: string;

  // Features Temporelles
  @Column({ name: 'mois_demarrage', nullable: true })
  moisDemarrage: number;

  @Column({ name: 'trimestre_demarrage', nullable: true })
  trimestreDemarrage: number;

  // Features Ressources
  @Column({ name: 'nb_salaries_affectes', nullable: true })
  nbSalariesAffectes: number;

  @Column({ name: 'heures_budget', type: 'numeric', precision: 10, scale: 2, nullable: true })
  heuresBudget: number;

  @Column({ name: 'ratio_mo_montant', type: 'numeric', precision: 8, scale: 4, nullable: true })
  ratioMoMontant: number;

  // Target Variables
  @Column({ name: 'marge_reelle_pct', type: 'numeric', precision: 5, scale: 2, nullable: true })
  margeReellePct: number;

  @Column({ name: 'ecart_budget_heures_pct', type: 'numeric', precision: 6, scale: 2, nullable: true })
  ecartBudgetHeuresPct: number;

  @Column({ name: 'retard_jours', nullable: true })
  retardJours: number;

  // Predictions
  @Column({ name: 'marge_predite_pct', type: 'numeric', precision: 5, scale: 2, nullable: true })
  margePreditePct: number;

  @Column({ name: 'risque_depassement_score', nullable: true })
  risqueDepassementScore: number;
}

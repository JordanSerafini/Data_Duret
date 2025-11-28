import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'ml_features_client', schema: 'gold' })
@Index(['clientSk'])
@Index(['segmentValeur', 'segmentComportement'])
export class MlFeaturesClient {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'client_sk', nullable: true })
  clientSk: number;

  @Column({ name: 'date_extraction', type: 'date' })
  dateExtraction: Date;

  // Features CA
  @Column({ name: 'ca_12m', type: 'numeric', precision: 15, scale: 2, nullable: true })
  ca12m: number;

  @Column({ name: 'ca_6m', type: 'numeric', precision: 15, scale: 2, nullable: true })
  ca6m: number;

  @Column({ name: 'ca_3m', type: 'numeric', precision: 15, scale: 2, nullable: true })
  ca3m: number;

  @Column({ name: 'ca_1m', type: 'numeric', precision: 15, scale: 2, nullable: true })
  ca1m: number;

  @Column({ name: 'tendance_ca', length: 20, nullable: true })
  tendanceCa: string;

  @Column({ name: 'volatilite_ca', type: 'numeric', precision: 8, scale: 4, nullable: true })
  volatiliteCa: number;

  // Features Comportement
  @Column({ name: 'nb_commandes_12m', nullable: true })
  nbCommandes12m: number;

  @Column({ name: 'frequence_commande_jours', type: 'numeric', precision: 6, scale: 1, nullable: true })
  frequenceCommandeJours: number;

  @Column({ name: 'recence_derniere_commande_jours', nullable: true })
  recenceDerniereCommandeJours: number;

  @Column({ name: 'panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true })
  panierMoyen: number;

  @Column({ name: 'panier_max', type: 'numeric', precision: 15, scale: 2, nullable: true })
  panierMax: number;

  @Column({ name: 'panier_min', type: 'numeric', precision: 15, scale: 2, nullable: true })
  panierMin: number;

  // Features Paiement
  @Column({ name: 'delai_paiement_moyen_jours', nullable: true })
  delaiPaiementMoyenJours: number;

  @Column({ name: 'nb_retards_paiement_12m', nullable: true })
  nbRetardsPaiement12m: number;

  @Column({ name: 'taux_impayes', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxImpayes: number;

  // Features Fidélité
  @Column({ name: 'anciennete_mois', nullable: true })
  ancienneteMois: number;

  @Column({ name: 'nb_affaires_total', nullable: true })
  nbAffairesTotal: number;

  @Column({ name: 'type_affaires_principal', length: 30, nullable: true })
  typeAffairesPrincipal: string;

  // Scores
  @Column({ name: 'score_rfm', nullable: true })
  scoreRfm: number;

  @Column({ name: 'score_risque', nullable: true })
  scoreRisque: number;

  @Column({ name: 'score_potentiel', nullable: true })
  scorePotentiel: number;

  // Classification
  @Column({ name: 'segment_valeur', length: 20, nullable: true })
  segmentValeur: string;

  @Column({ name: 'segment_comportement', length: 20, nullable: true })
  segmentComportement: string;

  @Column({ name: 'segment_risque', length: 20, nullable: true })
  segmentRisque: string;

  @Column({ name: 'probabilite_churn', type: 'numeric', precision: 5, scale: 4, nullable: true })
  probabiliteChurn: number;
}

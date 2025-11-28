import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_ca_client', schema: 'gold' })
@Index(['clientSk'])
@Index(['segmentCa'])
export class AggCaClient {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'client_sk', nullable: true })
  clientSk: number;

  @Column()
  annee: number;

  // Mesures CA
  @Column({ name: 'ca_cumule', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caCumule: number;

  @Column({ name: 'ca_n_moins_1', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caNMoins1: number;

  @Column({ name: 'variation_ca_pct', type: 'numeric', precision: 6, scale: 2, nullable: true })
  variationCaPct: number;

  // Comptages
  @Column({ name: 'nb_affaires', default: 0 })
  nbAffaires: number;

  @Column({ name: 'nb_factures', default: 0 })
  nbFactures: number;

  @Column({ name: 'nb_avoirs', default: 0 })
  nbAvoirs: number;

  // Marges
  @Column({ name: 'marge_brute', type: 'numeric', precision: 15, scale: 2, default: 0 })
  margeBrute: number;

  @Column({ name: 'taux_marge', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxMarge: number;

  // Paiements
  @Column({ name: 'encours_actuel', type: 'numeric', precision: 15, scale: 2, default: 0 })
  encoursActuel: number;

  @Column({ name: 'retard_paiement_moyen_jours', nullable: true })
  retardPaiementMoyenJours: number;

  @Column({ name: 'nb_impayes', default: 0 })
  nbImpayes: number;

  // Scoring
  @Column({ name: 'segment_ca', length: 20, nullable: true })
  segmentCa: string;

  @Column({ name: 'score_fidelite', nullable: true })
  scoreFidelite: number;

  @Column({ name: 'potentiel_croissance', length: 20, nullable: true })
  potentielCroissance: string;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

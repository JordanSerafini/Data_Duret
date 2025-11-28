import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_tresorerie', schema: 'gold' })
@Index(['societeSk'])
@Index(['annee', 'mois'])
export class AggTresorerie {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column()
  annee: number;

  @Column()
  mois: number;

  @Column({ nullable: true })
  jour: number;

  @Column({ name: 'niveau_agregation', length: 20 })
  niveauAgregation: string;

  // Soldes
  @Column({ name: 'solde_banque', type: 'numeric', precision: 15, scale: 2, default: 0 })
  soldeBanque: number;

  @Column({ name: 'solde_caisse', type: 'numeric', precision: 15, scale: 2, default: 0 })
  soldeCaisse: number;

  @Column({ name: 'solde_total', type: 'numeric', precision: 15, scale: 2, nullable: true })
  soldeTotal: number;

  // Flux
  @Column({ name: 'encaissements', type: 'numeric', precision: 15, scale: 2, default: 0 })
  encaissements: number;

  @Column({ name: 'decaissements', type: 'numeric', precision: 15, scale: 2, default: 0 })
  decaissements: number;

  @Column({ name: 'flux_net', type: 'numeric', precision: 15, scale: 2, nullable: true })
  fluxNet: number;

  // Créances / Dettes
  @Column({ name: 'creances_clients', type: 'numeric', precision: 15, scale: 2, default: 0 })
  creancesClients: number;

  @Column({ name: 'creances_echues', type: 'numeric', precision: 15, scale: 2, default: 0 })
  creancesEchues: number;

  @Column({ name: 'dettes_fournisseurs', type: 'numeric', precision: 15, scale: 2, default: 0 })
  dettesFournisseurs: number;

  @Column({ name: 'dettes_echues', type: 'numeric', precision: 15, scale: 2, default: 0 })
  dettesEchues: number;

  // BFR
  @Column({ name: 'bfr_estime', type: 'numeric', precision: 15, scale: 2, nullable: true })
  bfrEstime: number;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_balance_agee_client', schema: 'gold' })
@Index(['clientSk'])
export class AggBalanceAgeeClient {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'client_sk', nullable: true })
  clientSk: number;

  @Column({ name: 'date_calcul', type: 'date' })
  dateCalcul: Date;

  // Tranches d'âge
  @Column({ name: 'non_echu', type: 'numeric', precision: 15, scale: 2, default: 0 })
  nonEchu: number;

  @Column({ name: 'echu_0_30j', type: 'numeric', precision: 15, scale: 2, default: 0 })
  echu0_30j: number;

  @Column({ name: 'echu_31_60j', type: 'numeric', precision: 15, scale: 2, default: 0 })
  echu31_60j: number;

  @Column({ name: 'echu_61_90j', type: 'numeric', precision: 15, scale: 2, default: 0 })
  echu61_90j: number;

  @Column({ name: 'echu_plus_90j', type: 'numeric', precision: 15, scale: 2, default: 0 })
  echuPlus90j: number;

  @Column({ name: 'total_creances', type: 'numeric', precision: 15, scale: 2, nullable: true })
  totalCreances: number;

  @Column({ name: 'total_echu', type: 'numeric', precision: 15, scale: 2, nullable: true })
  totalEchu: number;

  // Indicateurs
  @Column({ name: 'dso_jours', nullable: true })
  dsoJours: number;

  @Column({ name: 'taux_recouvrement', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxRecouvrement: number;

  @Column({ name: 'score_risque_credit', nullable: true })
  scoreRisqueCredit: number;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

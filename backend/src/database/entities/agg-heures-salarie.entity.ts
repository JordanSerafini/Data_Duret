import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_heures_salarie', schema: 'gold' })
@Index(['salarieSk'])
@Index(['annee', 'mois'])
export class AggHeuresSalarie {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'salarie_sk', nullable: true })
  salarieSk: number;

  @Column()
  annee: number;

  @Column({ nullable: true })
  mois: number;

  // Heures
  @Column({ name: 'heures_normales', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresNormales: number;

  @Column({ name: 'heures_supplementaires', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresSupplementaires: number;

  @Column({ name: 'heures_total', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresTotal: number;

  @Column({ name: 'heures_theoriques', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresTheoriques: number;

  @Column({ name: 'taux_occupation', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxOccupation: number;

  // Affectation
  @Column({ name: 'heures_productives', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresProductives: number;

  @Column({ name: 'heures_non_productives', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresNonProductives: number;

  @Column({ name: 'taux_productivite', type: 'numeric', precision: 10, scale: 2, nullable: true })
  tauxProductivite: number;

  @Column({ name: 'nb_affaires_travaillees', default: 0 })
  nbAffairesTravaillees: number;

  // Coûts
  @Column({ name: 'cout_brut', type: 'numeric', precision: 12, scale: 2, default: 0 })
  coutBrut: number;

  @Column({ name: 'cout_charge', type: 'numeric', precision: 12, scale: 2, default: 0 })
  coutCharge: number;

  @Column({ name: 'indemnites', type: 'numeric', precision: 10, scale: 2, default: 0 })
  indemnites: number;

  @Column({ name: 'cout_total', type: 'numeric', precision: 12, scale: 2, default: 0 })
  coutTotal: number;

  @Column({ name: 'cout_horaire_moyen', type: 'numeric', precision: 8, scale: 2, nullable: true })
  coutHoraireMoyen: number;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

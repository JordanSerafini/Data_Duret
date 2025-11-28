import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'dim_salarie', schema: 'silver' })
@Index(['salarieNk', 'isCurrent'])
@Index(['matricule'])
export class DimSalarie {
  @PrimaryGeneratedColumn({ name: 'salarie_sk' })
  salarieSk: number;

  @Column({ name: 'salarie_nk', length: 30 })
  salarieNk: string;

  @Column({ name: 'source_system', length: 20, default: 'MDE_ERP' })
  sourceSystem: string;

  @Column({ name: 'source_id', nullable: true })
  sourceId: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ length: 20, nullable: true })
  matricule: string;

  @Column({ length: 50, nullable: true })
  nom: string;

  @Column({ length: 50, nullable: true })
  prenom: string;

  @Column({ name: 'nom_complet', length: 100, nullable: true })
  nomComplet: string;

  @Column({ name: 'date_naissance', type: 'date', nullable: true })
  dateNaissance: Date;

  @Column({ nullable: true })
  age: number;

  @Column({ name: 'date_entree', type: 'date', nullable: true })
  dateEntree: Date;

  @Column({ name: 'date_sortie', type: 'date', nullable: true })
  dateSortie: Date;

  @Column({ name: 'anciennete_mois', nullable: true })
  ancienneteMois: number;

  @Column({ length: 50, nullable: true })
  poste: string;

  @Column({ name: 'categorie_poste', length: 30, nullable: true })
  categoriePoste: string;

  @Column({ length: 30, nullable: true })
  qualification: string;

  @Column({ nullable: true })
  coefficient: number;

  @Column({ name: 'taux_horaire', type: 'numeric', precision: 10, scale: 2, nullable: true })
  tauxHoraire: number;

  @Column({ name: 'cout_horaire_charge', type: 'numeric', precision: 10, scale: 2, nullable: true })
  coutHoraireCharge: number;

  @Column({ name: 'responsable_sk', nullable: true })
  responsableSk: number;

  @Column({ name: 'est_actif', nullable: true })
  estActif: boolean;

  @Column({ name: 'is_current', default: true })
  isCurrent: boolean;

  @Column({ name: 'valid_from', type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ name: 'valid_to', type: 'timestamp', nullable: true })
  validTo: Date;
}

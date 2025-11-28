import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'dim_affaire', schema: 'silver' })
@Index(['affaireNk', 'isCurrent'])
@Index(['code'])
@Index(['etat'])
@Index(['clientSk'])
export class DimAffaire {
  @PrimaryGeneratedColumn({ name: 'affaire_sk' })
  affaireSk: number;

  @Column({ name: 'affaire_nk', length: 30 })
  affaireNk: string;

  @Column({ name: 'source_system', length: 20, default: 'MDE_ERP' })
  sourceSystem: string;

  @Column({ name: 'source_id', nullable: true })
  sourceId: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'client_sk', nullable: true })
  clientSk: number;

  @Column({ name: 'commercial_sk', nullable: true })
  commercialSk: number;

  @Column({ name: 'responsable_sk', nullable: true })
  responsableSk: number;

  @Column({ length: 20, nullable: true })
  code: string;

  @Column({ length: 200, nullable: true })
  libelle: string;

  @Column({ length: 20, nullable: true })
  etat: string;

  @Column({ name: 'etat_groupe', length: 20, nullable: true })
  etatGroupe: string;

  @Column({ name: 'type_affaire', length: 30, nullable: true })
  typeAffaire: string;

  @Column({ name: 'date_creation', type: 'date', nullable: true })
  dateCreation: Date;

  @Column({ name: 'date_debut_prevue', type: 'date', nullable: true })
  dateDebutPrevue: Date;

  @Column({ name: 'date_fin_prevue', type: 'date', nullable: true })
  dateFinPrevue: Date;

  @Column({ name: 'date_debut_reelle', type: 'date', nullable: true })
  dateDebutReelle: Date;

  @Column({ name: 'date_fin_reelle', type: 'date', nullable: true })
  dateFinReelle: Date;

  @Column({ name: 'duree_prevue_jours', nullable: true })
  dureePrevueJours: number;

  @Column({ name: 'duree_reelle_jours', nullable: true })
  dureeReelleJours: number;

  @Column({ name: 'adresse_chantier', type: 'text', nullable: true })
  adresseChantier: string;

  @Column({ name: 'code_postal_chantier', length: 10, nullable: true })
  codePostalChantier: string;

  @Column({ name: 'ville_chantier', length: 100, nullable: true })
  villeChantier: string;

  @Column({ name: 'departement_chantier', length: 3, nullable: true })
  departementChantier: string;

  @Column({ name: 'region_chantier', length: 50, nullable: true })
  regionChantier: string;

  @Column({ name: 'montant_devis', type: 'numeric', precision: 15, scale: 2, nullable: true })
  montantDevis: number;

  @Column({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, nullable: true })
  montantCommande: number;

  @Column({ name: 'budget_heures', type: 'numeric', precision: 10, scale: 2, nullable: true })
  budgetHeures: number;

  @Column({ name: 'marge_prevue_pct', type: 'numeric', precision: 5, scale: 2, nullable: true })
  margePrevuePct: number;

  @Column({ name: 'is_current', default: true })
  isCurrent: boolean;

  @Column({ name: 'valid_from', type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ name: 'valid_to', type: 'timestamp', nullable: true })
  validTo: Date;
}

import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'dim_element', schema: 'silver' })
@Index(['elementNk', 'isCurrent'])
@Index(['typeElement'])
@Index(['famille'])
export class DimElement {
  @PrimaryGeneratedColumn({ name: 'element_sk' })
  elementSk: number;

  @Column({ name: 'element_nk', length: 40 })
  elementNk: string;

  @Column({ name: 'source_system', length: 20, default: 'MDE_ERP' })
  sourceSystem: string;

  @Column({ name: 'source_id', nullable: true })
  sourceId: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ length: 30, nullable: true })
  code: string;

  @Column({ length: 200, nullable: true })
  designation: string;

  @Column({ name: 'type_element', length: 20, nullable: true })
  typeElement: string;

  @Column({ length: 50, nullable: true })
  famille: string;

  @Column({ name: 'sous_famille', length: 50, nullable: true })
  sousFamille: string;

  @Column({ length: 10, nullable: true })
  unite: string;

  @Column({ name: 'prix_achat_standard', type: 'numeric', precision: 15, scale: 4, nullable: true })
  prixAchatStandard: number;

  @Column({ name: 'prix_vente_standard', type: 'numeric', precision: 15, scale: 4, nullable: true })
  prixVenteStandard: number;

  @Column({ name: 'marge_standard_pct', type: 'numeric', precision: 6, scale: 2, nullable: true })
  margeStandardPct: number;

  @Column({ name: 'temps_unitaire_heures', type: 'numeric', precision: 10, scale: 4, nullable: true })
  tempsUnitaireHeures: number;

  @Column({ name: 'compte_achat', length: 13, nullable: true })
  compteAchat: string;

  @Column({ name: 'compte_vente', length: 13, nullable: true })
  compteVente: string;

  @Column({ name: 'fournisseur_principal_sk', nullable: true })
  fournisseurPrincipalSk: number;

  @Column({ name: 'est_actif', nullable: true })
  estActif: boolean;

  @Column({ name: 'is_current', default: true })
  isCurrent: boolean;

  @Column({ name: 'valid_from', type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ name: 'valid_to', type: 'timestamp', nullable: true })
  validTo: Date;
}

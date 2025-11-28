import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'dim_client', schema: 'silver' })
@Index(['clientNk', 'isCurrent'])
@Index(['siret'])
@Index(['ville'])
export class DimClient {
  @PrimaryGeneratedColumn({ name: 'client_sk' })
  clientSk: number;

  @Column({ name: 'client_nk', length: 30 })
  clientNk: string;

  @Column({ name: 'source_system', length: 20 })
  sourceSystem: string;

  @Column({ name: 'source_id', nullable: true })
  sourceId: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ length: 20, nullable: true })
  code: string;

  @Column({ name: 'raison_sociale', length: 150, nullable: true })
  raisonSociale: string;

  @Column({ name: 'type_client', length: 30, nullable: true })
  typeClient: string;

  @Column({ length: 14, nullable: true })
  siret: string;

  @Column({ name: 'tva_intracom', length: 20, nullable: true })
  tvaIntracom: string;

  @Column({ type: 'text', nullable: true })
  adresse: string;

  @Column({ name: 'code_postal', length: 10, nullable: true })
  codePostal: string;

  @Column({ length: 100, nullable: true })
  ville: string;

  @Column({ length: 3, nullable: true })
  departement: string;

  @Column({ length: 50, nullable: true })
  region: string;

  @Column({ length: 50, nullable: true, default: 'FRANCE' })
  pays: string;

  @Column({ length: 20, nullable: true })
  telephone: string;

  @Column({ length: 150, nullable: true })
  email: string;

  @Column({ name: 'mode_reglement', length: 20, nullable: true })
  modeReglement: string;

  @Column({ name: 'conditions_paiement', nullable: true })
  conditionsPaiement: number;

  @Column({ name: 'encours_max', type: 'numeric', precision: 15, scale: 2, nullable: true })
  encoursMax: number;

  @Column({ name: 'taux_remise', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxRemise: number;

  @Column({ name: 'segment_client', length: 20, nullable: true })
  segmentClient: string;

  @Column({ name: 'score_risque', nullable: true })
  scoreRisque: number;

  @Column({ name: 'sage_code', length: 17, nullable: true })
  sageCode: string;

  @Column({ name: 'mde_code', length: 20, nullable: true })
  mdeCode: string;

  @Column({ name: 'is_current', default: true })
  isCurrent: boolean;

  @Column({ name: 'valid_from', type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ name: 'valid_to', type: 'timestamp', nullable: true })
  validTo: Date;
}

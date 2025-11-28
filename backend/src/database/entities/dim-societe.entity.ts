import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'dim_societe', schema: 'silver' })
@Index(['societeNk', 'isCurrent'])
export class DimSociete {
  @PrimaryGeneratedColumn({ name: 'societe_sk' })
  societeSk: number;

  @Column({ name: 'societe_nk', length: 20 })
  societeNk: string;

  @Column({ name: 'source_system', length: 20 })
  sourceSystem: string;

  @Column({ name: 'source_id', nullable: true })
  sourceId: number;

  @Column({ length: 10, nullable: true })
  code: string;

  @Column({ name: 'raison_sociale', length: 100, nullable: true })
  raisonSociale: string;

  @Column({ length: 14, nullable: true })
  siret: string;

  @Column({ type: 'text', nullable: true })
  adresse: string;

  @Column({ name: 'code_postal', length: 10, nullable: true })
  codePostal: string;

  @Column({ length: 50, nullable: true })
  ville: string;

  @Column({ length: 3, nullable: true })
  departement: string;

  @Column({ length: 50, nullable: true })
  region: string;

  @Column({ length: 20, nullable: true })
  telephone: string;

  @Column({ length: 100, nullable: true })
  email: string;

  @Column({ name: 'regime_tva', length: 20, nullable: true })
  regimeTva: string;

  @Column({ name: 'is_current', default: true })
  isCurrent: boolean;

  @Column({ name: 'valid_from', type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ name: 'valid_to', type: 'timestamp', nullable: true })
  validTo: Date;
}

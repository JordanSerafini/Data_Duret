import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity({ name: 'tiers.adresse', schema: 'tiers' })
export class AddressEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_id' })
  societeId: number;

  @Column({ name: 'tiers_type' })
  tiersType: string;

  @Column({ name: 'tiers_id' })
  tiersId: number;

  @Column({ name: 'type_adresse' })
  typeAdresse: string;

  @Column({ nullable: true })
  libelle: string;

  @Column({ name: 'adresse_ligne1', nullable: true })
  adresseLigne1: string;

  @Column({ name: 'code_postal', nullable: true })
  codePostal: string;

  @Column({ nullable: true })
  ville: string;

  @Column({ name: 'pays_code', nullable: true })
  paysCode: string;

  @Column({ default: false })
  defaut: boolean;
}

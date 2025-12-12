import { Entity, PrimaryGeneratedColumn, Column, OneToMany, JoinColumn, ManyToOne } from 'typeorm';

@Entity({ name: 'tiers.client', schema: 'tiers' })
export class ClientEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  code: string;

  @Column()
  intitule: string;

  @Column({ name: 'siret', nullable: true })
  siret: string;

  @Column({ name: 'email', nullable: true })
  email: string;

  @Column({ name: 'ville', nullable: true })
  ville: string;
}

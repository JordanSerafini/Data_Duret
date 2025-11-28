import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_stock_element', schema: 'gold' })
@Index(['elementSk'])
@Index(['estSousStockMini', 'estSurstock'])
export class AggStockElement {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'element_sk', nullable: true })
  elementSk: number;

  @Column({ name: 'depot_code', length: 20, nullable: true })
  depotCode: string;

  @Column({ name: 'date_calcul', type: 'date' })
  dateCalcul: Date;

  // Quantités
  @Column({ name: 'stock_initial', type: 'numeric', precision: 15, scale: 4, default: 0 })
  stockInitial: number;

  @Column({ name: 'entrees', type: 'numeric', precision: 15, scale: 4, default: 0 })
  entrees: number;

  @Column({ name: 'sorties', type: 'numeric', precision: 15, scale: 4, default: 0 })
  sorties: number;

  @Column({ name: 'stock_final', type: 'numeric', precision: 15, scale: 4, nullable: true })
  stockFinal: number;

  // Valorisation
  @Column({ name: 'valeur_stock', type: 'numeric', precision: 15, scale: 2, default: 0 })
  valeurStock: number;

  @Column({ name: 'prix_moyen_pondere', type: 'numeric', precision: 15, scale: 4, nullable: true })
  prixMoyenPondere: number;

  // Indicateurs
  @Column({ name: 'rotation_stock', type: 'numeric', precision: 6, scale: 2, nullable: true })
  rotationStock: number;

  @Column({ name: 'couverture_jours', nullable: true })
  couvertureJours: number;

  @Column({ name: 'stock_minimum', type: 'numeric', precision: 15, scale: 4, nullable: true })
  stockMinimum: number;

  @Column({ name: 'est_sous_stock_mini', default: false })
  estSousStockMini: boolean;

  @Column({ name: 'est_surstock', default: false })
  estSurstock: boolean;

  // Consommation
  @Column({ name: 'conso_moyenne_mensuelle', type: 'numeric', precision: 15, scale: 4, nullable: true })
  consoMoyenneMensuelle: number;

  @Column({ name: 'conso_dernier_mois', type: 'numeric', precision: 15, scale: 4, nullable: true })
  consoDernierMois: number;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

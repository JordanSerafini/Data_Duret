import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_ca_periode', schema: 'gold' })
@Index(['societeSk', 'annee', 'mois'])
export class AggCaPeriode {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column()
  annee: number;

  @Column({ nullable: true })
  mois: number;

  @Column({ nullable: true })
  trimestre: number;

  @Column({ name: 'semaine_iso', nullable: true })
  semaineIso: number;

  @Column({ name: 'niveau_agregation', length: 20 })
  niveauAgregation: string;

  @Column({ name: 'date_debut', type: 'date', nullable: true })
  dateDebut: Date;

  @Column({ name: 'date_fin', type: 'date', nullable: true })
  dateFin: Date;

  // Mesures CA
  @Column({ name: 'ca_devis', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caDevis: number;

  @Column({ name: 'ca_commande', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caCommande: number;

  @Column({ name: 'ca_facture', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caFacture: number;

  @Column({ name: 'ca_avoir', type: 'numeric', precision: 15, scale: 2, default: 0 })
  caAvoir: number;

  @Column({ name: 'ca_net', type: 'numeric', precision: 15, scale: 2, nullable: true })
  caNet: number;

  // Comptages
  @Column({ name: 'nb_devis', default: 0 })
  nbDevis: number;

  @Column({ name: 'nb_commandes', default: 0 })
  nbCommandes: number;

  @Column({ name: 'nb_factures', default: 0 })
  nbFactures: number;

  @Column({ name: 'nb_avoirs', default: 0 })
  nbAvoirs: number;

  @Column({ name: 'nb_clients_actifs', default: 0 })
  nbClientsActifs: number;

  @Column({ name: 'nb_affaires_actives', default: 0 })
  nbAffairesActives: number;

  // Moyennes
  @Column({ name: 'panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true })
  panierMoyen: number;

  @Column({ name: 'taux_transformation', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxTransformation: number;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

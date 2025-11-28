import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'agg_ca_affaire', schema: 'gold' })
@Index(['societeSk'])
@Index(['clientSk'])
@Index(['niveauRisque'])
export class AggCaAffaire {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'affaire_sk', nullable: true })
  affaireSk: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column({ name: 'client_sk', nullable: true })
  clientSk: number;

  // Montants
  @Column({ name: 'montant_devis', type: 'numeric', precision: 15, scale: 2, default: 0 })
  montantDevis: number;

  @Column({ name: 'montant_commande', type: 'numeric', precision: 15, scale: 2, default: 0 })
  montantCommande: number;

  @Column({ name: 'montant_facture', type: 'numeric', precision: 15, scale: 2, default: 0 })
  montantFacture: number;

  @Column({ name: 'montant_avoir', type: 'numeric', precision: 15, scale: 2, default: 0 })
  montantAvoir: number;

  @Column({ name: 'montant_reste_a_facturer', type: 'numeric', precision: 15, scale: 2, nullable: true })
  montantResteAFacturer: number;

  // Coûts
  @Column({ name: 'cout_mo_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutMoPrevu: number;

  @Column({ name: 'cout_mo_reel', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutMoReel: number;

  @Column({ name: 'cout_achats_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutAchatsPrevu: number;

  @Column({ name: 'cout_achats_reel', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutAchatsReel: number;

  @Column({ name: 'cout_sous_traitance_prevu', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutSousTraitancePrevu: number;

  @Column({ name: 'cout_sous_traitance_reel', type: 'numeric', precision: 15, scale: 2, default: 0 })
  coutSousTraitanceReel: number;

  @Column({ name: 'cout_total_prevu', type: 'numeric', precision: 15, scale: 2, nullable: true })
  coutTotalPrevu: number;

  @Column({ name: 'cout_total_reel', type: 'numeric', precision: 15, scale: 2, nullable: true })
  coutTotalReel: number;

  // Marges
  @Column({ name: 'marge_prevue', type: 'numeric', precision: 15, scale: 2, nullable: true })
  margePrevue: number;

  @Column({ name: 'marge_reelle', type: 'numeric', precision: 15, scale: 2, nullable: true })
  margeReelle: number;

  @Column({ name: 'taux_marge_prevu', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxMargePrevu: number;

  @Column({ name: 'taux_marge_reel', type: 'numeric', precision: 5, scale: 2, nullable: true })
  tauxMargeReel: number;

  @Column({ name: 'ecart_marge', type: 'numeric', precision: 15, scale: 2, nullable: true })
  ecartMarge: number;

  // Heures
  @Column({ name: 'heures_budget', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresBudget: number;

  @Column({ name: 'heures_realisees', type: 'numeric', precision: 10, scale: 2, default: 0 })
  heuresRealisees: number;

  @Column({ name: 'ecart_heures', type: 'numeric', precision: 10, scale: 2, nullable: true })
  ecartHeures: number;

  @Column({ name: 'productivite_pct', type: 'numeric', precision: 10, scale: 2, nullable: true })
  productivitePct: number;

  // Avancement
  @Column({ name: 'avancement_facturation_pct', type: 'numeric', precision: 10, scale: 2, nullable: true })
  avancementFacturationPct: number;

  @Column({ name: 'avancement_travaux_pct', type: 'numeric', precision: 10, scale: 2, nullable: true })
  avancementTravauxPct: number;

  // Alertes
  @Column({ name: 'est_en_depassement_budget', default: false })
  estEnDepassementBudget: boolean;

  @Column({ name: 'est_en_retard', default: false })
  estEnRetard: boolean;

  @Column({ name: 'niveau_risque', length: 20, nullable: true })
  niveauRisque: string;

  @Column({ name: 'last_updated', type: 'timestamp', nullable: true })
  lastUpdated: Date;
}

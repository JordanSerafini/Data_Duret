import { Entity, Column, PrimaryGeneratedColumn, Index } from 'typeorm';

@Entity({ name: 'kpi_global', schema: 'gold' })
@Index(['societeSk', 'annee', 'mois'])
export class KpiGlobal {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'societe_sk', nullable: true })
  societeSk: number;

  @Column()
  annee: number;

  @Column()
  mois: number;

  // KPIs Commerciaux
  @Column({ name: 'kpi_ca_mensuel', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiCaMensuel: number;

  @Column({ name: 'kpi_ca_cumul', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiCaCumul: number;

  @Column({ name: 'kpi_ca_objectif', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiCaObjectif: number;

  @Column({ name: 'kpi_ca_realisation_pct', type: 'numeric', precision: 5, scale: 2, nullable: true })
  kpiCaRealisationPct: number;

  @Column({ name: 'kpi_ca_variation_n1_pct', type: 'numeric', precision: 6, scale: 2, nullable: true })
  kpiCaVariationN1Pct: number;

  @Column({ name: 'kpi_panier_moyen', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiPanierMoyen: number;

  @Column({ name: 'kpi_nb_nouveaux_clients', nullable: true })
  kpiNbNouveauxClients: number;

  @Column({ name: 'kpi_taux_transformation', type: 'numeric', precision: 5, scale: 2, nullable: true })
  kpiTauxTransformation: number;

  // KPIs Marge
  @Column({ name: 'kpi_marge_brute', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiMargeBrute: number;

  @Column({ name: 'kpi_taux_marge', type: 'numeric', precision: 5, scale: 2, nullable: true })
  kpiTauxMarge: number;

  @Column({ name: 'kpi_marge_objectif', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiMargeObjectif: number;

  // KPIs Trésorerie
  @Column({ name: 'kpi_tresorerie_nette', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiTresorerieNette: number;

  @Column({ name: 'kpi_bfr', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiBfr: number;

  @Column({ name: 'kpi_dso_jours', nullable: true })
  kpiDsoJours: number;

  @Column({ name: 'kpi_dpo_jours', nullable: true })
  kpiDpoJours: number;

  // KPIs RH
  @Column({ name: 'kpi_effectif_moyen', type: 'numeric', precision: 6, scale: 1, nullable: true })
  kpiEffectifMoyen: number;

  @Column({ name: 'kpi_heures_productives', type: 'numeric', precision: 10, scale: 2, nullable: true })
  kpiHeuresProductives: number;

  @Column({ name: 'kpi_taux_occupation', type: 'numeric', precision: 5, scale: 2, nullable: true })
  kpiTauxOccupation: number;

  @Column({ name: 'kpi_cout_mo_par_heure', type: 'numeric', precision: 8, scale: 2, nullable: true })
  kpiCoutMoParHeure: number;

  @Column({ name: 'kpi_ca_par_salarie', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiCaParSalarie: number;

  // KPIs Affaires
  @Column({ name: 'kpi_nb_affaires_en_cours', nullable: true })
  kpiNbAffairesEnCours: number;

  @Column({ name: 'kpi_nb_affaires_en_retard', nullable: true })
  kpiNbAffairesEnRetard: number;

  @Column({ name: 'kpi_nb_affaires_en_depassement', nullable: true })
  kpiNbAffairesEnDepassement: number;

  @Column({ name: 'kpi_carnet_commandes', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiCarnetCommandes: number;

  @Column({ name: 'kpi_reste_a_facturer', type: 'numeric', precision: 15, scale: 2, nullable: true })
  kpiResteAFacturer: number;

  @Column({ name: 'calcul_date', type: 'timestamp', nullable: true })
  calculDate: Date;
}

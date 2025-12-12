import { ViewEntity, ViewColumn, PrimaryColumn } from 'typeorm';

@ViewEntity({ 
    schema: 'analytics', 
    name: 'mvi_synthese_chantier_financier',
    expression: `
        -- Definition is managed by SQL migration, this is just for TypeORM mapping
        SELECT * FROM analytics.mvi_synthese_chantier_financier
    `
})
export class ChantierFinancierView {
  @PrimaryColumn({ name: 'chantier_id' })
  chantierId: number;

  @ViewColumn()
  code: string;

  @ViewColumn()
  intitule: string;

  @ViewColumn()
  etat: string;

  @ViewColumn({ name: 'ca_facture' })
  caFacture: number;

  @ViewColumn({ name: 'cout_mo' })
  coutMo: number;

  @ViewColumn({ name: 'cout_fournitures' })
  coutFournitures: number;

  @ViewColumn({ name: 'cout_total_estime' })
  coutTotalEstime: number;

  @ViewColumn({ name: 'marge_estimee' })
  margeEstimee: number;

  @ViewColumn({ name: 'taux_marge_pct' })
  tauxMargePct: number;
}

import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'data_quality_rules', schema: 'audit' })
export class DataQualityRule {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'rule_name', length: 100 })
  ruleName: string;

  @Column({ name: 'rule_description', type: 'text', nullable: true })
  ruleDescription: string;

  @Column({ length: 20 })
  layer: string;

  @Column({ name: 'table_name', length: 100 })
  tableName: string;

  @Column({ name: 'check_type', length: 50 })
  checkType: string;

  @Column({ name: 'check_query', type: 'text' })
  checkQuery: string;

  @Column({ name: 'threshold_value', type: 'numeric', nullable: true })
  thresholdValue: number;

  @Column({ length: 20, default: 'WARNING' })
  severity: string;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @Column({ name: 'created_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}

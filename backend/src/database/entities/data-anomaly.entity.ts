import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'data_anomaly', schema: 'audit' })
export class DataAnomaly {
  @PrimaryGeneratedColumn({ type: 'bigint' })
  id: number;

  @Column({ length: 20 })
  layer: string;

  @Column({ name: 'table_name', length: 100 })
  tableName: string;

  @Column({ name: 'record_id', type: 'bigint', nullable: true })
  recordId: number;

  @Column({ name: 'anomaly_type', length: 50 })
  anomalyType: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 20, default: 'WARNING' })
  severity: string;

  @Column({ name: 'detected_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  detectedAt: Date;

  @Column({ name: 'resolved_at', type: 'timestamp', nullable: true })
  resolvedAt: Date;

  @Column({ name: 'resolution_comment', type: 'text', nullable: true })
  resolutionComment: string;
}

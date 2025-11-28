import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'job_execution', schema: 'etl' })
export class JobExecution {
  @PrimaryGeneratedColumn({ type: 'bigint' })
  id: number;

  @Column({ name: 'job_name', length: 100 })
  jobName: string;

  @Column({ name: 'source_system', length: 50 })
  sourceSystem: string;

  @Column({ name: 'target_layer', length: 20 })
  targetLayer: string;

  @Column({ name: 'start_time', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  startTime: Date;

  @Column({ name: 'end_time', type: 'timestamp', nullable: true })
  endTime: Date;

  @Column({ length: 20, default: 'RUNNING' })
  status: string;

  @Column({ name: 'rows_read', type: 'bigint', default: 0 })
  rowsRead: number;

  @Column({ name: 'rows_inserted', type: 'bigint', default: 0 })
  rowsInserted: number;

  @Column({ name: 'rows_updated', type: 'bigint', default: 0 })
  rowsUpdated: number;

  @Column({ name: 'rows_deleted', type: 'bigint', default: 0 })
  rowsDeleted: number;

  @Column({ name: 'rows_rejected', type: 'bigint', default: 0 })
  rowsRejected: number;

  @Column({ name: 'error_message', type: 'text', nullable: true })
  errorMessage: string;

  @Column({ name: 'execution_parameters', type: 'jsonb', nullable: true })
  executionParameters: Record<string, unknown>;

  @Column({ name: 'created_by', length: 50, default: 'CURRENT_USER' })
  createdBy: string;
}

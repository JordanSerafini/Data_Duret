import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'data_quality_check', schema: 'audit' })
export class DataQualityCheck {
  @PrimaryGeneratedColumn({ type: 'bigint' })
  id: number;

  @Column({ name: 'check_name', length: 100 })
  checkName: string;

  @Column({ length: 20 })
  layer: string;

  @Column({ name: 'table_name', length: 100 })
  tableName: string;

  @Column({ name: 'check_type', length: 50 })
  checkType: string;

  @Column({ name: 'check_query', type: 'text' })
  checkQuery: string;

  @Column({ name: 'expected_result', type: 'text', nullable: true })
  expectedResult: string;

  @Column({ name: 'actual_result', type: 'text', nullable: true })
  actualResult: string;

  @Column({ nullable: true })
  passed: boolean;

  @Column({ name: 'execution_time', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  executionTime: Date;

  @Column({ name: 'job_id', type: 'bigint', nullable: true })
  jobId: number;
}

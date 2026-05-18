class DropRailsPulseTables < ActiveRecord::Migration[8.0]
  TABLES = %i[
    rails_pulse_operations
    rails_pulse_job_runs
    rails_pulse_jobs
    rails_pulse_summaries
    rails_pulse_requests
    rails_pulse_routes
    rails_pulse_queries
  ]

  def up
    TABLES.each { |t| drop_table t if table_exists?(t) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

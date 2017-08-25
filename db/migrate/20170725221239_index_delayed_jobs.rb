class IndexDelayedJobs < ActiveRecord::Migration
  def change
    add_index :delayed_jobs, [:run_at, :locked_at, :locked_by, :failed_at], name: :index_delayed_jobs_on_ready
    add_index :delayed_jobs, :priority, order: {priority: :asc}
  end
end

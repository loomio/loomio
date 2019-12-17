class AddDelayedJobsIndexOnRunAt < ActiveRecord::Migration[5.2]
  def change
    remove_index :delayed_jobs, name: 'delayed_jobs_priority'
    remove_index :delayed_jobs, name: 'index_delayed_jobs_on_ready'
    add_index :delayed_jobs, 'run_at'
  end
end

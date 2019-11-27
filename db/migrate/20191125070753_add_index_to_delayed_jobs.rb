class AddIndexToDelayedJobs < ActiveRecord::Migration[5.2]
  def change
    add_index :delayed_jobs, :locked_at, where: 'locked_at is null'
    add_index :delayed_jobs, :failed_at, where: 'failed_at is null'
    add_index :delayed_jobs, :locked_by
    add_index :delayed_jobs, :queue
  end
end

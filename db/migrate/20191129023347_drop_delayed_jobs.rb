class DropDelayedJobs < ActiveRecord::Migration[5.2]
  def change
    drop_table :delayed_jobs
  end
end

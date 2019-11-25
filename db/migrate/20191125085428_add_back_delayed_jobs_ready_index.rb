class AddBackDelayedJobsReadyIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :delayed_jobs, ["run_at", "locked_at", "locked_by", "failed_at"], name: "index_delayed_jobs_on_ready"
  end
end

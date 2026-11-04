class ScheduleItemTagBackfill < ActiveRecord::Migration[8.1]
  def up
    active = SolidQueue::Job.where(class_name: 'BackfillItemTagsWorker', finished_at: nil)
      .where.not(id: SolidQueue::FailedExecution.select(:job_id))
    return if active.exists?

    # Leave time for web and worker processes to upgrade before rebuilding
    # derived tags. A separate migration also covers already-migrated installs.
    BackfillItemTagsWorker.set(wait: 10.minutes).perform_later
  end

  def down
    # Tag summaries and search tags are derived data and need no reversal.
  end
end

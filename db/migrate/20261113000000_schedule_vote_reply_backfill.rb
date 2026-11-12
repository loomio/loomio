class ScheduleVoteReplyBackfill < ActiveRecord::Migration[8.1]
  def up
    BackfillVoteRepliesWorker.set(wait: 10.minutes).perform_later
  end

  def down
    # Corrected timeline ancestry is derived data and needs no reversal.
  end
end

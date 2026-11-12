class ScheduleVoteReplyBackfill < ActiveRecord::Migration[8.1]
  def up
    # Superseded by RepairVoteReplyNesting. Do not schedule the removed worker
    # when a fresh installation replays this migration.
  end

  def down
    # Corrected timeline ancestry is derived data and needs no reversal.
  end
end

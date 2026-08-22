class NormalizeNotificationDuplicates < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    stats = NotificationDuplicateCleanupService.normalize!(
      progress: lambda do |event_id_after, event_id_finish, totals|
        say(
          "normalized notification event ids after #{event_id_after} through #{event_id_finish}: " \
          "#{totals[:duplicate_groups]} duplicate groups, " \
          "#{totals[:removed_notifications]} rows removed",
          true
        )
      end
    )
    say "normalized historical notification duplicates: #{stats.inspect}"
  end

  def down
    # Removed duplicates cannot be reconstructed, and the retained rows remain
    # valid event-backed notifications.
  end
end

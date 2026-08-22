# Historical retries created more than one notification for the same user and
# event. Normalize bounded event ranges so each transaction stays small: retain
# the earliest row, merge the user-visible state into it, then remove later rows.
# This deliberately leaves event_id unchanged while event-backed delivery is the
# active compatibility path.
class NotificationDuplicateCleanupService
  EVENT_ID_BATCH_SIZE = 100_000

  def self.report
    counts = Notification.connection.select_one(<<~SQL.squish)
      SELECT
        COUNT(*) AS duplicate_groups,
        COALESCE(SUM(notification_count - 1), 0) AS duplicate_notifications
      FROM (
        SELECT COUNT(*) AS notification_count
        FROM notifications
        GROUP BY user_id, event_id
        HAVING COUNT(*) > 1
      ) duplicates
    SQL

    {
      duplicate_groups: counts.fetch("duplicate_groups").to_i,
      duplicate_notifications: counts.fetch("duplicate_notifications").to_i
    }
  end

  def self.normalize!(event_id_batch_size: EVENT_ID_BATCH_SIZE, progress: nil)
    event_id_batch_size = Integer(event_id_batch_size)
    raise ArgumentError, "event_id_batch_size must be positive" unless event_id_batch_size.positive?

    connection = Notification.connection
    stats = empty_stats
    event_id_after = -1

    while (event_id_finish = next_event_id_finish(connection, event_id_after, event_id_batch_size))
      batch_stats = normalize_batch!(event_id_after, event_id_finish)
      stats[:batches] += 1
      stats[:duplicate_groups] += batch_stats.fetch(:duplicate_groups)
      stats[:removed_notifications] += batch_stats.fetch(:removed_notifications)
      progress&.call(event_id_after, event_id_finish, stats.dup)
      event_id_after = event_id_finish
    end

    stats
  end

  def self.next_event_id_finish(connection, event_id_after, event_id_batch_size)
    connection.select_value(<<~SQL)&.to_i
      SELECT MAX(event_id)
      FROM (
        SELECT DISTINCT event_id
        FROM notifications
        WHERE event_id > #{connection.quote(event_id_after)}
        ORDER BY event_id
        LIMIT #{event_id_batch_size}
      ) notification_events
    SQL
  end
  private_class_method :next_event_id_finish

  def self.normalize_batch!(event_id_after, event_id_finish)
    connection = Notification.connection
    duplicate_groups = 0
    removed_notifications = 0

    Notification.transaction do
      duplicate_groups = connection.execute(<<~SQL).cmd_tuples
        WITH duplicate_groups AS (
          SELECT
            user_id,
            event_id,
            MIN(id) AS retained_id,
            BOOL_OR(viewed) AS viewed,
            MAX(updated_at) AS updated_at
          FROM notifications
          WHERE event_id > #{connection.quote(event_id_after)}
            AND event_id <= #{connection.quote(event_id_finish)}
          GROUP BY user_id, event_id
          HAVING COUNT(*) > 1
        )
        UPDATE notifications retained
        SET
          viewed = duplicate_groups.viewed,
          updated_at = duplicate_groups.updated_at
        FROM duplicate_groups
        WHERE retained.id = duplicate_groups.retained_id
      SQL

      removed_notifications = connection.execute(<<~SQL).cmd_tuples
        WITH duplicate_groups AS (
          SELECT
            user_id,
            event_id,
            MIN(id) AS retained_id
          FROM notifications
          WHERE event_id > #{connection.quote(event_id_after)}
            AND event_id <= #{connection.quote(event_id_finish)}
          GROUP BY user_id, event_id
          HAVING COUNT(*) > 1
        )
        DELETE FROM notifications duplicate
        USING duplicate_groups
        WHERE duplicate.user_id = duplicate_groups.user_id
          AND duplicate.event_id = duplicate_groups.event_id
          AND duplicate.id <> duplicate_groups.retained_id
      SQL
    end

    {
      duplicate_groups: duplicate_groups,
      removed_notifications: removed_notifications
    }
  end
  private_class_method :normalize_batch!

  def self.empty_stats
    {
      batches: 0,
      duplicate_groups: 0,
      removed_notifications: 0
    }
  end
  private_class_method :empty_stats
end

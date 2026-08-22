# Backfill the self-contained fields for legacy event-backed notifications after
# dual-writing has been fully deployed and old notification workers have drained.
# Work is bounded by notification ID and committed per batch so interruption and
# retry do not restart one large transaction or overwrite fields already copied.
class NotificationDeliveryBackfillService
  BATCH_SIZE = 100_000
  INDEX_DEDUPLICATION = "index_notifications_on_user_id_and_deduplication_key"

  class IncompleteBackfill < StandardError; end

  def self.run!(dry_run: true, batch_size: BATCH_SIZE, high_water_id: nil, rebuild_index: false, progress: nil)
    batch_size = Integer(batch_size)
    raise ArgumentError, "batch_size must be positive" unless batch_size.positive?

    high_water_id = Integer(high_water_id || Notification.maximum(:id) || 0)
    report_before = report(high_water_id: high_water_id)
    duplicate_report = NotificationDuplicateCleanupService.report

    if dry_run
      return {
        dry_run: true,
        high_water_id: high_water_id,
        duplicate_report: duplicate_report,
        before: report_before
      }
    end

    duplicate_stats = NotificationDuplicateCleanupService.normalize!(
      progress: lambda do |event_id_after, event_id_finish, totals|
        progress&.call(:duplicates, event_id_after, event_id_finish, totals)
      end
    )
    stats = {
      dry_run: false,
      index_rebuilt: rebuild_index,
      high_water_id: high_water_id,
      batches: 0,
      notifications_updated: 0,
      duplicate_report: duplicate_report,
      duplicate_stats: duplicate_stats,
      before: report_before
    }

    if rebuild_index
      # This mode requires all notification writers to be stopped. Rebuild in
      # ensure so an ordinary exception or interrupt does not leave delivery
      # identity unenforced after the maintenance window.
      begin
        remove_deduplication_index!
        backfill_fields!(stats, batch_size, high_water_id, progress)
      ensure
        add_deduplication_index!
      end
    else
      backfill_fields!(stats, batch_size, high_water_id, progress)
    end

    stats[:after] = report(high_water_id: high_water_id)
    if stats.dig(:after, :keys_missing).positive? || stats.dig(:after, :fields_incomplete).positive?
      raise IncompleteBackfill, "notification delivery backfill left incomplete rows: #{stats[:after].inspect}"
    end
    unless deduplication_index_valid?
      raise IncompleteBackfill, "notification delivery deduplication index is missing or invalid"
    end

    stats
  end

  def self.backfill_fields!(stats, batch_size, high_water_id, progress)
    notification_id_after = 0

    while (notification_id_finish = next_notification_id_finish(notification_id_after, high_water_id, batch_size))
      rows_updated = backfill_batch!(notification_id_after, notification_id_finish)
      stats[:batches] += 1
      stats[:notifications_updated] += rows_updated
      progress&.call(:fields, notification_id_after, notification_id_finish, stats.dup)
      notification_id_after = notification_id_finish
    end
  end
  private_class_method :backfill_fields!

  def self.remove_deduplication_index!
    index_name = Notification.connection.quote_column_name(INDEX_DEDUPLICATION)
    Notification.connection.execute("DROP INDEX CONCURRENTLY IF EXISTS #{index_name}")
    Notification.reset_column_information
  end
  private_class_method :remove_deduplication_index!

  def self.add_deduplication_index!
    return if deduplication_index_valid?

    # A cancelled concurrent build can reserve the name with an invalid index.
    remove_deduplication_index! if deduplication_index_exists?
    index_name = Notification.connection.quote_column_name(INDEX_DEDUPLICATION)
    Notification.connection.execute(<<~SQL.squish)
      CREATE UNIQUE INDEX CONCURRENTLY #{index_name}
      ON notifications (user_id, deduplication_key)
      WHERE deduplication_key IS NOT NULL
    SQL
    Notification.reset_column_information
  end
  private_class_method :add_deduplication_index!

  def self.deduplication_index_exists?
    !deduplication_index_valid_value.nil?
  end
  private_class_method :deduplication_index_exists?

  def self.deduplication_index_valid?
    ActiveModel::Type::Boolean.new.cast(deduplication_index_valid_value)
  end
  private_class_method :deduplication_index_valid?

  def self.deduplication_index_valid_value
    Notification.connection.select_value(<<~SQL.squish)
      SELECT index.indisvalid
      FROM pg_index index
      INNER JOIN pg_class index_class ON index_class.oid = index.indexrelid
      WHERE index_class.relname = #{Notification.connection.quote(INDEX_DEDUPLICATION)}
    SQL
  end
  private_class_method :deduplication_index_valid_value

  def self.report(high_water_id: Notification.maximum(:id) || 0)
    high_water_id = Integer(high_water_id)
    counts = Notification.connection.select_one(<<~SQL.squish)
      SELECT
        COUNT(*) FILTER (
          WHERE notifications.deduplication_key IS NULL
        ) AS keys_missing,
        COUNT(*) FILTER (
          WHERE notifications.deduplication_key IS NULL
            AND (
              events.id IS NULL OR
              events.kind IS NULL OR
              events.eventable_type IS NULL OR
              events.eventable_id IS NULL
            )
        ) AS rows_blocked,
        COUNT(*) FILTER (
          WHERE notifications.deduplication_key IS NOT NULL
            AND (
              notifications.kind IS NULL OR
              notifications.subject_type IS NULL OR
              notifications.subject_id IS NULL
            )
        ) AS fields_incomplete
      FROM notifications
      LEFT JOIN events ON events.id = notifications.event_id
      WHERE notifications.id <= #{Notification.connection.quote(high_water_id)}
    SQL

    {
      keys_missing: counts.fetch("keys_missing").to_i,
      rows_blocked: counts.fetch("rows_blocked").to_i,
      fields_incomplete: counts.fetch("fields_incomplete").to_i
    }
  end

  def self.next_notification_id_finish(notification_id_after, high_water_id, batch_size)
    Notification.connection.select_value(<<~SQL)&.to_i
      SELECT MAX(id)
      FROM (
        SELECT id
        FROM notifications
        WHERE id > #{Notification.connection.quote(notification_id_after)}
          AND id <= #{Notification.connection.quote(high_water_id)}
          AND deduplication_key IS NULL
        ORDER BY id
        LIMIT #{batch_size}
      ) notification_batch
    SQL
  end
  private_class_method :next_notification_id_finish

  def self.backfill_batch!(notification_id_after, notification_id_finish)
    Notification.connection.execute(<<~SQL).cmd_tuples
      WITH backfill_values AS (
        SELECT
          notifications.id,
          CASE
            WHEN events.kind = 'announcement_created' THEN
              COALESCE(events.custom_fields ->> 'kind', 'group_announced')
            WHEN events.kind = 'user_mentioned' AND (
              (mentioned_comments.parent_type = 'Discussion' AND parent_discussions.author_id = notifications.user_id) OR
              (mentioned_comments.parent_type = 'Comment' AND parent_comments.user_id = notifications.user_id) OR
              (mentioned_comments.parent_type = 'Outcome' AND parent_outcomes.author_id = notifications.user_id) OR
              (mentioned_comments.parent_type = 'Poll' AND parent_polls.author_id = notifications.user_id) OR
              (mentioned_comments.parent_type = 'Stance' AND parent_stances.participant_id = notifications.user_id)
            ) THEN 'comment_replied_to'
            ELSE events.kind
          END AS kind,
          events.eventable_type AS subject_type,
          events.eventable_id AS subject_id,
          events.user_id AS actor_id,
          'event:' || events.id AS deduplication_key
        FROM notifications
        INNER JOIN events ON events.id = notifications.event_id
        LEFT JOIN comments mentioned_comments
          ON events.kind = 'user_mentioned'
         AND events.eventable_type = 'Comment'
         AND mentioned_comments.id = events.eventable_id
        LEFT JOIN discussions parent_discussions
          ON mentioned_comments.parent_type = 'Discussion'
         AND parent_discussions.id = mentioned_comments.parent_id
        LEFT JOIN comments parent_comments
          ON mentioned_comments.parent_type = 'Comment'
         AND parent_comments.id = mentioned_comments.parent_id
        LEFT JOIN outcomes parent_outcomes
          ON mentioned_comments.parent_type = 'Outcome'
         AND parent_outcomes.id = mentioned_comments.parent_id
        LEFT JOIN polls parent_polls
          ON mentioned_comments.parent_type = 'Poll'
         AND parent_polls.id = mentioned_comments.parent_id
        LEFT JOIN stances parent_stances
          ON mentioned_comments.parent_type = 'Stance'
         AND parent_stances.id = mentioned_comments.parent_id
        WHERE notifications.id > #{Notification.connection.quote(notification_id_after)}
          AND notifications.id <= #{Notification.connection.quote(notification_id_finish)}
          AND notifications.deduplication_key IS NULL
          AND events.kind IS NOT NULL
          AND events.eventable_type IS NOT NULL
          AND events.eventable_id IS NOT NULL
      )
      UPDATE notifications
      SET
        kind = COALESCE(notifications.kind, backfill_values.kind),
        subject_type = COALESCE(notifications.subject_type, backfill_values.subject_type),
        subject_id = COALESCE(notifications.subject_id, backfill_values.subject_id),
        actor_id = COALESCE(notifications.actor_id, backfill_values.actor_id),
        deduplication_key = backfill_values.deduplication_key
      FROM backfill_values
      WHERE notifications.id = backfill_values.id
    SQL
  end
  private_class_method :backfill_batch!
end

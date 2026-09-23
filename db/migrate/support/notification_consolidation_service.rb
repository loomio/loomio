# Consolidate legacy per-user notification receipts into logical notification
# occurrences and in-app deliveries. The legacy tables remain authoritative
# while this runs, so every batch is additive, idempotent and independently
# committed. A notification-ID cursor catches receipts written for old events.
class NotificationConsolidationService
  BATCH_SIZE = 100_000
  STATE_NAME = "legacy_notification_receipts"

  class IncompleteBackfill < StandardError; end

  def self.run!(dry_run: true, batch_size: BATCH_SIZE, high_water_id: nil, repair: false, progress: nil)
    batch_size = Integer(batch_size)
    raise ArgumentError, "batch_size must be positive" unless batch_size.positive?

    connection = ActiveRecord::Base.connection
    ensure_preparation_schema!(connection)
    state = state(connection)
    high_water_id = [
      Integer(high_water_id || legacy_notification_id_max(connection)),
      state.fetch(:notification_id_high_water)
    ].max

    if dry_run
      return {
        dry_run: true,
        state: state,
        before: report(connection: connection, high_water_id: high_water_id)
      }
    end

    # Any mutating pass invalidates earlier proof, including a retry at the same
    # high-water mark. Only the successful audit at the end of this run may
    # restore completion, and only a repair run may authorize cutover.
    connection.exec_update(<<~SQL.squish)
      UPDATE notification_consolidation_states
      SET notification_id_high_water = GREATEST(
            notification_id_high_water,
            #{connection.quote(high_water_id)}
          ),
          completed_at = NULL,
          repair_completed_at = NULL,
          updated_at = CURRENT_TIMESTAMP
      WHERE name = #{connection.quote(STATE_NAME)}
    SQL

    stats = {
      dry_run: false,
      batches: 0,
      receipts_processed: 0,
      notification_id_high_water: high_water_id,
      before: state
    }
    notification_id_after = state.fetch(:notification_id_cursor)

    while (notification_id_finish = next_notification_id_finish(
      connection,
      notification_id_after,
      high_water_id,
      batch_size
    ))
      batch_stats = consolidate_batch!(connection, notification_id_after, notification_id_finish)
      stats[:batches] += 1
      stats[:receipts_processed] += batch_stats.fetch(:receipts_processed)
      notification_id_after = notification_id_finish
      progress&.call(notification_id_after, high_water_id, stats.dup)
    end

    # MAX(id) can be below the requested high-water mark when IDs have gaps.
    connection.exec_update(<<~SQL.squish)
      UPDATE notification_consolidation_states
      SET notification_id_cursor = GREATEST(notification_id_cursor, #{connection.quote(high_water_id)}),
          updated_at = CURRENT_TIMESTAMP
      WHERE name = #{connection.quote(STATE_NAME)}
    SQL

    stats[:repair] = repair_differences!(connection, high_water_id) if repair

    stats[:after] = report(connection: connection, high_water_id: high_water_id)
    audit_failures = %i[
      blocked_receipts
      missing_notifications
      extra_notifications
      missing_deliveries
      extra_deliveries
    ]
    if audit_failures.any? { |key| stats.dig(:after, key).positive? }
      raise IncompleteBackfill, "notification consolidation is incomplete: #{stats[:after].inspect}"
    end

    connection.exec_update(<<~SQL.squish)
      UPDATE notification_consolidation_states
      SET completed_at = CURRENT_TIMESTAMP,
          repair_completed_at = CASE
            WHEN #{connection.quote(repair)} THEN CURRENT_TIMESTAMP
            ELSE repair_completed_at
          END,
          updated_at = CURRENT_TIMESTAMP
      WHERE name = #{connection.quote(STATE_NAME)}
        AND notification_id_cursor >= notification_id_high_water
    SQL
    stats[:state] = state(connection)
    stats
  end

  # A sequence ID can be allocated before the warm cursor passes it and commit
  # afterwards. Once old writers are drained, reconcile the set difference
  # across the complete high-water range rather than assuming ID visibility
  # order was commit order. Legacy receipts remain authoritative, including
  # when a receipt was deleted after its dual-written delivery was prepared.
  def self.repair_differences!(connection, high_water_id)
    values_sql = receipt_values_sql(
      connection,
      notification_id_after: 0,
      notification_id_finish: high_water_id
    )

    occurrences_deleted = connection.execute(<<~SQL).cmd_tuples
      WITH receipt_values AS (
        #{values_sql}
      )
      DELETE FROM notification_occurrences occurrences
      WHERE occurrences.legacy_event_id IS NOT NULL
        AND NOT EXISTS (
          SELECT 1
          FROM receipt_values
          WHERE receipt_values.event_id = occurrences.legacy_event_id
            AND receipt_values.effective_kind = occurrences.kind
            AND receipt_values.subject_type IS NOT NULL
            AND receipt_values.subject_id IS NOT NULL
        )
    SQL

    deliveries_deleted = connection.execute(<<~SQL).cmd_tuples
      WITH receipt_values AS (
        #{values_sql}
      )
      DELETE FROM notification_deliveries deliveries
      USING notification_occurrences occurrences
      WHERE deliveries.notification_occurrence_id = occurrences.id
        AND occurrences.legacy_event_id IS NOT NULL
        AND deliveries.channel = 'in_app'
        AND deliveries.recipient_type = 'User'
        AND NOT EXISTS (
          SELECT 1
          FROM receipt_values
          WHERE receipt_values.event_id = occurrences.legacy_event_id
            AND receipt_values.effective_kind = occurrences.kind
            AND receipt_values.user_id = deliveries.recipient_id
            AND receipt_values.subject_type IS NOT NULL
            AND receipt_values.subject_id IS NOT NULL
        )
    SQL

    occurrences_inserted = connection.execute(<<~SQL).cmd_tuples
      WITH receipt_values AS (
        #{values_sql}
      ), occurrence_values AS (
        SELECT DISTINCT ON (event_id, effective_kind)
          event_id AS legacy_event_id,
          actor_id,
          effective_kind,
          subject_type,
          subject_id,
          recipient_message,
          audience_values,
          created_at,
          updated_at
        FROM receipt_values
        WHERE effective_kind IS NOT NULL
          AND subject_type IS NOT NULL
          AND subject_id IS NOT NULL
        ORDER BY event_id, effective_kind, notification_id
      )
      INSERT INTO notification_occurrences
        (legacy_event_id, actor_id, kind, subject_type, subject_id,
         recipient_message, audience_values, translation_values, deliveries_generated_at,
         created_at, updated_at)
      SELECT
        legacy_event_id, actor_id, effective_kind, subject_type, subject_id,
        recipient_message, audience_values, '{}'::jsonb, CURRENT_TIMESTAMP, created_at, updated_at
      FROM occurrence_values source_values
      WHERE NOT EXISTS (
        SELECT 1 FROM notification_occurrences occurrences
        WHERE occurrences.legacy_event_id = source_values.legacy_event_id
          AND occurrences.kind = source_values.effective_kind
      )
      ON CONFLICT (legacy_event_id, kind) DO NOTHING
    SQL

    deliveries_inserted = connection.execute(<<~SQL).cmd_tuples
      WITH receipt_values AS (
        #{values_sql}
      ), grouped_receipts AS (
        SELECT
          event_id AS legacy_event_id,
          effective_kind,
          user_id,
          (array_agg(translation_values ORDER BY notification_id))[1] AS translation_values,
          MIN(created_at) AS created_at,
          MAX(updated_at) AS updated_at,
          MAX(updated_at) FILTER (WHERE viewed) AS viewed_at
        FROM receipt_values
        WHERE effective_kind IS NOT NULL
          AND subject_type IS NOT NULL
          AND subject_id IS NOT NULL
        GROUP BY event_id, effective_kind, user_id
      )
      INSERT INTO notification_deliveries
        (notification_occurrence_id, recipient_type, recipient_id, channel,
         delivered_at, viewed_at, translation_values, created_at, updated_at)
      SELECT
        occurrences.id, 'User', grouped_receipts.user_id, 'in_app',
        grouped_receipts.created_at, grouped_receipts.viewed_at,
        grouped_receipts.translation_values,
        grouped_receipts.created_at, grouped_receipts.updated_at
      FROM grouped_receipts
      INNER JOIN notification_occurrences occurrences
        ON occurrences.legacy_event_id = grouped_receipts.legacy_event_id
       AND occurrences.kind = grouped_receipts.effective_kind
      WHERE NOT EXISTS (
        SELECT 1 FROM notification_deliveries deliveries
        WHERE deliveries.notification_occurrence_id = occurrences.id
          AND deliveries.channel = 'in_app'
          AND deliveries.recipient_type = 'User'
          AND deliveries.recipient_id = grouped_receipts.user_id
      )
      ON CONFLICT (notification_occurrence_id, channel, recipient_type, recipient_id)
      DO NOTHING
    SQL

    {
      occurrences_deleted: occurrences_deleted,
      deliveries_deleted: deliveries_deleted,
      occurrences_inserted: occurrences_inserted,
      deliveries_inserted: deliveries_inserted
    }
  end
  private_class_method :repair_differences!

  def self.report(connection: ActiveRecord::Base.connection, high_water_id: nil)
    ensure_preparation_schema!(connection)
    high_water_id = Integer(high_water_id || legacy_notification_id_max(connection))
    counts = connection.select_one(<<~SQL.squish)
      WITH receipt_values AS (
        #{receipt_values_sql(connection, notification_id_after: 0, notification_id_finish: high_water_id)}
      ), delivery_groups AS (
        SELECT DISTINCT event_id, effective_kind, user_id
        FROM receipt_values
        WHERE effective_kind IS NOT NULL
          AND subject_type IS NOT NULL
          AND subject_id IS NOT NULL
      )
      SELECT
        (SELECT COUNT(*) FROM receipt_values) AS legacy_receipts,
        (SELECT COUNT(*) FROM receipt_values
          WHERE effective_kind IS NULL OR subject_type IS NULL OR subject_id IS NULL
        ) AS blocked_receipts,
        (SELECT COUNT(DISTINCT (event_id, effective_kind)) FROM receipt_values
          WHERE effective_kind IS NOT NULL
            AND subject_type IS NOT NULL
            AND subject_id IS NOT NULL
        ) AS expected_notifications,
        (SELECT COUNT(*) FROM delivery_groups) AS expected_deliveries
    SQL

    actual_counts = connection.select_one(<<~SQL.squish)
      SELECT
        COUNT(DISTINCT occurrences.id) AS actual_notifications,
        COUNT(*) AS actual_deliveries
      FROM notification_occurrences occurrences
      INNER JOIN notification_deliveries deliveries
        ON deliveries.notification_occurrence_id = occurrences.id
      WHERE occurrences.legacy_event_id IS NOT NULL
        AND deliveries.channel = 'in_app'
        AND deliveries.recipient_type = 'User'
    SQL
    expected_notifications = counts.fetch("expected_notifications").to_i
    expected_deliveries = counts.fetch("expected_deliveries").to_i
    actual_notifications = actual_counts.fetch("actual_notifications").to_i
    actual_deliveries = actual_counts.fetch("actual_deliveries").to_i

    {
      notification_id_high_water: high_water_id,
      legacy_receipts: counts.fetch("legacy_receipts").to_i,
      blocked_receipts: counts.fetch("blocked_receipts").to_i,
      expected_notifications: expected_notifications,
      actual_notifications: actual_notifications,
      missing_notifications: [ expected_notifications - actual_notifications, 0 ].max,
      extra_notifications: [ actual_notifications - expected_notifications, 0 ].max,
      expected_deliveries: expected_deliveries,
      actual_deliveries: actual_deliveries,
      missing_deliveries: [ expected_deliveries - actual_deliveries, 0 ].max,
      extra_deliveries: [ actual_deliveries - expected_deliveries, 0 ].max
    }
  end

  def self.state(connection = ActiveRecord::Base.connection)
    connection.exec_insert(<<~SQL.squish)
      INSERT INTO notification_consolidation_states
        (name, notification_id_cursor, notification_id_high_water, created_at, updated_at)
      VALUES
        (#{connection.quote(STATE_NAME)}, 0, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ON CONFLICT (name) DO NOTHING
    SQL
    row = connection.select_one(<<~SQL.squish)
      SELECT notification_id_cursor, notification_id_high_water,
             completed_at, repair_completed_at
      FROM notification_consolidation_states
      WHERE name = #{connection.quote(STATE_NAME)}
    SQL
    {
      notification_id_cursor: row.fetch("notification_id_cursor").to_i,
      notification_id_high_water: row.fetch("notification_id_high_water").to_i,
      completed_at: row.fetch("completed_at"),
      repair_completed_at: row.fetch("repair_completed_at")
    }
  end

  def self.consolidate_batch!(connection, notification_id_after, notification_id_finish)
    receipts_processed = 0

    ActiveRecord::Base.transaction do
      values_sql = receipt_values_sql(
        connection,
        notification_id_after: notification_id_after,
        notification_id_finish: notification_id_finish
      )

      connection.exec_insert(<<~SQL)
        WITH receipt_values AS (
          #{values_sql}
        )
        INSERT INTO notification_occurrences
          (legacy_event_id, actor_id, kind, subject_type, subject_id,
           recipient_message, audience_values, translation_values, deliveries_generated_at,
           created_at, updated_at)
        SELECT DISTINCT ON (event_id, effective_kind)
          event_id,
          actor_id,
          effective_kind,
          subject_type,
          subject_id,
          recipient_message,
          audience_values,
          '{}'::jsonb,
          CURRENT_TIMESTAMP,
          created_at,
          updated_at
        FROM receipt_values
        WHERE effective_kind IS NOT NULL
          AND subject_type IS NOT NULL
          AND subject_id IS NOT NULL
        ORDER BY event_id, effective_kind, notification_id
        ON CONFLICT (legacy_event_id, kind) DO NOTHING
      SQL

      connection.execute(<<~SQL)
        WITH receipt_values AS (
          #{values_sql}
        ), grouped_receipts AS (
          SELECT
            event_id AS legacy_event_id,
            effective_kind,
            user_id,
            (array_agg(translation_values ORDER BY notification_id))[1] AS translation_values,
            MIN(created_at) AS created_at,
            MAX(updated_at) AS updated_at,
            MAX(updated_at) FILTER (WHERE viewed) AS viewed_at,
            COUNT(*) AS receipt_count
          FROM receipt_values
          WHERE effective_kind IS NOT NULL
            AND subject_type IS NOT NULL
            AND subject_id IS NOT NULL
          GROUP BY event_id, effective_kind, user_id
        )
        INSERT INTO notification_deliveries
          (notification_occurrence_id, recipient_type, recipient_id, channel,
           delivered_at, viewed_at, translation_values, created_at, updated_at)
        SELECT
          occurrences.id,
          'User',
          grouped_receipts.user_id,
          'in_app',
          grouped_receipts.created_at,
          grouped_receipts.viewed_at,
          grouped_receipts.translation_values,
          grouped_receipts.created_at,
          grouped_receipts.updated_at
        FROM grouped_receipts
        INNER JOIN notification_occurrences occurrences
          ON occurrences.legacy_event_id = grouped_receipts.legacy_event_id
         AND occurrences.kind = grouped_receipts.effective_kind
        ON CONFLICT (notification_occurrence_id, channel, recipient_type, recipient_id)
        DO UPDATE SET
          viewed_at = COALESCE(notification_deliveries.viewed_at, EXCLUDED.viewed_at),
          updated_at = GREATEST(notification_deliveries.updated_at, EXCLUDED.updated_at)
      SQL

      receipts_processed = connection.select_value(<<~SQL).to_i
        SELECT COUNT(*)
        FROM notifications
        WHERE id > #{connection.quote(notification_id_after)}
          AND id <= #{connection.quote(notification_id_finish)}
      SQL

      connection.exec_update(<<~SQL.squish)
        UPDATE notification_consolidation_states
        SET notification_id_cursor = #{connection.quote(notification_id_finish)},
            updated_at = CURRENT_TIMESTAMP
        WHERE name = #{connection.quote(STATE_NAME)}
      SQL
    end

    { receipts_processed: receipts_processed }
  end
  private_class_method :consolidate_batch!

  def self.next_notification_id_finish(connection, notification_id_after, high_water_id, batch_size)
    connection.select_value(<<~SQL)&.to_i
      SELECT MAX(id)
      FROM (
        SELECT id
        FROM notifications
        WHERE id > #{connection.quote(notification_id_after)}
          AND id <= #{connection.quote(high_water_id)}
        ORDER BY id
        LIMIT #{connection.quote(batch_size)}
      ) receipt_batch
    SQL
  end
  private_class_method :next_notification_id_finish

  def self.legacy_notification_id_max(connection)
    connection.select_value("SELECT COALESCE(MAX(id), 0) FROM notifications").to_i
  end
  private_class_method :legacy_notification_id_max

  def self.ensure_preparation_schema!(connection)
    required_tables = %w[notifications events notification_occurrences notification_deliveries notification_consolidation_states]
    missing_tables = required_tables.reject { |table| connection.data_source_exists?(table) }
    return if missing_tables.empty?

    raise IncompleteBackfill, "notification preparation schema is missing: #{missing_tables.join(', ')}"
  end
  private_class_method :ensure_preparation_schema!

  # One event can have two recipient-specific effective kinds: a mention of a
  # comment is a reply for the parent author and a mention for other users.
  # Effective kind is therefore part of occurrence identity.
  def self.receipt_values_sql(connection, notification_id_after:, notification_id_finish:)
    <<~SQL
      SELECT
        notifications.id AS notification_id,
        events.id AS event_id,
        notifications.user_id,
        notifications.translation_values,
        notifications.viewed,
        notifications.created_at,
        notifications.updated_at,
        actor_users.id AS actor_id,
        events.eventable_type AS subject_type,
        events.eventable_id AS subject_id,
        events.custom_fields ->> 'recipient_message' AS recipient_message,
        CASE
          WHEN events.custom_fields ? 'group_ids' THEN
            jsonb_build_object('group_ids', events.custom_fields -> 'group_ids')
          ELSE '{}'::jsonb
        END AS audience_values,
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
        END AS effective_kind
      FROM notifications
      INNER JOIN events ON events.id = notifications.event_id
      LEFT JOIN users actor_users ON actor_users.id = events.user_id
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
      WHERE notifications.id > #{connection.quote(notification_id_after)}
        AND notifications.id <= #{connection.quote(notification_id_finish)}
    SQL
  end
  private_class_method :receipt_values_sql
end

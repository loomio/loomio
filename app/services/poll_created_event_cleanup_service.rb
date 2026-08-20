class PollCreatedEventCleanupService
  TABLE_NORMALIZATION = "poll_created_event_normalization"
  TABLE_REPAIR = "poll_created_topic_repair"
  TABLE_REFRESH = "poll_created_topic_refresh"

  def self.normalize!
    connection = ActiveRecord::Base.connection
    [ TABLE_NORMALIZATION, TABLE_REPAIR, TABLE_REFRESH ].each do |table|
      connection.execute("DROP TABLE IF EXISTS #{table}")
    end

    insert_missing_events(connection)
    create_normalization_table(connection)
    create_topic_tables(connection)
    normalize_events(connection)
    refresh_topics(connection)

    connection.clear_cache!
    repair_topic_ids = connection.select_values(
      "SELECT topic_id FROM #{TABLE_REPAIR} ORDER BY topic_id"
    )
    repair_topic_ids.each { |topic_id| TopicService.repair(topic_id) }

    {
      duplicate_events: connection.select_value(
        "SELECT COUNT(*) FROM #{TABLE_NORMALIZATION} WHERE event_rank > 1"
      ).to_i,
      repaired_topics: repair_topic_ids.length
    }
  ensure
    [ TABLE_NORMALIZATION, TABLE_REPAIR, TABLE_REFRESH ].each do |table|
      connection&.execute("DROP TABLE IF EXISTS #{table}")
    end
  end

  def self.insert_missing_events(connection)
    connection.execute(<<~SQL)
      INSERT INTO events (
        kind,
        eventable_type,
        eventable_id,
        user_id,
        created_at,
        updated_at
      )
      SELECT
        'poll_created',
        'Poll',
        polls.id,
        polls.author_id,
        polls.created_at,
        CURRENT_TIMESTAMP
      FROM polls
      WHERE NOT EXISTS (
        SELECT 1
        FROM events
        WHERE events.eventable_type = 'Poll'
          AND events.eventable_id = polls.id
          AND events.kind = 'poll_created'
      )
    SQL
  end

  def self.create_normalization_table(connection)
    connection.execute(<<~SQL)
      CREATE TEMPORARY TABLE #{TABLE_NORMALIZATION} ON COMMIT DROP AS
      WITH child_counts AS (
        SELECT
          parent_id,
          COUNT(*) FILTER (WHERE topic_id IS NOT NULL) AS timeline_children
        FROM events
        WHERE parent_id IS NOT NULL
        GROUP BY parent_id
      ),
      ranked AS (
        SELECT
          events.id AS event_id,
          events.eventable_id AS poll_id,
          polls.topic_id AS poll_topic_id,
          events.topic_id AS event_topic_id,
          events.parent_id AS event_parent_id,
          ROW_NUMBER() OVER (
            PARTITION BY events.eventable_id
            ORDER BY
              (events.topic_id = polls.topic_id) DESC NULLS LAST,
              COALESCE(child_counts.timeline_children, 0) DESC,
              events.sequence_id ASC NULLS LAST,
              events.id
          ) AS event_rank
        FROM events
        INNER JOIN polls ON polls.id = events.eventable_id
        LEFT JOIN child_counts ON child_counts.parent_id = events.id
        WHERE events.eventable_type = 'Poll'
          AND events.kind = 'poll_created'
      )
      SELECT
        ranked.*,
        canonical.event_id AS canonical_id,
        canonical.event_topic_id AS canonical_topic_id
      FROM ranked
      INNER JOIN ranked canonical
        ON canonical.poll_id = ranked.poll_id
       AND canonical.event_rank = 1
    SQL

    connection.add_index(
      TABLE_NORMALIZATION,
      :event_id,
      unique: true,
      name: "index_poll_created_normalization_event"
    )
    connection.add_index(
      TABLE_NORMALIZATION,
      :poll_id,
      name: "index_poll_created_normalization_poll"
    )
  end

  def self.create_topic_tables(connection)
    connection.execute(<<~SQL)
      CREATE TEMPORARY TABLE #{TABLE_REPAIR} (
        topic_id BIGINT PRIMARY KEY
      ) ON COMMIT DROP
    SQL
    connection.execute(<<~SQL)
      INSERT INTO #{TABLE_REPAIR} (topic_id)
      SELECT DISTINCT topic_id
      FROM (
        SELECT canonical_topic_id AS topic_id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank = 1
          AND canonical_topic_id IS DISTINCT FROM poll_topic_id

        UNION

        SELECT poll_topic_id AS topic_id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank = 1
          AND canonical_topic_id IS DISTINCT FROM poll_topic_id

        UNION

        SELECT children.topic_id
        FROM #{TABLE_NORMALIZATION} normalization
        INNER JOIN events children ON children.parent_id = normalization.event_id
        WHERE normalization.event_rank > 1
          AND children.topic_id IS NOT NULL

        UNION

        SELECT normalization.poll_topic_id
        FROM #{TABLE_NORMALIZATION} normalization
        WHERE normalization.event_rank > 1
          AND EXISTS (
            SELECT 1
            FROM events children
            WHERE children.parent_id = normalization.event_id
              AND children.topic_id IS NOT NULL
          )

        UNION

        SELECT events.topic_id
        FROM events
        WHERE events.eventable_type = 'Poll'
          AND NOT EXISTS (
            SELECT 1
            FROM polls
            WHERE polls.id = events.eventable_id
          )
          AND events.topic_id IS NOT NULL
      ) topics
      WHERE topic_id IS NOT NULL
      ON CONFLICT DO NOTHING
    SQL

    connection.execute(<<~SQL)
      CREATE TEMPORARY TABLE #{TABLE_REFRESH} ON COMMIT DROP AS
      SELECT DISTINCT event_topic_id AS topic_id
      FROM #{TABLE_NORMALIZATION}
      WHERE event_rank > 1
        AND event_topic_id IS NOT NULL

      UNION

      SELECT DISTINCT poll_topic_id AS topic_id
      FROM #{TABLE_NORMALIZATION}
      WHERE event_rank = 1
        AND canonical_topic_id IS DISTINCT FROM poll_topic_id
    SQL
    connection.add_index(
      TABLE_REFRESH,
      :topic_id,
      unique: true,
      name: "index_poll_created_refresh_topic"
    )
  end

  def self.normalize_events(connection)
    connection.execute(<<~SQL)
      UPDATE events children
      SET parent_id = normalization.canonical_id
      FROM #{TABLE_NORMALIZATION} normalization
      WHERE normalization.event_rank > 1
        AND children.parent_id = normalization.event_id
    SQL

    connection.execute(<<~SQL)
      DELETE FROM notifications
      WHERE event_id IN (
        SELECT event_id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank > 1
      )
    SQL
    connection.execute(<<~SQL)
      DELETE FROM events
      WHERE id IN (
        SELECT event_id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank > 1
      )
    SQL

    connection.execute(<<~SQL)
      UPDATE events
      SET
        topic_id = normalization.poll_topic_id,
        parent_id = NULL,
        sequence_id = CASE
          WHEN topics.topicable_type = 'Poll'
           AND topics.topicable_id = normalization.poll_id
          THEN 0
          ELSE NULL
        END,
        position = 0,
        position_key = CASE
          WHEN topics.topicable_type = 'Poll'
           AND topics.topicable_id = normalization.poll_id
          THEN '00000'
          ELSE NULL
        END,
        depth = 0
      FROM #{TABLE_NORMALIZATION} normalization, topics
      WHERE normalization.event_rank = 1
        AND normalization.canonical_topic_id IS DISTINCT FROM normalization.poll_topic_id
        AND events.id = normalization.canonical_id
        AND topics.id = normalization.poll_topic_id
    SQL

    orphan_poll_ids = <<~SQL.squish
      SELECT DISTINCT events.eventable_id
      FROM events
      WHERE events.eventable_type = 'Poll'
        AND NOT EXISTS (
          SELECT 1 FROM polls WHERE polls.id = events.eventable_id
        )
    SQL
    orphan_event_ids = <<~SQL.squish
      SELECT events.id
      FROM events
      WHERE events.eventable_type = 'Poll'
        AND events.eventable_id IN (#{orphan_poll_ids})
    SQL
    connection.execute(<<~SQL)
      UPDATE events
      SET parent_id = NULL
      WHERE parent_id IN (#{orphan_event_ids})
    SQL
    connection.execute("DELETE FROM notifications WHERE event_id IN (#{orphan_event_ids})")
    connection.execute("DELETE FROM events WHERE id IN (#{orphan_event_ids})")
  end

  def self.refresh_topics(connection)
    connection.execute(<<~SQL)
      WITH parent_ids AS (
        SELECT canonical_id AS id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank > 1

        UNION

        SELECT event_parent_id AS id
        FROM #{TABLE_NORMALIZATION}
        WHERE event_rank > 1
          AND event_parent_id IS NOT NULL
      )
      UPDATE events parents
      SET child_count = (
        SELECT COUNT(*)
        FROM events children
        WHERE children.parent_id = parents.id
          AND children.topic_id = parents.topic_id
      )
      FROM parent_ids
      WHERE parents.id = parent_ids.id
    SQL

    connection.execute(<<~SQL)
      WITH ordered AS (
        SELECT
          events.topic_id,
          events.sequence_id,
          events.created_at,
          events.sequence_id - ROW_NUMBER() OVER (
            PARTITION BY events.topic_id
            ORDER BY events.sequence_id
          ) AS range_group
        FROM events
        INNER JOIN #{TABLE_REFRESH} refresh_topics
          ON refresh_topics.topic_id = events.topic_id
        WHERE events.sequence_id IS NOT NULL
      ),
      ranges AS (
        SELECT
          topic_id,
          MIN(sequence_id) AS range_start,
          MAX(sequence_id) AS range_finish
        FROM ordered
        GROUP BY topic_id, range_group
      ),
      range_strings AS (
        SELECT
          topic_id,
          STRING_AGG(
            range_start || '-' || range_finish,
            ',' ORDER BY range_start
          ) AS ranges_string
        FROM ranges
        GROUP BY topic_id
      ),
      summaries AS (
        SELECT
          ordered.topic_id,
          COUNT(*) AS items_count,
          range_strings.ranges_string,
          (ARRAY_AGG(ordered.created_at ORDER BY ordered.sequence_id DESC))[1] AS last_activity_at
        FROM ordered
        INNER JOIN range_strings ON range_strings.topic_id = ordered.topic_id
        GROUP BY ordered.topic_id, range_strings.ranges_string
      )
      UPDATE topics
      SET
        items_count = summaries.items_count,
        ranges_string = summaries.ranges_string,
        last_activity_at = summaries.last_activity_at
      FROM summaries
      WHERE topics.id = summaries.topic_id
    SQL
  end

  private_class_method :insert_missing_events,
                       :create_normalization_table,
                       :create_topic_tables,
                       :normalize_events,
                       :refresh_topics
end

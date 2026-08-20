class DiscussionCreatedEventCleanupService
  def self.normalize!
    connection = ActiveRecord::Base.connection
    topic_ids = connection.select_values(<<~SQL)
      SELECT discussions.topic_id
      FROM discussions
      INNER JOIN topics ON topics.id = discussions.topic_id
      WHERE NOT EXISTS (
        SELECT 1
        FROM events
        WHERE events.eventable_type = 'Discussion'
          AND events.eventable_id = discussions.id
          AND events.kind = 'new_discussion'
      )
      ORDER BY discussions.topic_id
    SQL

    connection.execute(<<~SQL)
      INSERT INTO events (
        kind,
        eventable_type,
        eventable_id,
        user_id,
        topic_id,
        sequence_id,
        position,
        position_key,
        depth,
        child_count,
        created_at,
        updated_at
      )
      SELECT
        'new_discussion',
        'Discussion',
        discussions.id,
        discussions.author_id,
        discussions.topic_id,
        0,
        0,
        '00000',
        0,
        0,
        discussions.created_at,
        CURRENT_TIMESTAMP
      FROM discussions
      INNER JOIN topics ON topics.id = discussions.topic_id
      WHERE NOT EXISTS (
        SELECT 1
        FROM events
        WHERE events.eventable_type = 'Discussion'
          AND events.eventable_id = discussions.id
          AND events.kind = 'new_discussion'
      )
    SQL

    orphan_discussion_ids = <<~SQL.squish
      SELECT events.eventable_id
      FROM events
      WHERE events.eventable_type = 'Discussion'
        AND events.kind = 'new_discussion'
        AND NOT EXISTS (
          SELECT 1
          FROM discussions
          WHERE discussions.id = events.eventable_id
        )
    SQL
    orphan_event_ids = <<~SQL.squish
      SELECT events.id
      FROM events
      WHERE events.eventable_type = 'Discussion'
        AND events.eventable_id IN (#{orphan_discussion_ids})
    SQL
    orphan_events = connection.select_value(
      "SELECT COUNT(*) FROM events WHERE id IN (#{orphan_event_ids})"
    ).to_i
    connection.execute("DELETE FROM notifications WHERE event_id IN (#{orphan_event_ids})")
    connection.execute("DELETE FROM events WHERE id IN (#{orphan_event_ids})")

    connection.clear_cache!
    Topic.where(id: topic_ids, discarded_at: nil).pluck(:id).each do |topic_id|
      TopicService.repair(topic_id)
    end
    Topic.where(id: topic_ids).find_each(&:update_sequence_info!)

    {
      inserted_events: topic_ids.length,
      orphan_events: orphan_events
    }
  end
end

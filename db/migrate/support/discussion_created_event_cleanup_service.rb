# Historical data can contain discussions without a new_discussion event, or
# new_discussion events whose discussion has been deleted. A discussion needs one
# new_discussion event to anchor its topic timeline. This service creates missing
# events, removes event families that no longer have a discussion, then repairs
# the affected topic timelines.
class DiscussionCreatedEventCleanupService
  def self.normalize!
    connection = ActiveRecord::Base.connection

    # Remember affected topics before creating the missing new_discussion events
    # so their timeline metadata can be rebuilt after the raw SQL changes.
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

    # A discussion with a topic must have one new_discussion event. Use the
    # discussion's original author and timestamp when reconstructing it.
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

    # If the discussion has gone, none of its events can be rendered or repaired.
    # Delete the whole event family, including notifications, rather than leaving
    # records whose polymorphic eventable no longer exists.
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

    # Raw SQL bypasses Active Record and the callbacks that maintain topic order,
    # parentage and cached counts, so explicitly restore those invariants.
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

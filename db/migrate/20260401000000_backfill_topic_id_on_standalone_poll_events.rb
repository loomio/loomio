class BackfillTopicIdOnStandalonePollEvents < ActiveRecord::Migration[7.0]
  def up
    # The original topic migration created topics for standalone polls and updated
    # polls.topic_id, but never set events.topic_id on their events.
    # Events.discussion_id was renamed to topic_id, but standalone polls had
    # discussion_id = NULL, so their events still have topic_id = NULL.

    # Set topic_id on the oldest poll_created event per standalone poll,
    # and mark it as root event (sequence_id=0, position=0).
    # Some polls have duplicate poll_created events, so use DISTINCT ON.
    execute <<~SQL
      UPDATE events
      SET topic_id = sub.topic_id,
          sequence_id = 0,
          position = 0,
          position_key = '00000'
      FROM (
        SELECT DISTINCT ON (e.eventable_id)
               e.id AS event_id, t.id AS topic_id
        FROM events e
        JOIN topics t ON t.topicable_type = 'Poll' AND t.topicable_id = e.eventable_id
        WHERE e.eventable_type = 'Poll'
          AND e.kind = 'poll_created'
          AND e.topic_id IS NULL
        ORDER BY e.eventable_id, e.id
      ) sub
      WHERE events.id = sub.event_id
    SQL

    # Update items_count on standalone poll topics
    execute <<~SQL
      UPDATE topics
      SET items_count = (
        SELECT COUNT(*) FROM events
        WHERE events.topic_id = topics.id AND events.sequence_id > 0
      )
      WHERE topics.topicable_type = 'Poll'
    SQL
  end

  def down
    # No-op: cannot reliably undo
  end
end

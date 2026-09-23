class DeleteLegacyDiscussionForkedEvents < ActiveRecord::Migration[8.0]
  def up
    rows = connection.select_rows(<<~SQL)
      SELECT forked_events.id, forked_events.topic_id, parent_events.topic_id
      FROM events forked_events
      LEFT JOIN events parent_events ON parent_events.id = forked_events.parent_id
      WHERE forked_events.kind = 'discussion_forked'
    SQL

    event_ids = rows.map { |event_id, _topic_id, _parent_topic_id| event_id.to_i }
    return if event_ids.empty?

    topic_ids = rows.flat_map { |_event_id, topic_id, parent_topic_id| [ topic_id, parent_topic_id ] }
    topic_ids.concat(
      connection.select_values(<<~SQL)
        SELECT DISTINCT topic_id
        FROM events
        WHERE parent_id IN (#{event_ids.join(', ')})
      SQL
    )

    execute <<~SQL
      DELETE FROM notifications
      WHERE event_id IN (#{event_ids.join(', ')})
    SQL

    execute <<~SQL
      DELETE FROM events
      WHERE id IN (#{event_ids.join(', ')})
    SQL

    connection.clear_cache!
    topic_ids.compact.map(&:to_i).uniq.each do |topic_id|
      TopicService.repair(topic_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy discussion_forked events cannot be restored"
  end
end

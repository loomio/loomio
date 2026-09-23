class RepairNullTopicItemPositions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    remove_obsolete_poll_lifecycle_topic_items!

    topic_ids = select_values(<<~SQL.squish).map(&:to_i)
      SELECT DISTINCT topic_id
      FROM topic_items
      WHERE position_key IS NULL
      ORDER BY topic_id
    SQL

    topic_ids.each.with_index(1) do |topic_id, index|
      say "repairing topic item positions for topic #{topic_id} (#{index}/#{topic_ids.length})", true if (index % 100).zero?
      Topic.transaction do
        TopicService.repair(topic_id)
        TopicService.verify_integrity!(topic_id)
      end
    end
  end

  def down
    # Restoring invalid timeline positions would reintroduce unreadable topics.
  end

  private

  # These legacy events are notifications rather than timeline activity in the
  # current model. Preserve their notification history on the poll, then remove
  # the obsolete timeline rows so topic repair does not recreate them.
  def remove_obsolete_poll_lifecycle_topic_items!
    kinds = %w[poll_closing_soon poll_expired poll_option_added]
            .map { |kind| connection.quote(kind) }
            .join(", ")

    execute <<~SQL.squish
      UPDATE notifications
      SET subject_type = 'Poll',
          subject_id = topic_items.itemable_id
      FROM topic_items
      WHERE notifications.subject_type = 'TopicItem'
        AND notifications.subject_id = topic_items.id
        AND topic_items.itemable_type = 'Poll'
        AND topic_items.kind IN (#{kinds})
    SQL

    execute <<~SQL.squish
      DELETE FROM topic_items
      WHERE itemable_type = 'Poll'
        AND kind IN (#{kinds})
    SQL
  end
end

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

    Topic.transaction(requires_new: true) do
      execute "LOCK TABLE notifications, topic_items IN SHARE ROW EXCLUSIVE MODE"
      affected_topic_ids = select_values("SELECT DISTINCT topic_id FROM topic_items WHERE itemable_type = 'Poll' AND kind IN (#{kinds})").map(&:to_i)
      # The parent FK cascades deletes. Move surviving children to their own
      # topic's real root before removing obsolete notification-only items.
      execute <<~SQL.squish
        UPDATE topic_items children
        SET parent_id = roots.id, depth = roots.depth + 1
        FROM topic_items obsolete, topics, topic_items roots
        WHERE children.parent_id = obsolete.id
          AND obsolete.itemable_type = 'Poll' AND obsolete.kind IN (#{kinds})
          AND topics.id = children.topic_id
          AND roots.topic_id = topics.id
          AND roots.itemable_type = topics.topicable_type
          AND roots.itemable_id = topics.topicable_id
          AND roots.kind IN ('new_discussion', 'poll_created')
          AND roots.parent_id IS NULL
      SQL
      if select_value(<<~SQL.squish)
        SELECT EXISTS (
          SELECT 1 FROM topic_items children JOIN topic_items obsolete ON children.parent_id = obsolete.id
          WHERE obsolete.itemable_type = 'Poll' AND obsolete.kind IN (#{kinds})
        )
      SQL
        raise "Cannot remove obsolete lifecycle items without a valid root for their children"
      end

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

      # Repair in the same transaction: a failure must leave obsolete items
      # available so retrying the migration still discovers affected topics.
      affected_topic_ids.each do |topic_id|
        TopicService.repair(topic_id)
        TopicService.verify_integrity!(topic_id)
      end
    end
  end
end

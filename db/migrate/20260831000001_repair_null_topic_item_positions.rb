class RepairNullTopicItemPositions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
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
end

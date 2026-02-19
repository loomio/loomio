class RemoveDiscussionIdFromPolls < ActiveRecord::Migration[7.2]
  def up
    remove_column :polls, :discussion_id
  end

  def down
    add_column :polls, :discussion_id, :integer

    # Backfill discussion_id from topic: if topic.topicable_type is 'Discussion', that's the discussion
    execute <<~SQL
      UPDATE polls SET discussion_id = t.topicable_id
      FROM topics t
      WHERE t.id = polls.topic_id AND t.topicable_type = 'Discussion'
    SQL

    add_index :polls, :discussion_id
  end
end

class AddTopicIdAndMoveGroupId < ActiveRecord::Migration[7.2]
  def up
    # Add topic_id to discussions and polls
    add_column :discussions, :topic_id, :integer
    add_column :polls, :topic_id, :integer

    # Add group_id to topics
    add_column :topics, :group_id, :integer

    # Backfill topic_id on discussions
    execute <<~SQL
      UPDATE discussions SET topic_id = t.id
      FROM topics t
      WHERE t.topicable_type = 'Discussion' AND t.topicable_id = discussions.id
    SQL

    # Backfill topic_id on standalone polls (from poll's own topic)
    execute <<~SQL
      UPDATE polls SET topic_id = t.id
      FROM topics t
      WHERE t.topicable_type = 'Poll' AND t.topicable_id = polls.id
    SQL

    # Backfill topic_id on in-discussion polls (from discussion's topic)
    execute <<~SQL
      UPDATE polls SET topic_id = d.topic_id
      FROM discussions d
      WHERE d.id = polls.discussion_id AND polls.topic_id IS NULL
    SQL

    # Backfill group_id on topics from discussions
    execute <<~SQL
      UPDATE topics SET group_id = d.group_id
      FROM discussions d
      WHERE topics.topicable_type = 'Discussion' AND topics.topicable_id = d.id
    SQL

    # Backfill group_id on topics from polls (standalone poll topics)
    execute <<~SQL
      UPDATE topics SET group_id = p.group_id
      FROM polls p
      WHERE topics.topicable_type = 'Poll' AND topics.topicable_id = p.id
    SQL

    # Remove group_id from discussions and polls
    remove_column :discussions, :group_id
    remove_column :polls, :group_id

    # Add indexes
    add_index :discussions, :topic_id
    add_index :topics, :group_id
  end

  def down
    add_column :discussions, :group_id, :integer
    add_column :polls, :group_id, :integer

    execute <<~SQL
      UPDATE discussions SET group_id = t.group_id
      FROM topics t
      WHERE t.topicable_type = 'Discussion' AND t.topicable_id = discussions.id
    SQL

    execute <<~SQL
      UPDATE polls SET group_id = t.group_id
      FROM topics t
      WHERE t.topicable_type = 'Poll' AND t.topicable_id = polls.id
    SQL

    # For in-discussion polls, get group_id from the discussion
    execute <<~SQL
      UPDATE polls SET group_id = d.group_id
      FROM discussions d
      WHERE polls.discussion_id = d.id AND polls.group_id IS NULL
    SQL

    remove_index :discussions, :topic_id
    remove_index :topics, :group_id

    remove_column :discussions, :topic_id
    remove_column :polls, :topic_id
    remove_column :topics, :group_id
  end
end

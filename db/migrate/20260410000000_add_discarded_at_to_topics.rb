class AddDiscardedAtToTopics < ActiveRecord::Migration[7.0]
  def up
    add_column :topics, :discarded_at, :datetime
    add_column :topics, :discarded_by, :integer

    execute <<~SQL
      UPDATE topics
      SET discarded_at = discussions.discarded_at,
          discarded_by = discussions.discarded_by
      FROM discussions
      WHERE topics.topicable_type = 'Discussion'
        AND topics.topicable_id = discussions.id
        AND discussions.discarded_at IS NOT NULL
    SQL

    execute <<~SQL
      UPDATE topics
      SET discarded_at = polls.discarded_at,
          discarded_by = polls.discarded_by
      FROM polls
      WHERE topics.topicable_type = 'Poll'
        AND topics.topicable_id = polls.id
        AND polls.discarded_at IS NOT NULL
    SQL

    add_index :topics, :discarded_at, where: "discarded_at IS NULL", name: "index_topics_on_discarded_at_null"
  end

  def down
    remove_index :topics, name: "index_topics_on_discarded_at_null"
    remove_column :topics, :discarded_by
    remove_column :topics, :discarded_at
  end
end

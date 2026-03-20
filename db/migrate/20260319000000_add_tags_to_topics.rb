class AddTagsToTopics < ActiveRecord::Migration[7.0]
  def up
    add_column :topics, :tags, :string, array: true, default: []
    add_index :topics, :tags, using: :gin

    execute <<~SQL
      UPDATE topics SET tags = discussions.tags
      FROM discussions WHERE topics.topicable_type = 'Discussion' AND topics.topicable_id = discussions.id
      AND discussions.tags != '{}';
    SQL

    execute <<~SQL
      UPDATE topics SET tags = polls.tags
      FROM polls WHERE topics.topicable_type = 'Poll' AND topics.topicable_id = polls.id
      AND polls.tags != '{}';
    SQL
  end

  def down
    remove_column :topics, :tags
  end
end

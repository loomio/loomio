class AddTagsToTopicItems < ActiveRecord::Migration[8.1]
  def up
    add_column :topic_items, :tags, :string, array: true, default: [], null: false
    add_index :topic_items, :tags, using: :gin
    add_index :topic_items, :topic_id, where: 'cardinality(tags) > 0', name: 'index_topic_items_with_tags_on_topic_id'
    add_check_constraint :topic_items, <<~SQL.squish, name: 'topic_items_tags_supported'
      cardinality(tags) = 0 OR
      (kind = 'new_discussion' AND itemable_type = 'Discussion') OR
      (kind = 'poll_created' AND itemable_type = 'Poll') OR
      (kind = 'outcome_created' AND itemable_type = 'Outcome') OR
      (kind = 'new_comment' AND itemable_type = 'Comment')
    SQL
    execute <<~SQL
      UPDATE topic_items SET tags = COALESCE(topics.tags, ARRAY[]::varchar[])
      FROM topics
      WHERE topic_items.topic_id = topics.id
        AND topic_items.itemable_type = topics.topicable_type
        AND topic_items.itemable_id = topics.topicable_id
        AND topic_items.kind IN ('new_discussion', 'poll_created')
    SQL
    # Preserve existing text indexes while replacing inherited thread labels
    # with the newly migrated explicit assignments.
    execute <<~SQL
      UPDATE pg_search_documents documents SET tags = COALESCE((
        SELECT items.tags FROM topic_items items
        WHERE items.itemable_type = documents.searchable_type
          AND items.itemable_id = documents.searchable_id
          AND items.kind IN ('new_discussion', 'poll_created', 'outcome_created', 'new_comment')
        ORDER BY items.id LIMIT 1
      ), ARRAY[]::varchar[])
    SQL
  end

  def down
    remove_check_constraint :topic_items, name: 'topic_items_tags_supported'
    remove_index :topic_items, name: 'index_topic_items_with_tags_on_topic_id'
    remove_column :topic_items, :tags
    execute 'UPDATE pg_search_documents SET tags = topics.tags FROM topics WHERE topics.id = pg_search_documents.topic_id'
  end
end

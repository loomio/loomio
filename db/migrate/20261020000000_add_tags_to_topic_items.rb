require_relative 'support/online_tag_migration'

class AddTagsToTopicItems < ActiveRecord::Migration[8.1]
  include OnlineTagMigration
  disable_ddl_transaction!

  def up
    with_short_lock_wait do
      add_column :topic_items, :tags, :string, array: true, default: [], null: false unless column_exists?(:topic_items, :tags)
      unless check_constraint_exists?(:topic_items, name: 'topic_items_tags_supported')
        add_check_constraint :topic_items, <<~SQL.squish, name: 'topic_items_tags_supported', validate: false
          cardinality(tags) = 0 OR
          (kind = 'new_discussion' AND itemable_type = 'Discussion') OR
          (kind = 'poll_created' AND itemable_type = 'Poll') OR
          (kind = 'outcome_created' AND itemable_type = 'Outcome') OR
          (kind = 'new_comment' AND itemable_type = 'Comment')
        SQL
      end
      add_concurrent_index :tags, name: 'index_topic_items_on_tags', using: :gin
      add_concurrent_index :topic_id, name: 'index_topic_items_with_tags_on_topic_id', where: 'cardinality(tags) > 0'
      # Validation scans the table with a lock that still permits normal reads
      # and writes, after the short exclusive ADD CONSTRAINT lock is released.
      constraint = connection.check_constraints(:topic_items).find { |check| check.name == 'topic_items_tags_supported' }
      validate_check_constraint :topic_items, name: constraint.name unless constraint.validate?
    end

    # Preserve existing tags before the new application starts. Only tagged
    # roots need copying; never hold schema locks or rewrite every search row.
    each_batch('topics', 'cardinality(tags) > 0') do |ids|
      connection.select_values("SELECT id FROM topics WHERE id IN (#{ids.join(',')}) ORDER BY id FOR NO KEY UPDATE")
      execute <<~SQL
        UPDATE topic_items SET tags = topics.tags
        FROM topics
        WHERE topics.id IN (#{ids.join(',')})
          AND topic_items.topic_id = topics.id
          AND topic_items.itemable_type = topics.topicable_type
          AND topic_items.itemable_id = topics.topicable_id
          AND topic_items.kind IN ('new_discussion', 'poll_created')
          AND cardinality(topic_items.tags) = 0
      SQL
    end
  end

  def down
    with_short_lock_wait do
      remove_column :topic_items, :tags if column_exists?(:topic_items, :tags)
    end
    each_batch('pg_search_documents') do |ids|
      execute <<~SQL
        UPDATE pg_search_documents SET tags = topics.tags
        FROM topics
        WHERE pg_search_documents.id IN (#{ids.join(',')})
          AND topics.id = pg_search_documents.topic_id
          AND pg_search_documents.tags IS DISTINCT FROM topics.tags
      SQL
    end
  end

  private

  def add_concurrent_index(column, name:, **options)
    return if index_exists?(:topic_items, column, name: name, valid: true)

    # Interrupted concurrent builds leave an invalid index behind. Recreate it
    # rather than letting IF NOT EXISTS silently retain an unusable index.
    remove_index :topic_items, name: name, algorithm: :concurrently if index_exists?(:topic_items, name: name)
    add_index :topic_items, column, name: name, algorithm: :concurrently, **options
  end

  def each_batch(table, condition = 'TRUE')
    after_id = 0
    loop do
      ids = connection.select_values("SELECT id FROM #{table} WHERE id > #{after_id} AND #{condition} ORDER BY id LIMIT 500")
      break if ids.empty?

      connection.transaction do
        execute "SET LOCAL lock_timeout = '100ms'"
        execute "SET LOCAL statement_timeout = '1s'"
        yield ids
      end
      after_id = ids.last
      say "Preserved #{table} tags through id #{after_id}"
    end
  end
end

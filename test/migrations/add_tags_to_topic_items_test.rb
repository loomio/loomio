require 'test_helper'
require_relative '../../db/migrate/20261020000000_add_tags_to_topic_items'

class AddTagsToTopicItemsTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'copies legacy opening tags without retaining schema locks or rewriting search documents' do
    topic = topics(:discussion_topic)
    root_id = topic.topicable.created_topic_item.id
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Inherited search tag'), actor: users(:admin))
    comment_item_id = comment.created_topic_item.id
    document = PgSearch::Document.find_by!(searchable: comment)
    topic.update_columns(tags: ['Legacy'])
    migration = AddTagsToTopicItems.new
    migration.suppress_messages { migration.down }
    document.update_columns(tags: ['Legacy'])

    reader = independent_connection
    reader.exec("SET statement_timeout = '100ms'")
    observed = false
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      next unless payload[:sql].include?('UPDATE topic_items SET tags = topics.tags')

      observed = true
      assert_equal root_id.to_s, reader.exec("SELECT id FROM topic_items WHERE id = #{root_id}").first.fetch('id')
      assert_equal 1, reader.exec("UPDATE topic_items SET updated_at = updated_at WHERE id = #{comment_item_id}").cmd_tuples
    end
    assert_no_enqueued_jobs do
      migration.suppress_messages { migration.up }
    end
    TopicItem.reset_column_information

    assert observed
    assert_equal ['Legacy'], TopicItem.find(root_id).tags
    assert_equal ['Legacy'], document.reload.tags, 'Search tag backfill must run after deployment'
    assert ActiveRecord::Base.connection.index_exists?(:topic_items, :tags, valid: true)
    assert ActiveRecord::Base.connection.check_constraints(:topic_items).find { |constraint| constraint.name == 'topic_items_tags_supported' }.validate?
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    reader&.close
    restore_schema(migration)
  end

  test 'an interrupted concurrent index build can be retried without overwriting existing assignments' do
    migration = AddTagsToTopicItems.new
    root = topics(:discussion_topic).topicable.created_topic_item
    migration.suppress_messages { migration.down }
    migration.add_column :topic_items, :tags, :string, array: true, default: [], null: false
    assert_raises(ActiveRecord::RecordNotUnique) do
      ActiveRecord::Base.connection.execute('CREATE UNIQUE INDEX CONCURRENTLY index_topic_items_on_tags ON topic_items(tags)')
    end

    migration.suppress_messages { migration.up }
    TopicItem.reset_column_information
    root.reload.update_columns(tags: ['Current assignment'])
    topics(:discussion_topic).update_columns(tags: ['Old cache'])
    migration.suppress_messages { migration.up }

    assert_equal ['Current assignment'], root.reload.tags
    index = ActiveRecord::Base.connection.indexes(:topic_items).find { |candidate| candidate.name == 'index_topic_items_on_tags' }
    assert index.valid?
    assert_equal :gin, index.using
  ensure
    restore_schema(migration)
  end

  private

  def restore_schema(migration)
    migration&.suppress_messages { migration.up } unless ActiveRecord::Base.connection.column_exists?(:topic_items, :tags)
    TopicItem.reset_column_information
  end

  def independent_connection
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    PG.connect(**config.slice(:host, :port, :password).merge(dbname: config[:database], user: config[:username]).compact)
  end
end

require 'test_helper'

class ItemTagBackfillServiceTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'search backfill keeps explicit contribution tags and text while removing inherited vote and orphan tags' do
    topic = topics(:discussion_topic)
    actor = users(:admin)
    discussion = topic.topicable
    discussion.update_pg_search_document
    comment = CommentService.create(comment: Comment.new(parent: discussion, body: 'Tagged comment'), actor: actor)
    poll = PollService.create(params: {topic_id: topic.id, title: 'Tagged poll', poll_type: 'proposal',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: actor)
    stance = poll.stances.latest.find_by!(participant: actor)
    stance.choice = 'Agree'
    stance.reason = 'Vote reason'
    StanceService.create(stance: stance, actor: actor)
    assignments = [[discussion, ['Opening']], [poll, ['Poll']], [comment, ['Comment']]]
    assignments.each do |record, names|
      TopicItemService.update_tags(topic_item: record.created_topic_item, tags: names, actor: actor)
      record.update_pg_search_document
    end
    stance.update_pg_search_document
    orphan = PgSearch::Document.create!(searchable_type: 'Comment', searchable_id: Comment.maximum(:id) + 1,
      topic_id: topic.id, content: 'Orphan text', tags: ['Inherited'])
    documents = assignments.map { |record, _| PgSearch::Document.find_by!(searchable: record) }
    vote_document = PgSearch::Document.find_by!(searchable: stance)
    documents += [vote_document, orphan]
    documents.each { |document| document.update_columns(tags: ['Inherited']) }
    content_before = documents.to_h { |document| [document.id, document.attributes.except('tags')] }

    result = ItemTagBackfillService.new(phase: 'search', batch_size: 1000).run_batch

    assert result[:finished]
    assert_equal documents.size, result[:updated]
    assignments.each do |record, names|
      assert_equal names, PgSearch::Document.find_by!(searchable: record).tags
    end
    assert_empty vote_document.reload.tags
    assert_empty orphan.reload.tags
    documents.each { |document| assert_equal content_before.fetch(document.id), document.reload.attributes.except('tags') }
    assert_equal 0, ItemTagBackfillService.new(phase: 'search', batch_size: 1000).run_batch[:updated]
  end

  test 'small batches resume at their cursor and do not touch records beyond the captured maximum' do
    ids = Topic.order(:id).limit(4).ids
    Topic.where(id: ids).update_all(tags: ['Stale'])

    first = ItemTagBackfillService.new(after_id: 0, through_id: ids[2], batch_size: 2).run_batch
    assert_equal 2, first[:checked]
    assert_equal ids[1], first[:after_id]
    assert_not first[:finished]
    assert_equal ['Stale'], Topic.find(ids[2]).tags
    second = ItemTagBackfillService.new(after_id: first[:after_id], through_id: first[:through_id], batch_size: 1).run_batch

    assert second[:finished]
    assert_equal ids[2], second[:after_id]
    assert_not_equal ['Stale'], Topic.find(ids.first).tags
    assert_not_equal ['Stale'], Topic.find(ids[1]).tags
    assert_not_equal ['Stale'], Topic.find(ids[2]).tags
    assert_equal ['Stale'], Topic.find(ids.last).tags
  end

  test 'a slow update rolls back its batch and restores the connection timeout' do
    topic = topics(:discussion_topic)
    topic.topicable.created_topic_item.update_columns(tags: ['Current'])
    topic.update_columns(tags: ['Stale'])
    connection = ActiveRecord::Base.connection
    timeout_before = connection.select_value('SHOW statement_timeout')
    connection.execute(<<~SQL)
      CREATE FUNCTION pg_temp.delay_tag_backfill() RETURNS trigger LANGUAGE plpgsql AS $$
      BEGIN PERFORM pg_sleep(0.1); RETURN NEW; END; $$;
      CREATE TRIGGER delay_tag_backfill BEFORE UPDATE ON topics
      FOR EACH ROW EXECUTE FUNCTION pg_temp.delay_tag_backfill();
    SQL
    options = {after_id: topic.id - 1, through_id: topic.id, statement_timeout_ms: 20}

    assert_raises(ActiveRecord::QueryCanceled) { ItemTagBackfillService.new(**options).run_batch }
    assert_equal ['Stale'], topic.reload.tags
    assert_equal timeout_before, connection.select_value('SHOW statement_timeout')
    connection.execute('DROP TRIGGER delay_tag_backfill ON topics')

    result = ItemTagBackfillService.new(**options.except(:statement_timeout_ms)).run_batch
    assert_equal 1, result[:updated]
    assert_equal ['Current'], topic.reload.tags
  ensure
    connection&.execute('DROP TRIGGER IF EXISTS delay_tag_backfill ON topics')
  end

  test 'a busy owner times out without updates and can be retried after its edit commits' do
    topic = topics(:discussion_topic)
    topic.topicable.created_topic_item.update_columns(tags: ['Current'])
    topic.update_columns(tags: ['Stale'])
    writer = independent_connection
    writer.exec('BEGIN')
    writer.exec("SELECT id FROM topics WHERE id = #{topic.id} FOR UPDATE")
    connection = ActiveRecord::Base.connection
    timeouts_before = %w[lock_timeout statement_timeout].map { |setting| connection.select_value("SHOW #{setting}") }
    options = {after_id: topic.id - 1, through_id: topic.id}

    assert_raises(ActiveRecord::LockWaitTimeout) { ItemTagBackfillService.new(**options).run_batch }
    assert_equal ['Stale'], topic.reload.tags
    assert_equal timeouts_before, %w[lock_timeout statement_timeout].map { |setting| connection.select_value("SHOW #{setting}") }
    writer.exec('COMMIT')

    result = ItemTagBackfillService.new(**options).run_batch
    assert_equal 1, result[:updated]
    assert_equal ['Current'], topic.reload.tags
  ensure
    writer&.close
  end

  test 'backfill rejects invalid cursor scope and refuses an enclosing transaction' do
    [{phase: 'unknown'}, {after_id: -1}, {through_id: -1}, {batch_size: 0},
     {batch_size: 1001}, {statement_timeout_ms: 0}].each do |options|
      assert_raises(ArgumentError) { ItemTagBackfillService.new(**options) }
    end
    ActiveRecord::Base.transaction do
      assert_raises(ArgumentError) { ItemTagBackfillService.new.run_batch }
    end
  end

  private

  def independent_connection
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    PG.connect(**config.slice(:host, :port, :password).merge(dbname: config[:database], user: config[:username]).compact)
  end
end

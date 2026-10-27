require 'test_helper'

class ReindexSearchDocumentWorkerTest < ActiveSupport::TestCase
  setup do
    @user = users(:member_normal)
    @topic = topics(:discussion_topic)
    @comment = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Original search text'), actor: @user)
  end

  test 'indexes committed contributions in group and direct topics using current text and tags' do
    [ @comment, CommentService.create(comment: Comment.new(parent: topics(:direct_topic).topicable, body: 'Direct search text'), actor: users(:guest_normal)) ].each do |comment|
      assert_not PgSearch::Document.exists?(searchable: comment)
      TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: [ 'Budget' ], actor: comment.author)
      CommentService.update(comment: comment, params: { body: 'Current search text' }, actor: comment.author)

      2.times { ReindexSearchDocumentWorker.perform_now('Comment', comment.id) }

      document = PgSearch::Document.where(searchable: comment).sole
      assert_includes document.content, 'Current search text'
      refute_includes document.content, 'Original search text'
      assert_equal comment.topic_id, document.topic_id
      assert_equal [ 'Budget' ], document.tags
    end
  end

  test 'tag edits refresh existing documents only when the job runs' do
    ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
    clear_enqueued_jobs

    TopicItemService.update_tags(topic_item: @comment.created_topic_item, tags: [ 'Budget' ], actor: @user)

    assert_equal [], PgSearch::Document.find_by!(searchable: @comment).tags
    assert_enqueued_with(job: ReindexSearchDocumentWorker, args: [ 'Comment', @comment.id ])
    ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
    assert_equal [ 'Budget' ], PgSearch::Document.find_by!(searchable: @comment).tags
  end

  test 'discarding and deleting return without indexing and queued jobs remove documents' do
    [ false, true ].each do |destroy|
      comment = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Removed content'), actor: @user)
      ReindexSearchDocumentWorker.perform_now('Comment', comment.id)
      Comment.stub(:pg_search_insert_statement, ->(**) { raise 'search indexing unavailable' }) do
        if destroy
          CommentService.destroy(comment: comment, actor: @user)
        else
          CommentService.discard(comment: comment, actor: @user)
        end
      end
      assert PgSearch::Document.exists?(searchable: comment)
      assert_empty SearchDocumentQuery.current(PgSearch::Document.where(searchable: comment))

      ReindexSearchDocumentWorker.perform_now('Comment', comment.id)
      assert_not PgSearch::Document.exists?(searchable: comment)
    end
  end

  test 'failed replacement preserves the previous document and schedules a retry' do
    ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
    CommentService.update(comment: @comment, params: { body: 'Updated after failure' }, actor: @user)
    clear_enqueued_jobs

    Comment.stub(:pg_search_insert_statement, ->(**) { raise 'search indexing unavailable' }) do
      assert_enqueued_with(job: ReindexSearchDocumentWorker, args: [ 'Comment', @comment.id ]) do
        ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
      end
    end
    assert_includes PgSearch::Document.where(searchable: @comment).sole.content, 'Original search text'

    ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
    assert_includes PgSearch::Document.where(searchable: @comment).sole.content, 'Updated after failure'
  end

  test 'all searchable models defer indexing on save' do
    poll = PollService.create(params: { topic_id: @topic.id, title: 'Deferred poll', poll_type: 'proposal',
      closing_at: 2.days.from_now, poll_option_names: [ 'Agree' ] }, actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: @user)
    outcome = Outcome.create!(poll: poll, author: users(:admin), statement: 'Deferred outcome')
    records = [ @topic.topicable, @comment, poll, stance, outcome ]
    records.each do |record|
      clear_enqueued_jobs
      record.class.stub(:pg_search_insert_statement, ->(**) { raise 'search indexing unavailable' }) do
        record.save!
      end
      if record.is_a?(Poll)
        assert_enqueued_with(job: ReindexPollWorker, args: [ record.id ])
      else
        assert_enqueued_with(job: ReindexSearchDocumentWorker, args: [ record.class.name, record.id ])
      end
    end
  end
end

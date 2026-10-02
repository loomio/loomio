require 'test_helper'
require Rails.root.join('db/migrate/20261002000000_remove_hidden_vote_search_documents')

class RemoveHiddenVoteSearchDocumentsTest < ActiveSupport::TestCase
  test 'removes existing hidden vote conversations without deleting comments or unrelated search documents' do
    user = users(:user)
    admin = users(:admin)
    topic = topics(:discussion_topic)
    poll = PollService.create(
      params: {topic_id: topic.id, title: 'Search migration', poll_type: 'proposal',
               poll_option_names: ['Agree', 'Disagree'], closing_at: 2.days.from_now, hide_results: 'off'},
      actor: admin
    )
    stance = poll.stances.latest.find_by!(participant: user)
    stance.choice = 'Agree'
    stance.reason = 'A vote reason in the timeline'
    StanceService.create(stance: stance, actor: user)
    reply = CommentService.create(comment: Comment.new(parent: stance, body: 'Hidden conversation'), actor: user)
    nested = CommentService.create(comment: Comment.new(parent: reply, body: 'Nested hidden conversation'), actor: user)
    direct = CommentService.create(comment: Comment.new(parent: poll, body: 'Hidden direct poll comment'), actor: user)
    ordinary = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Ordinary conversation'), actor: user)
    [reply, nested, direct, ordinary].each(&:update_pg_search_document)
    reply_ids = [reply.id, nested.id, direct.id]
    documents = PgSearch::Document.where(searchable_type: 'Comment', searchable_id: reply_ids)
    assert_equal 3, documents.count
    # Represent an already-hidden poll whose index predates these indexing rules.
    poll.update_columns(hide_results: Poll.hide_results.fetch('until_closed'))

    RemoveHiddenVoteSearchDocuments.new.migrate(:up)

    assert_empty documents
    assert_equal 3, Comment.where(id: reply_ids).count
    assert PgSearch::Document.where(searchable_type: 'Comment', searchable_id: ordinary.id).exists?
    PollService.close(poll: poll.reload, actor: admin)
    ReindexPollWorker.perform_now(poll.id)
    assert_equal 3, documents.count
  end
end

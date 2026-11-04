require 'test_helper'
require Rails.root.join('db/migrate/20261022000001_restore_poll_comment_search_documents')

class RestorePollCommentSearchDocumentsTest < ActiveSupport::TestCase
  test 'restores open poll comments without indexing hidden vote reasons' do
    poll = PollService.create(params: {topic_id: topics(:discussion_topic).id,
      title: 'Restore comments', poll_type: 'proposal', hide_results: 'until_closed',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: users(:member_normal))
    stance.choice = 'Agree'
    stance.reason = 'Vote reason still hidden'
    StanceService.create(stance: stance, actor: users(:member_normal))
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Ordinary comment'), actor: users(:member_normal))
    PgSearch::Document.where(searchable: comment).delete_all
    clear_enqueued_jobs

    assert_enqueued_with(job: ReindexPollWorker, args: [poll.id]) do
      RestorePollCommentSearchDocuments.new.migrate(:up)
    end
    perform_enqueued_jobs(only: ReindexPollWorker)
    assert PgSearch::Document.exists?(searchable: comment)
    assert_not PgSearch::Document.exists?(searchable: stance)
  end
end

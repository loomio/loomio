require 'test_helper'
require_relative '../../db/migrate/20261022000000_cache_topic_tag_summaries'

class CacheTopicTagSummariesTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'schema migration defers rebuilding kept tag summaries until the background backfill' do
    topic = topics(:discussion_topic)
    topic.update!(allow_concurrent_polls: true)
    actor = users(:admin)
    root = topic.topicable.created_topic_item
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Tagged reply'), actor: actor)
    discarded = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Removed reply'), actor: actor)
    TopicItemService.update_tags(topic_item: root, tags: ['Shared'], actor: actor)
    TopicItemService.update_tags(topic_item: comment.created_topic_item, tags: ['Shared', 'Reply'], actor: actor)
    TopicItemService.update_tags(topic_item: discarded.created_topic_item, tags: ['Removed'], actor: actor)
    CommentService.discard(comment: discarded, actor: actor)
    poll = PollService.create(params: {topic_id: topic.id, poll_type: 'proposal', title: 'Poll',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: actor)
    poll_comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Previously public'), actor: actor)
    TopicItemService.update_tags(topic_item: poll_comment.created_topic_item, tags: ['Public tag'], actor: actor)
    poll.update!(hide_results: 'until_closed')
    removed_poll = PollService.create(params: {topic_id: topic.id, poll_type: 'proposal', title: 'Removed poll',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: actor)
    removed_reply = CommentService.create(comment: Comment.new(parent: removed_poll, body: 'Reply to removed poll'), actor: actor)
    TopicItemService.update_tags(topic_item: removed_reply.created_topic_item, tags: ['Removed poll reply'], actor: actor)
    PollService.discard(poll: removed_poll, actor: actor)
    direct = topics(:direct_topic)
    TopicItemService.update_tags(topic_item: direct.topicable.created_topic_item, tags: ['Direct'], actor: users(:guest_admin_normal))
    Topic.where(id: [topic.id, direct.id]).update_all(tags: ['Stale aggregate'])

    migration = CacheTopicTagSummaries.new
    assert_no_enqueued_jobs do
      migration.suppress_messages do
        migration.down
        migration.up
      end
    end
    Topic.reset_column_information

    assert_equal ['Stale aggregate'], topic.reload.tags
    assert_not topic.has_tagged_replies
    ItemTagBackfillService.new.run_batch

    assert_equal ['Public tag', 'Reply', 'Shared'], topic.reload.tags
    assert topic.has_tagged_replies
    assert_equal ['Direct'], direct.reload.tags
    assert_not direct.has_tagged_replies
    assert_not topics(:subgroup_discussion_topic).has_tagged_replies
    assert_equal ['Removed'], discarded.created_topic_item.tags
  ensure
    Topic.reset_column_information
  end
end

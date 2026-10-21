require 'test_helper'

class TopicItemTagsTest < ActiveSupport::TestCase
  setup do
    @topic = topics(:discussion_topic)
    @admin = users(:admin)
    @author = users(:member_normal)
    @root = topic_items(:discussion_created_topic_item)
    @topic.topicable.update_pg_search_document
    @comment = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Budget insurance'), actor: @author)
    @item = @comment.created_topic_item
  end

  test 'explicit assignments aggregate without being inherited by siblings or the opening discussion' do
    tag(@root, ['Governance'])
    tag(@item, [' Budget ', 'Budget'])

    assert_equal ['Budget', 'Governance'], @topic.reload.tags
    assert_equal ['Governance'], @root.reload.tags
    assert_equal ['Budget'], @item.reload.tags
    assert_equal ['Budget'], PgSearch::Document.find_by!(searchable: @comment).tags
    assert_equal ['Governance'], PgSearch::Document.find_by!(searchable: @topic.topicable).tags

    tag(@root, [])
    assert_equal ['Budget'], @topic.reload.tags
  end

  test 'tagging uses the current access-control matrix and never grants access to revoked authors' do
    allowed = %i[admin guest_admin_normal member_normal]
    denied = %i[member_quiet guest_normal alien_quiet non_guest_loud former_guest_loud former_member_loud inactive_member_loud inactive_guest_loud]
    allowed.each { |role| assert users(role).can?(:update_tags, @item), role.to_s }
    denied.each { |role| assert_not users(role).can?(:update_tags, @item), role.to_s }
    assert_not LoggedOutUser.new.can?(:update_tags, @item)

    memberships(:member_normal_membership).update!(revoked_at: Time.current)
    assert_not @author.can?(:update_tags, @item)
    assert_raises(CanCan::AccessDenied) { tag(@item, ['Budget']) }
  end

  test 'sidebar tag visibility covers unloaded replies sharing the opening tags and updates when cleared' do
    tag(@root, ['Governance'])
    serialized_topic = -> {
      JSON.parse(MessageChannelService.serialize_shared_models([@root]).to_json).fetch('topics').find { |row| row['id'] == @topic.id }
    }
    assert_not serialized_topic.call.fetch('has_tagged_replies')
    tag(@item, ['Governance'])
    assert_equal ['Governance'], @topic.reload.tags
    assert serialized_topic.call.fetch('has_tagged_replies')
    tag(@item, [])
    assert_equal ['Governance'], @topic.reload.tags
    assert_not serialized_topic.call.fetch('has_tagged_replies')
  end

  test 'direct-topic authors and coordinators can tag but ordinary or revoked guests cannot tag others' do
    topic = topics(:direct_topic)
    author = users(:guest_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Direct budget'), actor: author)
    item = comment.created_topic_item
    assert author.can?(:update_tags, item)
    assert users(:guest_admin_normal).can?(:update_tags, item)
    %i[guest_quiet non_guest_loud former_guest_loud inactive_guest_loud alien_quiet].each do |role|
      assert_not users(role).can?(:update_tags, item), role.to_s
    end
    TopicItemService.update_tags(topic_item: item, tags: ['Private label'], actor: author)
    assert_equal ['Private label'], topic.reload.tags
    assert_not Tag.exists?(name: 'Private label')
  end

  test 'tag creation setting is separate from assignment permission' do
    @topic.group.update!(members_can_create_tags: false)
    Tag.create!(group: @topic.group, name: 'Existing')
    tag(@item, ['Existing'])
    tag(@item, ['Existing', 'New'])
    assert_equal ['Existing'], @item.reload.tags
    assert_not Tag.exists?(group: @topic.group, name: 'New')
    tag(@item, ['New'], @admin)
    assert_equal ['New'], @topic.reload.tags
  end

  test 'closed polls and outcomes can be tagged without permission to edit their contents' do
    poll = make_poll
    poll.update!(closed_at: Time.current)
    item = poll.created_topic_item
    assert_not @admin.can?(:update, poll)
    tag(item, ['Decision'], @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    tag(outcome.created_topic_item, ['Follow up'], @admin)
    assert_equal ['Decision', 'Follow up'], @topic.reload.tags
    @topic.update!(locked_at: Time.current)
    assert_not @admin.can?(:update_tags, item.reload)
  end

  test 'discard restore and deletion update aggregates while preserving assignments on discarded content' do
    tag(@item, ['Budget'])
    CommentService.discard(comment: @comment, actor: @author)
    assert_empty @topic.reload.tags
    assert_equal ['Budget'], @item.reload.tags
    CommentService.undiscard(comment: @comment, actor: @author)
    assert_equal ['Budget'], @topic.reload.tags
    CommentService.destroy(comment: @comment, actor: @admin)
    assert_empty @topic.reload.tags
  end

  test 'tag changes and their aggregate roll back together' do
    TopicItem.transaction(requires_new: true) do
      tag(@item, ['Rollback label'])
      assert_equal ['Rollback label'], @topic.reload.tags
      assert Tag.exists?(group: @topic.group, name: 'Rollback label')
      raise ActiveRecord::Rollback
    end
    assert_empty @item.reload.tags
    assert_empty @topic.reload.tags
    assert_empty PgSearch::Document.find_by!(searchable: @comment).tags
    assert_not Tag.exists?(group: @topic.group, name: 'Rollback label')
  end

  test 'discarding a poll removes its conversation from tag summaries without deleting assignments' do
    poll = make_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Poll reply'), actor: @author)
    tag(comment.created_topic_item, ['Reply label'])
    PollService.discard(poll: poll, actor: @admin)
    assert_empty @topic.reload.tags
    assert_not @topic.has_tagged_replies
    assert_equal ['Reply label'], comment.created_topic_item.tags
    poll.update!(discarded_at: nil, discarded_by: nil)
    assert_equal ['Reply label'], @topic.reload.tags
    assert @topic.has_tagged_replies
  end

  test 'subgroup assignments create colored organization metadata without waiting for a job' do
    topic = topics(:subgroup_discussion_topic)
    TopicItemService.update_tags(topic_item: topic.topicable.created_topic_item, tags: ['Subgroup label'], actor: @admin)
    metadata = topic.group.parent_or_self.tags.find_by!(name: 'Subgroup label')
    assert_includes Tag::COLORS, metadata.color
    assert_equal [topic.group_id], metadata.used_group_ids
    TagService.update_org_tags(topic.group_id)
    assert_equal metadata.color, metadata.reload.color
    assert_not topic.group.tags.exists?(name: 'Subgroup label')
  end

  test 'comment authors can tag comments they can write regardless of result visibility' do
    %w[off until_vote until_closed].each do |mode|
      poll = make_poll
      poll.update!(hide_results: mode)
      comment = Comment.new(parent: poll, body: 'Tagged comment')
      assert @author.can?(:create, comment), mode
      CommentService.create(comment: comment, actor: @author)
      tag(comment.created_topic_item, ["Label #{mode}"])

      assert_equal ["Label #{mode}"], comment.created_topic_item.tags, mode
      assert_includes @topic.reload.tags, "Label #{mode}", mode
      assert @topic.group.tags.find_by!(name: "Label #{mode}").color.present?, mode
      poll.update!(closed_at: Time.current)
    end
  end

  test 'existing tags remain shared metadata when results are hidden and hidden comments leave search' do
    %w[off until_vote until_closed].each do |mode|
      poll = make_poll
      comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Insurance confidential'), actor: @author)
      item = comment.created_topic_item
      tag(item, ['Sensitive'])
      poll.update!(hide_results: mode)
      assert_includes @topic.reload.tags, 'Sensitive', mode
      assert JSON.parse(MessageChannelService.serialize_shared_models([@item]).to_json).fetch('topics').first.fetch('has_tagged_replies'), mode
      assert @author.can?(:update_tags, item), mode
      shared = JSON.parse(MessageChannelService.serialize_shared_models([item]).to_json)
      row = shared.fetch('topic_items').find { |entry| entry['id'] == item.id }
      assert_equal ['Sensitive'], row['tags'], mode
      comment.update_pg_search_document
      doc = PgSearch::Document.find_by(searchable: comment)
      if mode == 'until_closed'
        assert_nil doc
      else
        assert_equal ['Sensitive'], doc.tags
      end
      poll.update!(closed_at: Time.current)
      assert_includes @topic.reload.tags, 'Sensitive'
      assert_equal ['Sensitive'], item.reload.tags
      item.update!(tags: [])
    end
  end

  test 'moving tagged branches refreshes both topics and keeps item assignments' do
    tag(@item, ['Budget'])
    target = topics(:subgroup_discussion_topic)
    MoveCommentsWorker.perform_now([@item.id], @topic.id, target.id, @admin.id)
    assert_empty @topic.reload.tags
    assert_equal ['Budget'], target.reload.tags
    assert_equal ['Budget'], @item.reload.tags
    assert_not @topic.has_tagged_replies
    assert_empty @topic.root_tags
    assert target.has_tagged_replies
    assert_empty target.root_tags
  end

  test 'repair rebuilds cached tag summaries after restoring the root sequence' do
    tag(@root, ['Opening'], @admin)
    tag(@item, ['Reply'])
    @root.update_columns(sequence_id: nil)
    @item.update_columns(sequence_id: 0)
    @topic.update_columns(root_tags: ['Stale'], has_tagged_replies: false)

    TopicService.repair(@topic.id)

    assert_equal ['Opening', 'Reply'], @topic.reload.tags
    assert_equal ['Opening'], @topic.root_tags
    assert @topic.has_tagged_replies
  end

  test 'hiding poll results rolls search removal back with the poll and leaves tags unchanged' do
    poll = make_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Initially public'), actor: @author)
    tag(comment.created_topic_item, ['Shared label'])
    assert PgSearch::Document.exists?(searchable: comment)

    Poll.transaction(requires_new: true) do
      poll.update!(hide_results: 'until_closed')
      assert_not PgSearch::Document.exists?(searchable: comment)
      assert_equal ['Shared label'], @topic.reload.tags
      raise ActiveRecord::Rollback
    end

    assert_equal 'off', poll.reload.hide_results
    assert PgSearch::Document.exists?(searchable: comment)
    assert_equal ['Shared label'], comment.created_topic_item.tags
  end

  test 'hidden comments remain taggable at the display cap while staying out of search' do
    @topic.update!(max_depth: 1)
    poll = make_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Poll reply'), actor: @author)
    reply = CommentService.create(comment: Comment.new(parent: comment, body: 'Nested poll reply'), actor: @author)
    tag(reply.created_topic_item, ['Hidden branch'])
    assert_equal poll.created_topic_item.parent_id, reply.created_topic_item.parent_id
    poll.update!(hide_results: 'until_closed')
    assert_equal ['Hidden branch'], @topic.reload.tags
    assert @author.can?(:update_tags, reply.created_topic_item)
    assert_not PgSearch::Document.exists?(searchable: reply)
  end

  test 'reopening a poll hides searches while its outcome conversation remains taggable' do
    poll = make_poll
    PollService.close(poll: poll, actor: @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    comment = CommentService.create(comment: Comment.new(parent: outcome, body: 'Outcome reply'), actor: @author)
    tag(comment.created_topic_item, ['Outcome discussion'])
    assert PgSearch::Document.exists?(searchable: comment)
    poll.update!(hide_results: 'until_closed')
    PollService.reopen(poll: poll, params: {closing_at: 2.days.from_now}, actor: @admin)

    assert @author.can?(:update_tags, comment.created_topic_item)
    assert_not PgSearch::Document.exists?(searchable: comment)
    assert_equal ['Outcome discussion'], @topic.reload.tags
    assert_equal ['Outcome discussion'], comment.created_topic_item.tags
    poll.discard!
    assert_empty @topic.reload.tags
  end

  test 'anonymous poll tagging changes no ballots results or quorum settings' do
    poll = PollService.create(params: {topic_id: @topic.id, poll_type: 'proposal', title: 'Anonymous decision',
      anonymous: true, quorum_pct: 50, poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: @admin)
    snapshot = poll.reload.attributes
    tag(poll.created_topic_item, ['Decision'], @admin)
    assert_equal snapshot, poll.reload.attributes
    assert_empty poll.stances
    assert_not @admin.can?(:update_tags, poll.anonymous_ballots.build)
    assert_equal ['Decision'], @topic.reload.tags
  end

  test 'generic topic edits route tag writes to the opening item and retain child assignments' do
    tag(@item, ['Budget'])
    TopicService.update(topic: @topic, params: {tags: ['Governance']}, actor: @admin)
    assert_equal ['Governance'], @root.reload.tags
    assert_equal ['Budget', 'Governance'], @topic.reload.tags
  end

  test 'archives retain public tags while markdown omits hidden comment content' do
    poll = make_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Poll reply'), actor: @author)
    item = comment.created_topic_item
    tag(item, ['Hidden branch'])
    assert_equal ['Hidden branch'], GroupExportService.export_record(item, 'topic_items').fetch('tags')
    assert_includes ThreadMarkdownService.render(topic: @topic.reload, user: @author), 'Tags: Hidden branch'
    poll.update!(hide_results: 'until_closed')
    assert_equal ['Hidden branch'], GroupExportService.export_record(item, 'topic_items').fetch('tags')
    markdown = ThreadMarkdownService.render(topic: @topic.reload, user: @author)
    assert_includes markdown, 'Hidden branch'
    refute_includes markdown, 'Poll reply'
  end

  test 'organization rename merge and delete apply to every item assignment' do
    tag(@root, ['Budget'], @admin)
    tag(@item, ['Budget', 'Finance'])
    TagService.update_org_tags(@topic.group_id)
    UpdateTagWorker.perform_now(@topic.group_id, 'Budget', 'Finance', '#abcdef')
    assert_equal ['Finance'], @root.reload.tags
    assert_equal ['Finance'], @item.reload.tags
    assert_equal ['Finance'], @topic.reload.tags
    TagService.destroy_by_name(@topic.group_id, 'Finance')
    assert_empty @item.reload.tags
    assert_empty @topic.reload.tags
    assert_not Tag.exists?(group_id: @topic.group_id, name: 'Finance')
  end

  test 'stances ballots and administrative timeline entries cannot acquire tags' do
    edited = TopicItems::DiscussionEdited.create!(itemable: @topic.topicable, user: @admin)
    assert_not @admin.can?(:update_tags, edited)
    assert_raises(ActiveRecord::RecordInvalid) { edited.update!(tags: ['Budget']) }
    assert_raises(ActiveRecord::StatementInvalid) do
      TopicItem.transaction(requires_new: true) { edited.update_columns(tags: ['Budget']) }
    end
  end

  private

  def tag(item, tags, actor = @author)
    actor = @admin if item == @root && actor == @author
    TopicItemService.update_tags(topic_item: item, tags: tags, actor: actor)
  end

  def make_poll
    PollService.create(params: {topic_id: @topic.id, poll_type: 'proposal', title: 'Budget poll',
      poll_option_names: ['Agree', 'Disagree'], closing_at: 2.days.from_now}, actor: @admin)
  end
end

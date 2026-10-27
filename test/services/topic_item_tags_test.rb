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
    perform_enqueued_jobs(only: [ReindexSearchDocumentWorker, ReindexPollWorker])

    assert_equal ['Budget', 'Governance'], @topic.reload.tags
    assert_equal ['Governance'], @root.reload.tags
    assert_equal ['Budget'], @item.reload.tags
    assert_equal ['Budget'], PgSearch::Document.find_by!(searchable: @comment).tags
    assert_equal ['Governance'], PgSearch::Document.find_by!(searchable: @topic.topicable).tags

    tag(@root, [])
    assert_equal ['Budget'], @topic.reload.tags
  end

  test 'reindexing correlates discussion poll outcome and comment tags to their own items' do
    poll = make_poll
    PollService.close(poll: poll, actor: @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    sibling = CommentService.create(comment: Comment.new(parent: @topic.topicable, body: 'Untagged reply'), actor: @author)
    assignments = [[@topic.topicable, ['Governance']], [poll, ['Decision']],
      [outcome, ['Follow up']], [@comment, ['Budget']], [sibling, []]]
    assignments.each { |record, names| tag(record.created_topic_item, names, @admin) }

    SearchService.reindex_by_discussion_id(@topic.topicable_id)

    assignments.each do |record, names|
      assert_equal names, PgSearch::Document.find_by!(searchable: record).tags, record.class.name
    end
  end

  test 'tagging uses the current access-control matrix and never grants access to revoked authors' do
    @topic.group.update!(members_can_edit_discussions: false)
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

  test 'context editing allows tagging every contribution while preserving the access-control matrix' do
    @topic.group.update!(members_can_edit_discussions: true)
    poll = make_poll
    PollService.close(poll: poll, actor: @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    items = [@root, poll.created_topic_item, outcome.created_topic_item, @item]
    allowed = %i[admin guest_admin_normal member_normal member_quiet guest_normal]
    denied = %i[alien_quiet non_guest_loud former_guest_loud former_member_loud inactive_member_loud inactive_guest_loud]

    items.each do |item|
      allowed.each { |role| assert users(role).can?(:update_tags, item), "#{item.kind}: #{role}" }
      denied.each { |role| assert_not users(role).can?(:update_tags, item), "#{item.kind}: #{role}" }
      assert_not LoggedOutUser.new.can?(:update_tags, item)
      TopicItemService.update_tags(topic_item: item, tags: ['Organized'], actor: users(:member_quiet))
      assert_equal ['Organized'], item.reload.tags
    end

    @topic.group.update!(members_can_edit_discussions: false)
    items.each { |item| assert_not users(:member_quiet).can?(:update_tags, item), item.kind }
  end

  test 'context editors cannot tag locked discarded or disabled threads or removed contributions' do
    @topic.group.update!(members_can_edit_discussions: true)
    editor = users(:member_quiet)
    assert editor.can?(:update_tags, @item)

    @topic.update!(locked_at: Time.current)
    assert_raises(CanCan::AccessDenied) { tag(@item, ['Blocked'], editor) }
    @topic.update!(locked_at: nil, discarded_at: Time.current)
    assert_raises(CanCan::AccessDenied) { tag(@item, ['Blocked'], editor) }
    @topic.update!(discarded_at: nil)
    @comment.update!(discarded_at: Time.current)
    assert_raises(CanCan::AccessDenied) { tag(@item, ['Blocked'], editor) }
    @comment.update!(discarded_at: nil)
    subscription = Subscription.create!(plan: 'free', state: 'on_hold')
    @topic.group.update!(subscription: subscription)
    assert_raises(CanCan::AccessDenied) { tag(@item, ['Blocked'], editor) }
    assert_empty @item.reload.tags
  end

  test 'member editing permits tagging the opening poll and replies in a standalone poll thread' do
    poll = PollService.create(params: {group_id: @topic.group_id, poll_type: 'proposal', title: 'Standalone poll',
      poll_option_names: ['Agree'], closing_at: 2.days.from_now}, actor: @admin)
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Follow up'), actor: @admin)
    editor = users(:member_quiet)
    @topic.group.update!(members_can_edit_discussions: false)
    items = [poll.created_topic_item, comment.created_topic_item]
    items.each { |item| assert_not editor.can?(:update_tags, item) }

    @topic.group.update!(members_can_edit_discussions: true)
    items.each do |item|
      TopicItemService.update_tags(topic_item: item, tags: ['Organized'], actor: editor)
      assert_equal ['Organized'], item.reload.tags
    end
  end

  test 'direct-topic participants can tag others contributions but revoked and unrelated users cannot' do
    topic = topics(:direct_topic)
    author = users(:guest_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: 'Direct budget'), actor: author)
    item = comment.created_topic_item
    assert author.can?(:update_tags, item)
    assert users(:guest_admin_normal).can?(:update_tags, item)
    assert users(:guest_quiet).can?(:update_tags, item)
    %i[non_guest_loud former_guest_loud inactive_guest_loud alien_quiet].each do |role|
      assert_not users(role).can?(:update_tags, item), role.to_s
    end
    TopicItemService.update_tags(topic_item: item, tags: ['Private label'], actor: users(:guest_quiet))
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
    ReindexSearchDocumentWorker.perform_now('Comment', @comment.id)
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

  test 'discarded poll ancestry excludes nested stance and outcome comments even at the display cap' do
    @topic.update!(max_depth: 1)
    poll = make_poll
    stance = poll.stances.latest.find_by!(participant: @admin)
    stance.choice = 'Agree'
    stance.reason = 'Vote reason'
    StanceService.create(stance: stance, actor: @admin)
    PollService.close(poll: poll, actor: @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    replies = [stance, outcome].map do |parent|
      comment = CommentService.create(comment: Comment.new(parent: parent, body: 'Parent reply'), actor: @author)
      reply = CommentService.create(comment: Comment.new(parent: comment, body: 'Nested reply'), actor: @author)
      tag(reply.created_topic_item, [parent.class.name])
      reply
    end

    poll.discard!
    assert_empty @topic.reload.tags
    replies.each do |reply|
      assert_not reply.created_topic_item.tags_assignable?
      assert_equal [reply.parent.parent_type], reply.created_topic_item.tags
      reply.update_pg_search_document
      assert_not PgSearch::Document.exists?(searchable: reply)
    end
    assert @item.tags_assignable?, 'An unrelated discussion reply stays assignable'

    poll.update!(discarded_at: nil, discarded_by: nil)
    assert_equal ['Outcome', 'Stance'], @topic.reload.tags
    replies.each { |reply| assert reply.created_topic_item.tags_assignable? }
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

  test 'existing comment tags stay shared and searchable regardless of result visibility' do
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
      assert_equal ['Sensitive'], doc.tags
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
    assert target.has_tagged_replies
  end

  test 'repair rebuilds cached tag summaries after restoring the root sequence' do
    tag(@root, ['Opening'], @admin)
    tag(@item, ['Reply'])
    @root.update_columns(sequence_id: nil)
    @item.update_columns(sequence_id: 0)
    @topic.update_columns(tags: ['Stale'], has_tagged_replies: false)

    TopicService.repair(@topic.id)

    assert_equal ['Opening', 'Reply'], @topic.reload.tags
    assert_equal ['Opening'], @topic.topicable.created_topic_item.tags
    assert @topic.has_tagged_replies
  end

  test 'poll comments stay taggable and searchable at the display cap' do
    @topic.update!(max_depth: 1)
    poll = make_poll
    comment = CommentService.create(comment: Comment.new(parent: poll, body: 'Poll reply'), actor: @author)
    reply = CommentService.create(comment: Comment.new(parent: comment, body: 'Nested poll reply'), actor: @author)
    tag(reply.created_topic_item, ['Hidden branch'])
    assert_equal poll.created_topic_item.parent_id, reply.created_topic_item.parent_id
    poll.update!(hide_results: 'until_closed')
    assert_equal ['Hidden branch'], @topic.reload.tags
    assert @author.can?(:update_tags, reply.created_topic_item)
    ReindexPollWorker.perform_now(poll.id)
    assert PgSearch::Document.exists?(searchable: reply)
  end

  test 'reopening an eligible poll keeps outcome conversations taggable and searchable' do
    poll = make_poll
    PollService.close(poll: poll, actor: @admin)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: 'Proceed'), actor: @admin)
    comment = CommentService.create(comment: Comment.new(parent: outcome, body: 'Outcome reply'), actor: @author)
    tag(comment.created_topic_item, ['Outcome discussion'])
    ReindexSearchDocumentWorker.perform_now('Comment', comment.id)
    assert PgSearch::Document.exists?(searchable: comment)
    poll.update!(hide_results: 'until_vote')
    PollService.reopen(poll: poll, params: {closing_at: 2.days.from_now}, actor: @admin)

    assert @author.can?(:update_tags, comment.created_topic_item)
    assert PgSearch::Document.exists?(searchable: comment)
    assert_equal ['Outcome discussion'], @topic.reload.tags
    assert_equal ['Outcome discussion'], comment.created_topic_item.tags
    poll.discard!
    assert_empty @topic.reload.tags
    assert_empty SearchDocumentQuery.current(PgSearch::Document.where(searchable: comment))
    ReindexPollWorker.perform_now(poll.id)
    assert_not PgSearch::Document.exists?(searchable: comment)
    SearchService.reindex_by_comment_id(comment.id)
    assert_not PgSearch::Document.exists?(searchable: comment)
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

  test 'archives and markdown include poll comments and tags while results are hidden' do
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
    assert_includes markdown, 'Poll reply'
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

require 'test_helper'

class TopicServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)

    @discussion = DiscussionService.create(params: {
      title: "Test Discussion",
      group_id: @group.id,
      max_depth: 2
    }, actor: @user)
    @topic = @discussion.topic

    @comment1 = Comment.new(body: "comment1", parent: @discussion)
    @comment2 = Comment.new(body: "comment2", parent: @comment1)
    @comment3 = Comment.new(body: "comment3", parent: @comment2)

    @discussion_event = @discussion.created_topic_item
    @comment1_event = CommentService.create(comment: @comment1, actor: @user)
    @comment2_event = CommentService.create(comment: @comment2, actor: @user)
    @comment3_event = CommentService.create(comment: @comment3, actor: @user)

    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now,
      group_id: @group.id,
      topic_id: @topic.id
    }, actor: @user)
    @poll_created_topic_item = poll.created_topic_item
  end

  test "flattens topic_items to max_depth 1" do
    @topic.update!(max_depth: 1)
    TopicService.repair(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_topic_item].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 1, @comment2_event.depth
    assert_equal 1, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @discussion_event.id, @comment2_event.parent_id
    assert_equal @discussion_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_topic_item.parent_id
  end

  test "branches topic_items at max_depth 2" do
    @topic.update!(max_depth: 2)
    TopicService.repair(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_topic_item].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 2, @comment2_event.depth
    assert_equal 2, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @comment1_event.id, @comment2_event.parent_id
    assert_equal @comment1_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_topic_item.parent_id
  end

  test "branches topic_items at max_depth 3" do
    @topic.update!(max_depth: 3)
    TopicService.repair(@topic.id)

    [@comment1_event, @comment2_event, @comment3_event, @poll_created_topic_item].each(&:reload)

    assert_equal 1, @comment1_event.depth
    assert_equal 2, @comment2_event.depth
    assert_equal 3, @comment3_event.depth

    assert_equal @discussion_event.id, @comment1_event.parent_id
    assert_equal @comment1_event.id, @comment2_event.parent_id
    assert_equal @comment2_event.id, @comment3_event.parent_id
    assert_equal @discussion_event.id, @poll_created_topic_item.parent_id
  end


  test "repair clears stale parent from root topic_item" do
    poll = PollService.create(params: {
      title: "Standalone Poll",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 5.days.from_now,
      group_id: @group.id
    }, actor: @user)
    created_topic_item = poll.created_topic_item
    created_topic_item.update_columns(parent_id: created_topic_item.id)

    TopicService.repair(poll.topic_id)

    assert_nil created_topic_item.reload.parent_id
    assert_equal 0, created_topic_item.sequence_id
  end

  test "repair ignores a topic whose topicable was concurrently removed" do
    Topic.stub(:find_by, @topic) do
      @topic.stub(:topicable, nil) do
        assert_nothing_raised { TopicService.repair(@topic.id) }
      end
    end
  end

  test "repair excludes children from another topic from child counts" do
    target = DiscussionService.create(
      params: {title: "Target discussion", group_id: @group.id},
      actor: @user
    )
    TopicItem.create!(
      kind: "discussion_edited",
      itemable: @discussion,
      topic: target.topic,
      parent: @discussion_event,
      user: @user
    )

    TopicService.repair(@topic.id)
    TopicService.verify_integrity!(@topic.id)

    expected_count = TopicItem.where(
      parent_id: @discussion_event.id,
      topic_id: @topic.id
    ).count
    assert_equal expected_count, @discussion_event.reload.child_count
  end

  test "verify_integrity raises for an invalid topic_item tree" do
    @discussion_event.update_columns(child_count: 999)

    error = assert_raises(TopicService::IntegrityError) do
      TopicService.verify_integrity!(@topic.id)
    end

    assert_match(/topic_item #{@discussion_event.id} child_count/, error.message)
  end

  # -- Move --

  test "move moves discussion to a public_only group" do
    admin = users(:admin)
    public_group = groups(:public_group)
    public_group.add_member!(admin)

    discussion = discussions(:discussion)
    TopicService.move(topic: discussion.topic, params: { group_id: public_group.id }, actor: admin)
    assert_equal false, discussion.topic.reload.private
  end

  test "move updates privacy for private_only groups" do
    admin = users(:admin)
    public_group = groups(:public_group)
    public_group.add_admin!(admin)
    subgroup = groups(:subgroup)

    discussion = DiscussionService.create(params: { title: "Test", group_id: public_group.id, private: false }, actor: admin)
    assert_equal false, discussion.topic.private
    TopicService.move(topic: discussion.topic, params: { group_id: subgroup.id }, actor: admin)
    assert_equal true, discussion.topic.reload.private
  end

  test "move versions the topic group without recording it on the topic_item" do
    admin = users(:admin)
    alien_group = groups(:alien_group)
    alien_group.add_member!(admin)

    discussion = discussions(:discussion)
    source_group_id = discussion.topic.group_id

    assert_difference -> { discussion.topic.versions.count }, 1 do
      TopicService.move(topic: discussion.topic, params: { group_id: alien_group.id }, actor: admin)
    end

    assert_equal alien_group.id, discussion.topic.reload.group_id
    assert_equal [source_group_id, alien_group.id], discussion.topic.versions.last.changeset['group_id']

    moved_event = discussion.topic_items.where(kind: 'discussion_moved').order(:id).last!
    assert_equal admin.id, moved_event.user_id
    assert_not moved_event.custom_fields.key?('source_group_id')
  end

  test "move converts a group discussion to a direct thread for its participants" do
    mover = users(:admin)
    voter = users(:member)
    commenter = User.create!(
      name: "Direct commenter",
      email: "direct-commenter-#{SecureRandom.hex(4)}@example.com",
      username: "directcommenter#{SecureRandom.hex(4)}",
      email_verified: true
    )
    reactor = User.create!(
      name: "Direct reactor",
      email: "direct-reactor-#{SecureRandom.hex(4)}@example.com",
      username: "directreactor#{SecureRandom.hex(4)}",
      email_verified: true
    )
    observer = User.create!(
      name: "Direct observer",
      email: "direct-observer-#{SecureRandom.hex(4)}@example.com",
      username: "directobserver#{SecureRandom.hex(4)}",
      email_verified: true
    )
    [commenter, reactor, observer].each { |user| @group.add_member!(user) }

    comment = Comment.new(body: "Participating by commenting", parent: @discussion)
    CommentService.create(comment:, actor: commenter)
    ReactionService.update(
      reaction: Reaction.new(reactable: comment),
      params: { reaction: "🙂" },
      actor: reactor
    )

    poll = @topic.polls.first!
    stance = poll.stances.undecided.find_by!(participant: voter, latest: true)
    stance.choice = poll.poll_option_names.first
    StanceService.create(stance:, actor: voter)

    TopicReader.for(user: observer, topic: @topic).viewed!
    @topic.add_admin!(commenter, @user)

    TopicService.move(topic: @topic, params: { make_direct: true }, actor: mover)

    participant_ids = [@user.id, mover.id, voter.id, commenter.id, reactor.id]
    active_readers = @topic.topic_readers.active

    assert_nil @topic.reload.group_id
    assert @topic.private
    assert_equal participant_ids.sort, active_readers.pluck(:user_id).sort
    assert_equal participant_ids.sort, active_readers.guests.pluck(:user_id).sort
    assert_equal [@user.id, mover.id].sort, active_readers.admins.pluck(:user_id).sort
    assert_not_nil @topic.topic_readers.find_by!(user: observer).revoked_at
    assert TopicQuery.visible_to(user: commenter, topic_id: @topic.id).exists?
    assert_not TopicQuery.visible_to(user: observer, topic_id: @topic.id).exists?
  end

  test "move does not convert a thread containing an anonymous poll to direct" do
    @topic.update!(allow_concurrent_polls: true)
    PollService.create(params: {
      title: "Anonymous poll",
      poll_type: "proposal",
      topic_id: @topic.id,
      anonymous: true,
      poll_option_names: %w[Agree Disagree],
      closing_at: 1.day.from_now
    }, actor: users(:admin))
    group_id = @topic.group_id
    reader_attributes = @topic.topic_readers.order(:id).pluck(:id, :guest, :admin, :revoked_at)

    error = assert_raises ActiveRecord::RecordInvalid do
      TopicService.move(topic: @topic, params: { make_direct: true }, actor: users(:admin))
    end

    assert_includes error.record.errors[:base], I18n.t("errors.direct_thread_anonymous_poll")
    assert_equal group_id, @topic.reload.group_id
    assert_equal reader_attributes, @topic.topic_readers.order(:id).pluck(:id, :guest, :admin, :revoked_at)
  end

  test "move does not treat an unknown destination group as direct" do
    group_id = @topic.group_id

    assert_raises ActiveRecord::RecordNotFound do
      TopicService.move(topic: @topic, params: { group_id: -1 }, actor: users(:admin))
    end

    assert_equal group_id, @topic.reload.group_id
  end

  test "move does not let a non-admin convert a group discussion to direct" do
    assert_raises CanCan::AccessDenied do
      TopicService.move(topic: @topic, params: { make_direct: true }, actor: users(:member))
    end

    assert_equal @group.id, @topic.reload.group_id
  end

  # -- Close / Reopen --

  test "locks a topic" do
    discussion = DiscussionService.create(params: {
      title: 'Lockable Discussion',
      group_id: @group.id
    }, actor: @user)

    assert_nil discussion.topic.locked_at
    TopicService.lock(topic: discussion.topic, actor: @user)
    assert_not_nil discussion.topic.reload.locked_at
  end

  test "unlocks a locked topic" do
    discussion = DiscussionService.create(params: {
      title: 'Unlockable Discussion',
      group_id: @group.id
    }, actor: @user)
    discussion.topic.update!(locked_at: 1.day.ago)

    TopicService.unlock(topic: discussion.topic, actor: @user)
    assert_nil discussion.topic.reload.locked_at
  end

  # -- Mark as read --

  test "mark_as_read_simple_params ignores a topic the actor can no longer view" do
    @topic.update!(discarded_at: Time.current)

    assert_nothing_raised do
      TopicService.mark_as_read_simple_params(@discussion.id, @discussion_event.sequence_id, @user.id)
    end
  end

  test "mark_as_read rejects a topic the actor cannot view" do
    @topic.update!(discarded_at: Time.current)

    assert_raises CanCan::AccessDenied do
      TopicService.mark_as_read(
        topic: @topic,
        params: {ranges: @discussion_event.sequence_id},
        actor: @user
      )
    end
  end
end

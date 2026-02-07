require 'test_helper'

class RecordClonerTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @actor = users(:another_user)

    # Reset invitation throttle from accumulated test runs
    CACHE_REDIS_POOL.with do |r|
      r.del("THROTTLE-DAY-UserInviterInvitations-#{@user.id}")
      r.del("THROTTLE-HOUR-UserInviterInvitations-#{@user.id}")
    end

    # Use a fresh group to avoid fixture discussions without created_events
    @group = Group.new(
      name: "Cloner Test Group",
      handle: "cloner-test-#{SecureRandom.hex(4)}",
      description: "Group for record cloner testing",
      members_can_add_members: true,
      members_can_edit_discussions: true,
      members_can_edit_comments: true,
      members_can_raise_motions: true,
      members_can_vote: true,
      members_can_start_discussions: true,
      members_can_create_subgroups: true,
      subscription: Subscription.create!(plan: 'trial')
    )
    @group.group_privacy = 'secret'
    @group.save!
    @group.add_admin!(@user)

    @discussion = create_discussion(group: @group, author: @user)

    # Create a comment in the discussion
    comment = Comment.new(body: "Test comment", discussion: @discussion, author: @user)
    CommentService.create(comment: comment, actor: @user)

    # Create poll with stance and outcome
    @poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      poll_option_names: ['Agree', 'Disagree'],
      discussion: @discussion
    )
    PollService.create(poll: @poll, actor: @user)
    @poll.reload

    # Cast a stance - use only choice= setter (not stance_choices.build)
    # to avoid exceeding dots_per_person limit on proposal polls
    stance = @poll.stances.find_by(participant_id: @user.id, latest: true)
    if stance
      stance.choice = 'Agree'
      stance.reason = "good idea"
      StanceService.create(stance: stance, actor: @user)
    end

    # Close poll and create outcome
    PollService.close(poll: @poll, actor: @user)
    @outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "We agreed"
    )
    OutcomeService.create(outcome: @outcome, actor: @user)

    # Repair event chain for discussion
    EventService.repair_discussion(@discussion.id)
  end

  # -- Clone Group --

  test "clones a group with all fields" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).create_clone_group_for_actor(@group, @actor)

    # Check key settings are copied
    %w[
      name
      description
      members_can_add_members
      members_can_edit_discussions
      members_can_edit_comments
      members_can_raise_motions
      members_can_vote
      members_can_start_discussions
      members_can_create_subgroups
    ].each do |field|
      assert_equal @group.send(field), clone.send(field), "#{field} should be copied"
    end

    assert clone.id.present?
    assert_nil clone.handle  # Handle is reset
    assert_equal @actor.id, clone.creator_id
    assert_equal false, clone.is_visible_to_public
    assert_equal 'private_only', clone.discussion_privacy_options
    assert_equal 'approval', clone.membership_granted_upon

    # Check discussions and polls are cloned
    assert_equal @group.discussions.kept.count, clone.discussions.count
    assert clone.discussions.count >= 1
    assert clone.polls.count >= 1
  end

  # -- Clone Discussion --

  test "clones a discussion with events and comments" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).new_clone_discussion_and_events(@discussion)
    clone.save!
    clone.reload

    assert_equal @discussion.title, clone.title
    assert_equal @discussion.description, clone.description
    assert_equal @discussion.description_format, clone.description_format
    assert_equal @discussion.comments.count, clone.comments.count
    assert_equal @discussion.polls.count, clone.polls.count

    # Clone drops poll_closed_by_user/poll_expired/poll_reopened events,
    # so items count may differ from original
    drop_kinds = %w[poll_closed_by_user poll_expired poll_reopened]
    expected_items = @discussion.items.reject { |i| drop_kinds.include?(i.kind) }.count
    assert_equal expected_items, clone.items.count
  end

  # -- Clone Poll --

  test "clones a poll with correct attributes" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).new_clone_poll(@poll)
    clone.save!
    clone.reload

    assert_equal @poll.title, clone.title
    assert_equal @poll.details, clone.details
    assert_equal @poll.details_format, clone.details_format
    assert clone.closing_at > @poll.closing_at
    assert clone.created_at > @poll.created_at

    # Check poll options are cloned
    assert_equal @poll.poll_options.count, clone.poll_options.count
    assert_equal @poll.poll_options.first.name, clone.poll_options.first.name
  end

  test "clones poll stances and outcomes" do
    clone = RecordCloner.new(recorded_at: 2.days.ago).new_clone_poll(@poll)
    clone.save!
    clone.reload

    # Check stances are cloned
    assert clone.stances.count >= 1

    # Verify the cast stance was cloned with correct participant
    original_cast_stance = @poll.stances.where.not(cast_at: nil).first
    if original_cast_stance
      clone_cast_stance = clone.stances.find_by(participant_id: original_cast_stance.participant_id)
      assert_not_nil clone_cast_stance, "Cast stance should be cloned with same participant"
    end

    # Check outcomes are cloned
    assert_equal @poll.outcomes.count, clone.outcomes.count
    assert_equal @poll.outcomes.first.statement, clone.outcomes.first.statement
  end
end

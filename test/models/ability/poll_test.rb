require 'test_helper'

class Ability::PollTest < ActiveSupport::TestCase
  def can?(action, subject)
    @ability.can?(action, subject)
  end

  def cannot?(action, subject)
    !@ability.can?(action, subject)
  end

  setup do
    @actor = User.create!(name: "Poll Actor #{SecureRandom.hex(4)}", email: "pollactor_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    @ability = Ability::Base.new(@actor)
  end

  # Poll without group
  test "poll without group as poll admin can vote and manage" do
    other = User.create!(name: "PO #{SecureRandom.hex(4)}", email: "po_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    poll = Poll.create!(poll_type: 'poll', title: "PTest #{SecureRandom.hex(4)}",
                        poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                        author: other, specified_voters_only: true)
    poll.stances.create!(participant_id: @actor.id, admin: true, guest: true, latest: true)
    assert can?(:vote_in, poll)
    assert can?(:add_voters, poll)
    assert can?(:announce, poll)
    assert can?(:add_guests, poll)
  end

  test "poll without group as voter can vote but not manage" do
    other = User.create!(name: "PO #{SecureRandom.hex(4)}", email: "po_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    poll = Poll.create!(poll_type: 'poll', title: "PTest #{SecureRandom.hex(4)}",
                        poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                        author: other, specified_voters_only: true)
    poll.stances.create!(participant_id: @actor.id, admin: false, guest: true, latest: true)
    assert can?(:vote_in, poll)
    assert cannot?(:add_voters, poll)
    assert cannot?(:announce, poll)
    assert cannot?(:add_guests, poll)
  end

  test "poll without group as unrelated cannot do anything" do
    other = User.create!(name: "Other #{SecureRandom.hex(4)}", email: "pother_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    poll = Poll.create!(poll_type: 'poll', title: "PTest #{SecureRandom.hex(4)}",
                        poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                        author: other, specified_voters_only: true)
    assert cannot?(:vote_in, poll)
    assert cannot?(:add_voters, poll)
    assert cannot?(:announce, poll)
    assert cannot?(:add_guests, poll)
  end

  # Poll in group - as group admin
  test "group admin can manage poll" do
    group = Group.create!(name: "PGrp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@actor)
    group.update!(members_can_announce: false, members_can_add_guests: false)
    discussion = create_discussion(group: group, author: @actor)
    poll = Poll.new(poll_type: 'poll', title: "GP #{SecureRandom.hex(4)}",
                    poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                    author: @actor, discussion: discussion, group: group)
    PollService.create(poll: poll, actor: @actor)

    assert can?(:add_voters, poll)
    assert can?(:announce, poll)
    assert can?(:add_guests, poll)
    assert can?(:update, poll)
  end

  test "group admin cannot update closed poll" do
    group = Group.create!(name: "PGrp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@actor)
    discussion = create_discussion(group: group, author: @actor)
    poll = Poll.new(poll_type: 'poll', title: "GP #{SecureRandom.hex(4)}",
                    poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                    author: @actor, discussion: discussion, group: group)
    PollService.create(poll: poll, actor: @actor)
    poll.update!(closed_at: Time.current)
    assert cannot?(:update, poll)
  end

  test "group admin specified_voters_only true cannot vote" do
    group = Group.create!(name: "PGrp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@actor)
    discussion = create_discussion(group: group, author: @actor)
    poll = Poll.new(poll_type: 'poll', title: "GP #{SecureRandom.hex(4)}",
                    poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                    author: @actor, discussion: discussion, group: group,
                    specified_voters_only: true)
    PollService.create(poll: poll, actor: @actor)
    assert cannot?(:vote_in, poll)
  end

  test "group admin specified_voters_only false can vote" do
    group = Group.create!(name: "PGrp #{SecureRandom.hex(4)}", group_privacy: 'secret')
    group.add_admin!(@actor)
    discussion = create_discussion(group: group, author: @actor)
    poll = Poll.new(poll_type: 'poll', title: "GP #{SecureRandom.hex(4)}",
                    poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                    author: @actor, discussion: discussion, group: group,
                    specified_voters_only: false)
    PollService.create(poll: poll, actor: @actor)
    assert can?(:vote_in, poll)
  end

  # Poll in group - as group member, poll admin
  # Use specified_voters_only: true to avoid auto-stance creation, then manually set stance
  test "group member poll admin with members_can_add_guests true" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: true, specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, admin: true, latest: true)
    assert can?(:add_guests, poll)
  end

  test "group member poll admin with members_can_add_guests false" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: false, specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, admin: true, latest: true)
    assert cannot?(:add_guests, poll)
  end

  test "group member poll admin with members_can_announce true" do
    group, discussion, poll = create_group_discussion_poll(members_can_announce: true, specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, admin: true, latest: true)
    assert can?(:announce, poll)
  end

  test "group member poll admin with members_can_announce false" do
    group, discussion, poll = create_group_discussion_poll(members_can_announce: false, specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, admin: true, latest: true)
    assert cannot?(:announce, poll)
  end

  # Poll in group - as group member, poll member
  test "group member poll member specified_voters_only true can vote" do
    group, discussion, poll = create_group_discussion_poll(specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, inviter_id: @actor.id, latest: true)
    assert can?(:vote_in, poll)
  end

  test "group member poll member specified_voters_only true cannot add guests even if allowed" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: true, specified_voters_only: true)
    group.add_member!(@actor)
    poll.stances.create!(participant_id: @actor.id, inviter_id: @actor.id, latest: true)
    assert cannot?(:add_guests, poll)
  end

  test "group member poll member specified_voters_only false can vote" do
    group, discussion, poll = create_group_discussion_poll
    group.add_member!(@actor)
    # add_member auto-creates a stance for non-specified_voters_only polls
    # update it to set inviter_id to make actor a "poll member"
    stance = poll.stances.find_by(participant_id: @actor.id)
    stance.update!(inviter_id: @actor.id) if stance
    poll.update!(specified_voters_only: false)
    assert can?(:vote_in, poll)
  end

  test "group member poll member specified_voters_only false cannot add guests even if allowed" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: true)
    group.add_member!(@actor)
    stance = poll.stances.find_by(participant_id: @actor.id)
    stance.update!(inviter_id: @actor.id) if stance
    poll.update!(specified_voters_only: false)
    assert cannot?(:add_guests, poll)
  end

  # Poll in group - group member, not poll member
  test "group member not poll member specified_voters_only true cannot vote" do
    group, discussion, poll = create_group_discussion_poll(specified_voters_only: true)
    group.add_member!(@actor)
    # specified_voters_only: true means no auto-stance
    assert cannot?(:vote_in, poll)
  end

  test "group member not poll member specified_voters_only true cannot add guests even if allowed" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: true, specified_voters_only: true)
    group.add_member!(@actor)
    assert cannot?(:add_guests, poll)
  end

  test "group member not poll member specified_voters_only false can vote" do
    group, discussion, poll = create_group_discussion_poll
    group.add_member!(@actor)
    poll.update!(specified_voters_only: false)
    assert can?(:vote_in, poll)
  end

  test "group member not poll member specified_voters_only false cannot add guests even if allowed" do
    group, discussion, poll = create_group_discussion_poll(members_can_add_guests: true)
    group.add_member!(@actor)
    poll.update!(specified_voters_only: false)
    assert cannot?(:add_guests, poll)
  end

  # Discussion guest
  test "discussion guest is not a group member" do
    group, discussion, poll = create_group_discussion_poll
    discussion.add_guest!(@actor, discussion.author)
    assert_not group.members.exists?(@actor.id)
  end

  test "discussion guest is a discussion member" do
    group, discussion, poll = create_group_discussion_poll
    discussion.add_guest!(@actor, discussion.author)
    assert discussion.members.exists?(@actor.id)
  end

  test "discussion guest is a discussion guest" do
    group, discussion, poll = create_group_discussion_poll
    discussion.add_guest!(@actor, discussion.author)
    assert discussion.guests.exists?(@actor.id)
  end

  test "discussion guest can create poll when members_can_raise_motions" do
    group, discussion, poll = create_group_discussion_poll(members_can_raise_motions: true)
    discussion.add_guest!(@actor, discussion.author)
    assert can?(:create, poll)
  end

  test "discussion guest cannot create poll when members_cannot_raise_motions" do
    group, discussion, poll = create_group_discussion_poll(members_can_raise_motions: false)
    discussion.add_guest!(@actor, discussion.author)
    assert cannot?(:create, poll)
  end

  test "discussion guest can announce own poll when members_can_announce and specified_voters_only" do
    group, discussion, _poll = create_group_discussion_poll(members_can_announce: true)
    discussion.add_guest!(@actor, discussion.author)
    guest_poll = Poll.new(poll_type: 'poll', title: "Guest Poll #{SecureRandom.hex(4)}",
                          poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                          author: @actor, discussion: discussion, group: group,
                          specified_voters_only: true)
    PollService.create(poll: guest_poll, actor: @actor)
    assert can?(:announce, guest_poll)
  end

  test "discussion guest cannot announce other poll when specified_voters_only" do
    group, discussion, poll = create_group_discussion_poll(members_can_announce: true)
    discussion.add_guest!(@actor, discussion.author)
    poll.update!(specified_voters_only: true)
    assert cannot?(:announce, poll)
  end

  test "discussion guest can announce own poll when anyone can vote" do
    group, discussion, _poll = create_group_discussion_poll(members_can_announce: true)
    discussion.add_guest!(@actor, discussion.author)
    guest_poll = Poll.new(poll_type: 'poll', title: "Guest Poll #{SecureRandom.hex(4)}",
                          poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                          author: @actor, discussion: discussion, group: group,
                          specified_voters_only: false)
    PollService.create(poll: guest_poll, actor: @actor)
    assert can?(:announce, guest_poll)
  end

  test "discussion guest cannot announce when members_cannot_announce" do
    group, discussion, poll = create_group_discussion_poll(members_can_announce: false)
    discussion.add_guest!(@actor, discussion.author)
    guest_poll = Poll.new(poll_type: 'poll', title: "Guest Poll #{SecureRandom.hex(4)}",
                          poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                          author: @actor, discussion: discussion, group: group)
    PollService.create(poll: guest_poll, actor: @actor)
    assert cannot?(:announce, poll)
    assert cannot?(:announce, guest_poll)
  end

  # Unrelated to group
  test "unrelated user cannot do anything with group poll" do
    group, discussion, poll = create_group_discussion_poll(
      members_can_add_guests: true, members_can_announce: true
    )
    poll.update!(specified_voters_only: false)
    assert cannot?(:vote_in, poll)
    assert cannot?(:announce, poll)
    assert cannot?(:add_guests, poll)
    assert cannot?(:update, poll)
    assert cannot?(:destroy, poll)
    assert cannot?(:close, poll)
    assert cannot?(:reopen, poll)
    assert cannot?(:show, poll)
  end

  private

  def create_group_discussion_poll(specified_voters_only: false, **group_options)
    author = User.create!(name: "PA #{SecureRandom.hex(4)}", email: "pa_#{SecureRandom.hex(4)}@test.com", email_verified: true)
    group = Group.create!({ name: "PG #{SecureRandom.hex(4)}", group_privacy: 'secret' }.merge(group_options))
    group.add_admin!(author)
    discussion = create_discussion(group: group, author: author)
    poll = Poll.new(poll_type: 'poll', title: "P #{SecureRandom.hex(4)}",
                    poll_option_names: %w[Yes No], closing_at: 1.day.from_now,
                    author: author, discussion: discussion, group: group,
                    specified_voters_only: specified_voters_only)
    PollService.create(poll: poll, actor: author)
    [group, discussion, poll]
  end
end

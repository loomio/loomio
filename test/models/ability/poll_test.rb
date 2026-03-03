require 'test_helper'

class Ability::PollTest < ActiveSupport::TestCase
  # Poll without group
  test "poll without group as topic admin can vote and manage" do
    user = users(:user)
    poll = PollService.create(params: poll_params, actor: user)
    assert user.can?(:add_voters, poll)
    assert user.can?(:announce, poll)
    assert user.can?(:add_guests, poll.topic)
    assert user.can?(:vote_in, poll)
  end

  test "poll without group as voter can vote but not manage" do
    user = users(:user)
    other = users(:alien)
    poll = PollService.create(params: poll_params(specified_voters_only: true), actor: other)
    poll.stances.create!(participant_id: user.id, inviter: other, latest: true)
    assert user.can?(:vote_in, poll)
    assert_not user.can?(:add_voters, poll)
    assert_not user.can?(:announce, poll)
    assert_not user.can?(:add_guests, poll.topic)
  end

  test "poll without group as unrelated cannot do anything" do
    user = users(:user)
    other = users(:alien)
    poll = PollService.create(params: poll_params(specified_voters_only: true), actor: other)
    assert_not user.can?(:vote_in, poll)
    assert_not user.can?(:add_voters, poll)
    assert_not user.can?(:announce, poll)
    assert_not user.can?(:add_guests, poll.topic)
  end

  # Poll in group - as group admin
  test "group admin can manage poll" do
    user = users(:user)
    admin = users(:admin)
    group = groups(:group)
    group.update_columns(members_can_announce: false, members_can_add_guests: false)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: user)
    assert admin.can?(:add_voters, poll)
    assert admin.can?(:announce, poll)
    assert admin.can?(:add_guests, poll.topic)
    assert admin.can?(:update, poll)

    poll.update!(closed_at: Time.current)
    assert_not admin.can?(:update, poll)
  end

  test "group admin specified_voters_only true cannot vote" do
    admin = users(:admin)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: admin)
    assert_not admin.can?(:vote_in, poll)
  end

  test "group admin specified_voters_only false can vote" do
    admin = users(:admin)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: admin)
    assert admin.can?(:vote_in, poll)
  end

  # Poll in group - as group member, topic admin
  test "group member topic admin with members_can_add_guests true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: true)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    poll.stances.create!(participant_id: user.id, latest: true)
    poll.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert user.can?(:add_guests, poll.topic)
  end

  test "group member topic admin with members_can_add_guests false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: false)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    poll.stances.create!(participant_id: user.id, latest: true)
    poll.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert_not user.can?(:add_guests, poll.topic)
  end

  test "group member topic admin with members_can_announce true" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_announce: true)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    poll.stances.create!(participant_id: user.id, latest: true)
    poll.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert user.can?(:announce, poll)
  end

  test "group member topic admin with members_can_announce false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_announce: false)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    poll.stances.create!(participant_id: user.id, latest: true)
    poll.topic.topic_readers.find_or_create_by!(user: user).update!(admin: true)
    assert_not user.can?(:announce, poll)
  end

  # Poll in group - voting permissions
  test "group member with stance can vote when specified_voters_only" do
    user = users(:user)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    poll.stances.create!(participant_id: user.id, inviter_id: user.id, latest: true)
    assert user.can?(:vote_in, poll)
  end

  test "group member without stance cannot vote when specified_voters_only" do
    user = users(:user)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id, specified_voters_only: true), actor: users(:admin))
    assert_not user.can?(:vote_in, poll)
  end

  test "group member can vote when not specified_voters_only" do
    user = users(:user)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    assert user.can?(:vote_in, poll)
  end

  # Topic add_guests governed by group setting, not poll membership
  test "group member can add guests to topic when members_can_add_guests" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: true)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    assert user.can?(:add_guests, poll.topic)
  end

  test "group member cannot add guests to topic when members_can_add_guests false" do
    user = users(:user)
    group = groups(:group)
    group.update_columns(members_can_add_guests: false)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    assert_not user.can?(:add_guests, poll.topic)
  end

  # Topic guest (not a group member, but guest on the poll's topic)
  test "topic guest is not a group member" do
    guest = users(:alien)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    poll.topic.add_guest!(guest, poll.author)
    assert_not group.members.exists?(guest.id)
  end

  test "topic guest is a topic member" do
    guest = users(:alien)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    poll.topic.add_guest!(guest, poll.author)
    assert poll.topic.members.exists?(guest.id)
  end

  test "topic guest is a topic guest" do
    guest = users(:alien)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    poll.topic.add_guest!(guest, poll.author)
    assert poll.topic.guests.exists?(guest.id)
  end

  test "topic guest can create poll when members_can_raise_motions" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_raise_motions: true)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    poll.topic.add_guest!(guest, poll.author)
    assert guest.can?(:create, poll)
  end

  test "topic guest cannot create poll when members_cannot_raise_motions" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_raise_motions: false)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.add_guest!(guest, discussion.author)
    poll = PollService.build(params: poll_params(topic: discussion.topic), actor: guest)
    assert_not guest.can?(:create, poll)
  end

  test "topic guest can announce own poll when members_can_announce and specified_voters_only" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_announce: true, members_can_raise_motions: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.add_guest!(guest, discussion.author)
    guest_poll = PollService.create(params: poll_params(topic: discussion.topic, specified_voters_only: true), actor: guest)
    assert guest.can?(:announce, guest_poll)
  end

  test "topic guest cannot announce other poll when specified_voters_only" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_announce: true)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    poll.topic.add_guest!(guest, poll.author)
    poll.update!(specified_voters_only: true)
    assert_not guest.can?(:announce, poll)
  end

  test "topic guest can announce own poll when anyone can vote" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_announce: true, members_can_raise_motions: true)
    discussion = DiscussionService.create(params: discussion_params(group_id: group.id), actor: users(:admin))
    discussion.topic.add_guest!(guest, discussion.author)
    guest_poll = PollService.create(params: poll_params(topic: discussion.topic, specified_voters_only: false), actor: guest)
    assert guest.can?(:announce, guest_poll)
  end

  test "topic guest cannot announce when members_cannot_announce" do
    guest = users(:alien)
    group = groups(:group)
    group.update_columns(members_can_announce: false, members_can_raise_motions: true)
    discussion = DiscussionService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    discussion.topic.add_guest!(guest, discussion.author)
    guest_poll = PollService.create(params: poll_params(topic: discussion.topic), actor: guest)
    assert_not guest.can?(:announce, discussion)
    assert_not guest.can?(:announce, guest_poll)
  end

  # Unrelated to group
  test "unrelated user cannot do anything with group poll" do
    unrelated = users(:alien)
    group = groups(:group)
    poll = PollService.create(params: poll_params(group_id: group.id), actor: users(:admin))
    assert_not unrelated.can?(:vote_in, poll)
    assert_not unrelated.can?(:announce, poll)
    assert_not unrelated.can?(:add_guests, poll.topic)
    assert_not unrelated.can?(:update, poll)
    assert_not unrelated.can?(:destroy, poll)
    assert_not unrelated.can?(:close, poll)
    assert_not unrelated.can?(:reopen, poll)
    assert_not unrelated.can?(:show, poll)
  end

  private
  def discussion_params(**overrides)
    {
      title: "Discussion #{SecureRandom.hex(4)}",
    }.merge(overrides)
  end

  def poll_params(**overrides)
    {
      poll_type: 'poll',
      title: "Poll #{SecureRandom.hex(4)}",
      poll_option_names: %w[Yes No],
      closing_at: 1.day.from_now
    }.merge(overrides)
  end
end

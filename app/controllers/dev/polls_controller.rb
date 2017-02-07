class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper

  def test_discussion
    group = create_group_with_members
    discussion = saved fake_discussion(group: group)
    sign_in group.admins.first
    redirect_to discussion_url(discussion)
  end

  def test_poll_in_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group)
    poll = saved fake_poll(discussion: discussion)
    redirect_to poll_url(poll)
  end

  def test_activity_items
    user = fake_user
    group = saved fake_group
    group.add_admin! user
    discussion = saved fake_discussion(group: group)

    sign_in user
    create_activity_items(discussion: discussion, actor: user)
    redirect_to discussion_url(discussion)
  end

  def test_new_poll_email
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    PollService.create(poll: fake_poll(discussion: discussion, make_announcement: true), actor: actor)
    last_email
  end

  # TODO: make this not broken
  # def test_poll_edited_email
  #   discussion = fake_discussion(group: create_group_with_members)
  #   actor      = discussion.group.admins.first
  #   PollService.update(
  #     poll: saved(fake_poll(discussion: discussion)),
  #     params: {make_announcement: true, title: "Some other title"},
  #     actor: actor)
  #   last_email
  # end

  def test_poll_closing_soon_email
    discussion = fake_discussion(group: create_group_with_members)
    non_voter  = saved(fake_user)
    discussion.group.add_member! non_voter
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(make_announcement: true,
                                                     author: actor,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))
    PollService.create(poll: poll, actor: actor)
    PollService.publish_closing_soon
    last_email(to: non_voter.email)
  end

  def test_poll_closing_soon_author_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))
    PollService.publish_closing_soon
    last_email(to: actor.email)
  end

  def test_poll_expired_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               closing_at: 1.day.ago)
    PollService.expire_lapsed_polls
    last_email
  end

  def test_poll_outcome_created_email
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               closed_at: 1.day.ago,
                                               closing_at: 1.day.ago)
    outcome    = fake_outcome(poll: poll, make_announcement: true)
    OutcomeService.create(outcome: outcome, actor: actor)
    last_email
  end

  def test_proposal_created_email
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    PollService.create(poll: fake_poll(discussion: discussion, poll_type: 'proposal', make_announcement: true), actor: actor)
    last_email
  end

  def test_proposal_expired_email
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion, poll_type: 'proposal', closing_at: 1.day.ago)
    PollService.expire_lapsed_polls
    last_email
  end
end

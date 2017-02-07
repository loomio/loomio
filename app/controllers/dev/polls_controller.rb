class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper
  skip_before_filter :cleanup_database

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

  def test_check_in_created_email
    poll_created_scenario(poll_type: 'check_in')
    last_email
  end

  def test_check_in_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'check_in')
    last_email(to: scenario[:non_voter].email)
  end

  def test_check_in_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'check_in')
    last_email(to: scenario[:actor].email)
  end

  def test_check_in_expired_email
    poll_expired_scenario(poll_type: 'check_in')
    last_email
  end

  def test_check_in_outcome_created_email
    poll_outcome_created_scenario(poll_type: 'check_in')
    last_email
  end

  def test_proposal_created_email
    poll_created_scenario(poll_type: 'proposal')
    last_email
  end

  def test_proposal_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'proposal')
    last_email(to: scenario[:non_voter].email)
  end

  def test_proposal_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'proposal')
    last_email(to: scenario[:actor].email)
  end

  def test_proposal_expired_email
    poll_expired_scenario(poll_type: 'proposal')
    last_email
  end

  def test_proposal_outcome_created_email
    poll_outcome_created_scenario(poll_type: 'proposal')
    last_email
  end

  def test_poll_created_email
    poll_created_scenario(poll_type: 'poll')
    last_email
  end

  def test_poll_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'poll')
    last_email(to: scenario[:non_voter].email)
  end

  def test_poll_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'poll')
    last_email(to: scenario[:actor].email)
  end

  def test_poll_expired_email
    poll_expired_scenario(poll_type: 'poll')
    last_email
  end

  def test_poll_outcome_created_email
    poll_outcome_created_scenario(poll_type: 'poll')
    last_email
  end


  # def test_proposal_created_email
  #   discussion = fake_discussion(group: create_group_with_members)
  #   actor = discussion.group.admins.first
  #   PollService.create(poll: fake_poll(discussion: discussion, poll_type: 'proposal', make_announcement: true), actor: actor)
  #   last_email
  # end
  #
  # def test_proposal_expired_email
  #   discussion = fake_discussion(group: create_group_with_members)
  #   actor      = discussion.group.admins.first
  #   poll       = create_fake_poll_with_stances(discussion: discussion, poll_type: 'proposal')
  #   poll.update_attribute(:closing_at, 1.day.ago)
  #   PollService.expire_lapsed_polls
  #   last_email
  # end
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
end

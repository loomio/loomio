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
    scenario = poll_created_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_check_in_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_check_in_closing_soon_with_vote_email
    scenario = poll_closing_soon_with_vote_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_check_in_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_check_in_expired_email
    scenario = poll_expired_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_check_in_outcome_created_email
    scenario = poll_outcome_created_scenario(poll_type: 'check_in')
    view_last_email_for(scenario[:observer])
  end

  def test_proposal_created_email
    scenario = poll_created_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end

  def test_proposal_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end

  def test_proposal_closing_soon_with_vote_email
    scenario = poll_closing_soon_with_vote_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end


  def test_proposal_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end

  def test_proposal_expired_email
    scenario = poll_expired_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end

  def test_proposal_missed_yesterday_email
    scenario = poll_missed_yesterday_scenario(poll_type: 'proposal')
    UserMailer.missed_yesterday(scenario[:recipient]).deliver_now
    last_email
  end

  def test_proposal_outcome_created_email
    scenario = poll_outcome_created_scenario(poll_type: 'proposal')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_created_email
    scenario = poll_created_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_closing_soon_email
    scenario = poll_closing_soon_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_closing_soon_with_vote_email
    scenario = poll_closing_soon_with_vote_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_closing_soon_author_email
    scenario = poll_closing_soon_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:actor])
  end

  def test_poll_expired_email
    scenario = poll_expired_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_outcome_created_email
    poll_outcome_created_scenario(poll_type: 'poll')
    view_last_email_for(scenario[:observer])
  end

  def test_poll_missed_yesterday_email
    scenario = poll_missed_yesterday_scenario(poll_type: 'poll')
    UserMailer.missed_yesterday(scenario[:recipient]).deliver_now
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
end

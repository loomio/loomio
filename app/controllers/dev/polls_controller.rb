class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper

  def test_activity_items
    user = fake_user
    group = saved fake_group
    group.add_admin! user
    discussion = saved fake_discussion(group: group)

    sign_in user
    create_activity_items(discussion: discussion, actor: user)
    redirect_to discussion_url(discussion)
  end

  def test_poll_created_email
    poll = saved fake_poll
    render_poll_email(poll, 'poll_created')
  end

  # def test_poll_updated_email
  #   poll = fake_poll
  #   create_stances(poll: poll)
  #   poll.save!
  #   render_poll_email(poll, 'poll_updated')
  # end

  def test_poll_closing_soon_email
    poll = create_fake_poll_with_stances
    render_poll_email(poll, 'poll_closing_soon')
  end

  def test_poll_closing_soon_yours_email
    poll = create_fake_poll_with_stances
    render_poll_email(poll, 'poll_closing_soon_yours')
  end

  def test_poll_expired_email
    poll = create_fake_poll_with_stances(closed_at: 1.day.ago,
                                         closing_at: 1.day.ago)
    render_poll_email(poll, 'poll_expired')
  end

  def test_poll_outcome_created_email
    poll = create_fake_poll_with_stances(closed_at: 1.day.ago,
                                         closing_at: 1.day.ago)
    outcome = create_outcome(poll: poll)
    render_poll_email(poll, 'outcome_created')
  end

  def test_proposal_created_email
    poll = saved fake_poll(poll_type: 'proposal')
    render_poll_email(poll, 'poll_created')
  end

  def test_proposal_closed_email
    poll = create_fake_poll_with_stances(poll_type: 'proposal')
    render_poll_email(poll, 'poll_closed')
  end
end

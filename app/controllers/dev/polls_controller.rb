class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper
  include Dev::PollsScenarioHelper
  skip_before_filter :cleanup_database

  def test_verify_vote_by_unverified_user
    poll = saved fake_poll
    unverified_user = saved fake_user(email_verified: false)
    poll.guest_group.add_member! unverified_user
    stance = fake_stance(poll: poll, participant: unverified_user)
    StanceService.create(stance: stance, actor: unverified_user)
    last_email
  end

  def test_verify_vote_by_verified_user
    poll = saved fake_poll
    verified_user = saved fake_user(email: 'user@example.com', email_verified: true)
    unverified_user = saved fake_user(email: 'user@example.com', email_verified: false)
    poll.guest_group.add_member! unverified_user
    stance = fake_stance(poll: poll, participant: unverified_user)
    StanceService.create(stance: stance, actor: unverified_user)
    last_email
  end

  def test_discussion
    group = create_group_with_members
    discussion = saved fake_discussion(group: group)
    sign_in group.admins.first
    redirect_to discussion_path(discussion)
  end

  def test_poll_in_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group)
    poll = saved fake_poll(discussion: discussion)
    redirect_to poll_url(poll)
  end

  def start_poll
    sign_in saved fake_user
    redirect_to new_poll_url
  end

  def start_poll_with_received_email
    sign_in saved fake_user
    email = saved(fake_received_email(sender_email: fake_user.user))
    UserMailer.start_decision(received_email: email).deliver_now
    last_email
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

  def self.observe_scenario(scenario_name, email: false, except: [])
    (AppConfig.poll_templates.keys - except).each do |poll_type|
      define_method :"test_#{poll_type}_#{scenario_name}#{'_email' if email}" do
        sign_out :user
        scenario = send(:"#{scenario_name}_scenario", poll_type: poll_type)
        sign_in(scenario[:observer]) if scenario[:observer].is_a?(User)
        if email
          last_email to: scenario[:observer]
        else
          redirect_to poll_url(scenario[:poll], Hash(scenario[:params]))
        end
      end
    end
  end

  observe_scenario :poll_created,                email: true
  observe_scenario :poll_edited,                 email: true
  observe_scenario :poll_closing_soon,           email: true
  observe_scenario :poll_closing_soon_with_vote, email: true
  observe_scenario :poll_closing_soon_author,    email: true
  observe_scenario :poll_expired,                email: true
  observe_scenario :poll_expired_author,         email: true
  observe_scenario :poll_outcome_created,        email: true
  observe_scenario :poll_missed_yesterday,       email: true
  observe_scenario :poll_stance_created,         email: true
  observe_scenario :poll_options_added,          email: true, except: [:check, :proposal]
  observe_scenario :poll_options_added_author,   email: true, except: [:check, :proposal]
  observe_scenario :poll_with_guest
  observe_scenario :poll_with_guest_as_author
  observe_scenario :poll_notifications
  observe_scenario :poll_created_as_visitor
  observe_scenario :poll_created_as_logged_out
  observe_scenario :poll_share
  observe_scenario :poll_closed
end

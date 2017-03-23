class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper
  include Dev::PollsScenarioHelper
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

  def start_poll
    sign_in saved fake_user
    redirect_to new_poll_url
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

  def self.observe_scenario(scenario_name, email: false)
    Poll::TEMPLATES.keys.each do |poll_type|
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
  observe_scenario :poll_outcome_created,        email: true
  observe_scenario :poll_missed_yesterday,       email: true
  observe_scenario :poll_notifications
  observe_scenario :poll_created_as_visitor
  observe_scenario :poll_created_as_logged_out
  observe_scenario :poll_share
  observe_scenario :poll_closed
end

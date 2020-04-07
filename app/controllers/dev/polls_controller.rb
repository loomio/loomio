class Dev::PollsController < Dev::NightwatchController
  include Dev::PollsHelper
  include Dev::PollsScenarioHelper

  def test_invite_to_poll
    admin = saved fake_user
    group = saved fake_group
    group.add_admin! admin

    if params[:guest]
      user = saved fake_unverified_user
    else
      user = saved fake_user
      group.add_member! user
    end

    discussion = fake_discussion(group: group)

    DiscussionService.create(discussion: discussion, actor: admin)

    # select poll type here
    poll = fake_poll(group: group, discussion: discussion, author: admin)
    PollService.create(poll: poll, actor: poll.author)

    PollService.announce(poll: poll, params: {user_ids: [user.id]}, actor: poll.author)
    last_email
  end

  def test_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group, author: group.admins.first)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    redirect_to discussion_path(discussion)
  end

  def test_poll_in_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group, author: group.admins.first)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    poll = saved fake_poll(discussion: discussion)
    stance = saved fake_stance(poll: poll)
    StanceService.create(stance: stance, actor: group.members.last)
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
    DiscussionService.create(discussion: discussion, actor: discussion.author)

    sign_in user
    create_activity_items(discussion: discussion, actor: user)
    redirect_to discussion_url(discussion)
  end

  def self.observe_scenario(scenario_name, email: false, except: [], only:nil)
    poll_types = only || (AppConfig.poll_templates.keys - except.map(&:to_s))
    poll_types.each do |poll_type|
      action_name = :"test_#{poll_type}_#{scenario_name}#{'_email' if email}"
      define_method action_name do
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
  observe_scenario :poll_expired_author,         email: true
  observe_scenario :poll_outcome_created,        email: true
  observe_scenario :poll_catch_up,               email: true
  observe_scenario :poll_stance_created,         email: true
  observe_scenario :poll_options_added_author,   email: true, except: [:count, :proposal]
  observe_scenario :poll_anonymous,              email: true
  observe_scenario :poll_share
  observe_scenario :poll_options_added
  observe_scenario :poll_expired
  observe_scenario :poll_anonymous
  observe_scenario :poll_with_guest
  observe_scenario :poll_with_guest_as_author
  observe_scenario :poll_notifications
  observe_scenario :poll_created_as_visitor
  observe_scenario :poll_created_as_logged_out
  observe_scenario :poll_closed
  observe_scenario :poll_meeting_populated,     only: [:meeting]
  observe_scenario :poll_user_mentioned, email: true
end

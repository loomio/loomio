class DevelopmentController < ApplicationController
  include Development::DashboardHelper
  include Development::NintiesMoviesHelper

  before_filter :cleanup_database, except: [:last_email, :index]
  around_filter :ensure_testing_environment

  def index
    @routes = DevelopmentController.action_methods.select do |action|
      action.starts_with? 'setup'
    end
    render layout: false
  end

  def last_email
    @email = ActionMailer::Base.deliveries.last
    render layout: false
  end

  def setup_dashboard
    sign_in patrick
    starred_proposal_discussion; proposal_discussion; starred_discussion
    recent_discussion; old_discussion; participating_discussion; muted_discussion; muted_group_discussion
    redirect_to dashboard_url
  end

  def setup_inbox
    sign_in patrick
    starred_discussion; recent_discussion group: another_test_group
    old_discussion; muted_discussion
    redirect_to inbox_url
  end

  def setup_new_group
    group = Group.new(name: 'Fresh group')
    StartGroupService.start_group(group)
    group.add_admin! patrick
    sign_in patrick
    redirect_to group_url(group)
  end

  def setup_group
    sign_in patrick
    test_group.add_member! emilio
    redirect_to group_url(test_group)
  end

  def setup_group_with_expired_legacy_trial
    sign_in jennifer
    GroupService.create(group: test_group, actor: patrick)
    test_group.update_attribute(:cohort_id, 3)
    redirect_to group_url(test_group)
  end

  def setup_group_with_expired_legacy_trial_admin
    sign_in patrick
    test_group.add_member! emilio
    test_group.update_attribute(:cohort_id, 3)
    ENV['TRIAL_EXPIRED_GROUP_IDS'] = test_group.id.to_s

    redirect_to group_url(test_group)
  end

  def setup_group_with_many_discussions
    sign_in patrick
    test_group.add_member! emilio
    50.times do
      discussion = FactoryGirl.build(:discussion,
                                     group: test_group,
                                     private: true,
                                     author: emilio)
      DiscussionService.create(discussion: discussion, actor: emilio)
    end
    redirect_to group_url(test_group)
  end

  def setup_group_on_trial_admin
    sign_in patrick
    group_on_trial = Group.new(name: 'Ghostbusters', is_visible_to_public: true)
    GroupService.create(group: group_on_trial, actor: patrick)
    group_on_trial.add_member! jennifer
    redirect_to group_url(group_on_trial)
  end

  def setup_group_on_trial
    sign_in jennifer
    GroupService.create(group: test_group, actor: patrick)
    redirect_to group_url(test_group)
  end

  def setup_group_with_expired_trial
    GroupService.create(group: test_group, actor: patrick)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :expires_at, 1.day.ago
    redirect_to group_url(test_group)
  end

  def setup_group_with_overdue_trial
    GroupService.create(group: test_group, actor: patrick)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :expires_at, 20.days.ago
    redirect_to group_url(test_group)
  end

  def setup_group_on_paid_plan
    GroupService.create(group: test_group, actor: patrick)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :kind, 'paid'
    redirect_to group_url(test_group)
  end

  def setup_public_group_with_public_content
    another_test_group
    public_test_proposal
    sign_in jennifer
    redirect_to discussion_url(public_test_discussion)
  end

  def setup_multiple_discussions
    sign_in patrick
    test_discussion
    public_test_discussion
    redirect_to discussion_url(test_discussion)
  end

  def setup_group_with_multiple_coordinators
    test_group.add_admin! emilio
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_group_for_invitations
    setup_group
    another_test_group
    patricks_contact
  end

  def setup_group_with_pending_invitation
    sign_in patrick
    pending_invitation
    redirect_to group_url(test_group)
  end

  def view_secret_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    redirect_to group_url(test_group)
  end

  def view_closed_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    redirect_to group_url(test_group)
  end

  def view_open_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    redirect_to group_url(test_group)
  end

  def view_open_group_as_visitor
    @test_group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @test_discussion = @test_group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    redirect_to group_url(@test_group)
  end

  def setup_closed_group
    @test_group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    @test_group.add_admin!  patrick
    @test_group.add_member! jennifer
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_closed_group_to_join
    sign_in jennifer
    another_test_group
    public_test_discussion
    private_test_discussion
    test_subgroup
    redirect_to group_url(another_test_group)
  end

  def setup_public_group_to_join_upon_request
    sign_in jennifer
    another_test_group.update(group_privacy: 'open')
    another_test_group.update(membership_granted_upon: 'request')
    public_test_discussion
    redirect_to group_url(another_test_group)
  end

  def setup_group_with_subgroups
    sign_in jennifer
    test_group
    test_subgroup.add_member! jennifer
    another_test_subgroup.add_member! jennifer
    redirect_to group_url(another_test_group)
  end

  def params_membership_granted_upon
    if ['request', 'approval', 'invitation'].include? params[:membership_granted_upon]
      params[:membership_granted_upon]
    else
      'request'
    end
  end

  def setup_discussion
    test_discussion
    sign_in patrick
    redirect_to discussion_url(test_discussion)
  end

  def setup_busy_discussion
    test_discussion
    sign_in patrick
    setup_all_notifications_work
    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal
    sign_in patrick
    test_proposal
    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal_with_votes
    sign_in patrick
    test_vote
    another_test_vote

    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal
    sign_in patrick
    test_proposal
    MotionService.close(test_proposal)
    redirect_to discussion_url(test_discussion)
  end

  def setup_previous_proposal
    sign_in patrick
    test_proposal
    MotionService.close(test_proposal)
    redirect_to previous_proposals_group_url(test_group)
  end

  def setup_proposal_closing_soon
    sign_in patrick
    test_proposal.update_attribute(:closing_at, 6.hours.from_now)
    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal_with_outcome
    sign_in patrick
    MotionService.close(test_proposal)
    MotionService.create_outcome(motion: test_proposal,
                                 params: {outcome: 'Were going hiking tomorrow'},
                                 actor: patrick)
    redirect_to discussion_url(test_discussion)
  end

  def setup_membership_requests
    sign_in patrick
    test_group
    another_test_group
    3.times do
      membership_request_from_logged_out
    end
    membership_request_from_user
    redirect_to group_url(test_group)
  end

  def setup_user_email_settings
    sign_in patrick
    patrick.update_attributes(email_when_proposal_closing_soon: false,
                              email_missed_yesterday:           false,
                              email_when_mentioned:             false,
                              email_on_participation:           false)
    redirect_to dashboard_url
  end

  def setup_all_notifications
    sign_in patrick
    setup_all_notifications_work
    redirect_to discussion_url(test_discussion)
  end

  private

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
    tmp, Rails.env = Rails.env, 'test'
    yield
    Rails.env = tmp
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    Membership.delete_all

    ActionMailer::Base.deliveries = []
  end
end

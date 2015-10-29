class DevelopmentController < ApplicationController
  include Development::DashboardHelper

  around_filter :ensure_testing_environment

  def last_email
    @email = ActionMailer::Base.deliveries.last
    render layout: false
  end

  def discussion_url(discussion)
    "http://localhost:8000/d/#{discussion.key}/"
  end

  def group_url(group)
    "http://localhost:8000/g/#{group.key}/"
  end

  def dashboard_url
    "http://localhost:8000/dashboard"
  end

  def inbox_url
    "http://localhost:8000/inbox"
  end

  def previous_proposal_url(group)
    "http://localhost:8000/g/#{group.key}/previous_proposals"
  end

  def setup_dashboard
    cleanup_database
    sign_in patrick
    starred_proposal_discussion; proposal_discussion; starred_discussion
    recent_discussion; old_discussion; participating_discussion; muted_discussion
    redirect_to dashboard_url
  end

  def setup_inbox
    cleanup_database
    sign_in patrick
    starred_discussion; recent_discussion group: another_test_group
    old_discussion; muted_discussion
    redirect_to inbox_url
  end

  def setup_new_group
    cleanup_database
    group = Group.new(name: 'Fresh group')
    StartGroupService.start_group(group)
    group.add_admin! patrick
    sign_in patrick
    redirect_to group_url(group)
  end

  def setup_group
    cleanup_database
    sign_in patrick
    test_group.add_member! emilio
    redirect_to group_url(test_group)
  end

  def setup_group_with_many_discussions
    cleanup_database
    sign_in patrick
    test_group.add_member! emilio
    50.times do
      DiscussionService.create(discussion: FactoryGirl.build(:discussion, group: test_group, author: emilio), actor: emilio)
    end
    redirect_to group_url(test_group)
  end

  def setup_group_on_trial_admin
    cleanup_database
    sign_in patrick
    GroupService.create(group: test_group, actor: current_user)
    redirect_to group_url(test_group)
  end

  def setup_group_on_trial
    cleanup_database
    sign_in jennifer
    GroupService.create(group: test_group, actor: current_user)
    redirect_to group_url(test_group)
  end

  def setup_group_with_expired_trial
    cleanup_database
    GroupService.create(group: test_group, actor: current_user)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :expires_at, 1.day.ago
    redirect_to group_url(test_group)
  end

  def setup_group_with_overdue_trial
    cleanup_database
    GroupService.create(group: test_group, actor: patrick)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :expires_at, 20.days.ago
    redirect_to group_url(test_group)
  end

  def setup_group_on_paid_plan
    cleanup_database
    GroupService.create(group: test_group, actor: patrick)
    sign_in patrick
    subscription = test_group.subscription
    subscription.update_attribute :kind, 'paid'
    redirect_to group_url(test_group)
  end

  def setup_public_group_with_public_content
    cleanup_database
    another_test_group
    public_test_proposal
    sign_in jennifer
    redirect_to discussion_url(public_test_discussion)
  end

  def setup_multiple_discussions
    cleanup_database
    sign_in patrick
    test_discussion
    public_test_discussion
    redirect_to discussion_url(test_discussion)
  end

  def setup_group_with_multiple_coordinators
    cleanup_database
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
    cleanup_database
    sign_in patrick
    pending_invitation
    redirect_to group_url(test_group)
  end

  def setup_group_to_join
    cleanup_database
    sign_in jennifer
    another_test_group.update_attribute(:membership_granted_upon, params_membership_granted_upon)
    public_test_discussion
    private_test_discussion
    test_subgroup
    redirect_to group_url(another_test_group)
  end

  def setup_group_with_subgroups
    cleanup_database
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
    cleanup_database
    test_discussion
    sign_in patrick
    redirect_to discussion_url(test_discussion)
  end

  def setup_busy_discussion
    cleanup_database
    test_discussion
    sign_in patrick
    setup_all_notifications_work
    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal
    cleanup_database
    sign_in patrick
    test_proposal

    redirect_to discussion_url(test_discussion)
  end

  def setup_proposal_with_votes
    cleanup_database
    sign_in patrick
    test_vote
    another_test_vote

    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal
    cleanup_database
    sign_in patrick
    test_proposal
    MotionService.close(test_proposal)
    redirect_to discussion_url(test_discussion)
  end

  def setup_previous_proposal
    cleanup_database
    sign_in patrick
    test_proposal
    MotionService.close(test_proposal)
    redirect_to previous_proposal_url(test_group)
  end

  def setup_proposal_closing_soon
    cleanup_database
    sign_in patrick
    test_proposal.update_attribute(:closing_at, 6.hours.from_now)
    redirect_to discussion_url(test_discussion)
  end

  def setup_closed_proposal_with_outcome
    cleanup_database
    sign_in patrick
    MotionService.close(test_proposal)
    MotionService.create_outcome(motion: test_proposal,
                                 params: {outcome: 'Were going hiking tomorrow'},
                                 actor: patrick)
    redirect_to discussion_url(test_discussion)
  end

  def setup_membership_requests
    cleanup_database
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
    cleanup_database
    sign_in patrick
    patrick.update_attributes(email_when_proposal_closing_soon: false,
                              email_missed_yesterday:           false,
                              email_when_mentioned:             false,
                              email_on_participation:           false)
    redirect_to dashboard_url
  end

  def setup_all_notifications
    cleanup_database
    sign_in patrick
    setup_all_notifications_work


    redirect_to discussion_url(test_discussion)
  end

  private

  def setup_all_notifications_work
    #'comment_liked'
    comment = Comment.new(discussion: test_discussion, body: 'I\'m rather likeable')
    new_comment_event = CommentService.create(comment: comment, actor: patrick)
    comment_liked_event = CommentService.like(comment: comment, actor: jennifer)

    #'motion_closing_soon'
    motion_created_event = MotionService.create(motion: test_proposal,
                                                actor: jennifer)
    closing_soon_event = Events::MotionClosingSoon.publish!(test_proposal)

    #'motion_outcome_created'
    outcome_event = MotionService.create_outcome(motion: test_proposal,
                                                 params: {outcome: 'Were going hiking tomorrow'},
                                                 actor: jennifer)

    #'comment_replied_to'
    reply_comment = Comment.new(discussion: test_discussion,
                                body: 'I agree with you', parent: comment)
    CommentService.create(comment: reply_comment, actor: jennifer)

    #'user_mentioned'
    comment = Comment.new(discussion: test_discussion, body: 'hey @patrickswayze you look great in that tuxeido')
    CommentService.create(comment: comment, actor: jennifer)

    #'membership_requested',
    membership_request = MembershipRequest.new(name: 'The Ghost', email: 'boooooo@invisible.co', group: test_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: LoggedOutUser.new)

    #'membership_request_approved',
    another_group = Group.new(name: 'Stars of the 90\'s', is_visible_to_public: true)
    GroupService.create(group: another_group, actor: jennifer)
    membership_request = MembershipRequest.new(requestor: patrick, group: another_group)
    event = MembershipRequestService.create(membership_request: membership_request, actor: patrick)
    approval_event = MembershipRequestService.approve(membership_request: membership_request, actor: jennifer)

    #'user_added_to_group',
    #notify patrick that he has been added to jens group
    another_group = Group.new(name: 'Planets of the 80\'s')
    GroupService.create(group: another_group, actor: jennifer)
    MembershipService.add_users_to_group(users: [patrick], group: another_group, inviter: jennifer, message: 'join in')
  end

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
    tmp, Rails.env = Rails.env, 'test'
    yield
    Rails.env = tmp
  end

  def patrick
    @patrick ||= User.create!(name: 'Patrick Swayze',
                              email: 'patrick_swayze@example.com',
                              is_admin: true,
                              username: 'patrickswayze',
                              password: 'gh0stmovie',
                              detected_locale: 'en',
                              angular_ui_enabled: true)
  end

  def patricks_contact
    if patrick.contacts.empty?
      patrick.contacts.create(name: 'Keanu Reeves',
                              email: 'keanu@example.com',
                              source: 'gmail')
    end
  end

  def jennifer
    @jennifer ||= User.create!(name: 'Jennifer Grey',
                               email: 'jennifer_grey@example.com',
                               username: 'jennifergrey',
                               password: 'gh0stmovie',
                               angular_ui_enabled: true)
  end

  def max
    @max ||= User.create!(name: 'Max Von Sydow',
                          email: 'max@example.com',
                          password: 'gh0stmovie',
                          username: 'mingthemerciless',
                          angular_ui_enabled: true)
  end

  def emilio
    @emilio ||= User.create!(name: 'Emilio Estevez',
                            email: 'emilio@loomio.org',
                            password: 'gh0stmovie',
                            angular_ui_enabled: true)
  end

  def test_group
    unless @test_group
      @test_group = Group.create!(name: 'Dirty Dancing Shoes',
                                  membership_granted_upon: 'approval',
                                  is_visible_to_public: true,
                                  is_visible_to_parent_members: false)
      @test_group.add_admin!  patrick
      @test_group.add_member! jennifer
      @test_group.add_member! emilio
    end
    @test_group
  end

  def another_test_group
    unless @another_test_group
      @another_test_group = Group.create!(name: 'Point Break',
                                          visible_to: 'public',
                                          description: 'An FBI agent goes undercover to catch a gang of bank robbers who may be surfers.')
      @another_test_group.add_admin! patrick
      @another_test_group.add_member! max
    end
    @another_test_group
  end

  def test_discussion
    unless @test_discussion
      @test_discussion = Discussion.create(title: 'What star sign are you?', group: test_group, author: jennifer, private: false)
      DiscussionService.create(discussion: @test_discussion, actor: @test_discussion.author)
    end
    @test_discussion
  end

  def public_test_discussion
    unless @another_test_discussion
      @another_test_discussion = Discussion.create!(title: "The name's Johnny Utah!", group: another_test_group, author: patrick, private: false)
    end
    @another_test_discussion
  end

  def private_test_discussion
    unless @another_test_discussion
      @another_test_discussion = Discussion.create!(title: 'But are you crazy enough?', group: another_test_group, author: patrick, private: true)
    end
    @another_test_discussion
  end

  def test_subgroup
    unless @test_subgroup
      @test_subgroup = Group.create!(name: 'Johnny Utah',
                                     parent_id: another_test_group.id,
                                     visible_to: 'public')
      @test_subgroup.add_admin! patrick
    end
    @test_subgroup
  end

  def another_test_subgroup
    unless @another_test_subgroup
      @another_test_subgroup = Group.create!(name: 'Bodhi',
                                             parent_id: another_test_group.id,
                                             visible_to: 'public')
      @another_test_subgroup.add_admin! patrick
    end
    @another_test_subgroup
  end

  def test_proposal
    unless @test_proposal
      @test_proposal = Motion.new(name: 'lets go hiking to the moon and never ever ever come back!',
                                closing_at: 3.days.from_now.beginning_of_hour,
                                discussion: test_discussion)
      MotionService.create(motion: @test_proposal, actor: jennifer)
    end
    @test_proposal
  end

  def public_test_proposal
    unless @public_test_proposal
      @public_test_proposal = Motion.new(name: 'Lets holiday on Earth instead',
                                         closing_at: 3.days.from_now.beginning_of_hour,
                                         discussion: public_test_discussion)
      MotionService.create(motion: @public_test_proposal, actor: patrick)
    end
    @public_test_proposal
  end

  def test_vote
    unless @test_vote
      @test_vote = Vote.new(position: 'yes', motion: test_proposal, statement: 'I agree!')
      VoteService.create(vote: @test_vote, actor: patrick)
    end
    @test_vote
  end

  def another_test_vote
    unless @another_test_vote
      @another_test_vote = Vote.new(position: 'no', motion: test_proposal, statement: 'I disagree!')
      VoteService.create(vote: @another_test_vote, actor: jennifer)
    end
    @another_test_vote
  end

  def membership_request_from_logged_out
    membership_request = MembershipRequest.new(group: test_group,
                                               name: Faker::Name.name,
                                               email: Faker::Internet.email,
                                               introduction: Faker::Hacker.say_something_smart)
    MembershipRequestService.create(membership_request: membership_request)
    membership_request
  end

  def membership_request_from_user
    unless @membership_request_from_user
      @membership_request_from_user = MembershipRequest.new(group: test_group,
                                                            requestor: max,
                                                            introduction: "I'd like to make decisions with y'all")
      MembershipRequestService.create(membership_request: @membership_request_from_user)
    end
    @membership_request_from_user
  end

  def pending_invitation
    unless @pending_invitation
      @pending_invitation = InvitationService.invite_to_group(recipient_emails: ['judd@example.com'],
                                                              message: 'Come and join the group!',
                                                              group: test_group,
                                                              inviter: patrick)
    end
    @pending_invitation
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    ActionMailer::Base.deliveries = []
  end
end

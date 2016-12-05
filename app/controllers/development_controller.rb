class DevelopmentController < ApplicationController
  include Development::DashboardHelper
  include Development::NintiesMoviesHelper
  include PrettyUrlHelper

  before_filter :ensure_testing_environment
  before_filter :cleanup_database, except: [:last_email, :index, :accept_last_invitation]

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

  def accept_last_invitation
    InvitationService.redeem(Invitation.last, max)
    redirect_to(test_group)
  end

  def setup_login
    patrick
    redirect_to new_user_session_url
  end

  def setup_spanish_user
    patrick.update(selected_locale: :es)
    redirect_to explore_path
  end

  def setup_logged_out_group_member
    patrick
    test_group
    redirect_to new_user_session_url
  end

  def setup_logged_out_member_of_multiple_groups
    patrick
    test_group
    another_test_group
    redirect_to new_user_session_url
  end

  def setup_non_angular_login
    patrick.update(angular_ui_enabled: false)
    redirect_to new_user_session_url
  end

  def setup_non_angular_logged_in_user
    patrick.update(angular_ui_enabled: false)
    sign_in patrick
    redirect_to dashboard_url
  end

  def setup_dashboard
    sign_in patrick
    starred_proposal_discussion; proposal_discussion; starred_discussion
    recent_discussion; old_discussion; participating_discussion; muted_discussion; muted_group_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_as_visitor
    patrick
    recent_discussion
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
    GroupService.create(group: group, actor: patrick)
    group.add_admin! patrick
    membership = Membership.find_by(user: patrick, group: group)
    sign_in patrick
    redirect_to group_url(group)
  end

  def setup_group
    sign_in patrick
    test_group.add_member! emilio
    redirect_to group_url(test_group)
  end

  def setup_subgroup
    test_subgroup.add_member! jennifer
    sign_in jennifer
    redirect_to group_url(test_subgroup)
  end

  def setup_experimental_group
    sign_in patrick
    test_group.add_member! emilio
    test_group.update(enable_experiments: true)
    redirect_to group_url(test_group)
  end

  def setup_membership_request_approved_notification
    sign_in max
    membership_request = MembershipRequest.new(user: max, group: test_group)
    MembershipRequestService.approve(membership_request: membership_request, actor: patrick)
    redirect_to group_url(test_group)
  end

  def setup_multiple_groups
    sign_in patrick
    multiple_groups.each do |group|
      GroupService.create(group: group, actor: patrick)
    end
    redirect_to dashboard_url
  end

  def setup_group_with_welcome_modal
    another_group = Group.new(name: 'Another group',
                              discussion_privacy_options: :public_only,
                              is_visible_to_public: true,
                              membership_granted_upon: :request)
    group = Group.new(name: 'Welcomed group')
    GroupService.create(group: another_group, actor: LoggedOutUser.new)
    GroupService.create(group: group, actor: patrick)
    group.add_admin! patrick
    sign_in patrick
    redirect_to group_url(group)
  end

  # to test subdomains in development
  def setup_group_with_subdomain
    sign_in patrick
    test_group.update_attributes(name: 'Ghostbusters', subdomain: 'ghostbusters')
    redirect_to "http://ghostbusters.lvh.me:3000/"
  end

  def setup_group_as_member
    sign_in jennifer
    redirect_to group_url(test_group)
  end

  def setup_group_with_many_discussions
    test_group.add_member! emilio
    40.times do
      discussion = FactoryGirl.build(:discussion,
                                     group: test_group,
                                     private: false,
                                     author: emilio)
      DiscussionService.create(discussion: discussion, actor: emilio)
    end
    redirect_to group_url(test_group, from: 5)
  end

  def setup_discussion_with_many_comments
    test_group.add_member! emilio
    40.times do |i|
      comment = FactoryGirl.build(:comment, discussion: test_discussion, body: "#{i} bottles of beer on the wall")
      CommentService.create(comment: comment, actor: emilio)
    end
    redirect_to discussion_url(test_discussion, from: 5)
  end

  def setup_busy_discussion_with_signed_in_user
    test_group.add_member! emilio
    100.times do |i|
      comment = FactoryGirl.build(:comment, discussion: test_discussion, body: "#{i} bottles of beer on the wall")
      CommentService.create(comment: comment, actor: emilio)
    end
    sign_in patrick
    redirect_to discussion_url(test_discussion)
  end

  def setup_public_group_with_public_content
    another_test_group
    public_test_proposal
    sign_in jennifer
    redirect_to discussion_url(public_test_discussion)
  end

  def setup_restricted_profile
    sign_in patrick
    test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    test_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_profile_with_group_visible_to_members
    sign_in patrick
    test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    test_group.add_admin!(patrick)
    test_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_group_with_empty_draft
    sign_in patrick
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @test_group.add_admin! patrick
    membership = Membership.find_by(user: patrick, group: @test_group)
    test_empty_draft
    redirect_to group_url(test_group)
  end

  def setup_multiple_discussions
    sign_in patrick
    test_discussion
    public_test_discussion
    redirect_to discussion_url(test_discussion)
  end

  def setup_explore_groups
    sign_in patrick
    30.times do |i|
      explore_group = Group.new(name: Faker::Name.name, group_privacy: 'open', is_visible_to_public: true)
      GroupService.create(group: explore_group, actor: patrick)
      explore_group.update_attribute(:memberships_count, i)
    end
    Group.limit(15).update_all(name: 'Footloose')
    redirect_to group_url(Group.last)
  end

  def setup_group_with_multiple_coordinators
    test_group.add_admin! emilio
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_existing_user_invitation
    test_group
    judd
    pending_invitation
    redirect_to last_email_development_index_path
  end

  def setup_new_user_invitation
    test_group
    pending_invitation
    redirect_to last_email_development_index_path
  end

  def setup_used_invitation
    test_group
    emilio
    InvitationService.redeem(pending_invitation, judd)
    redirect_to last_email_development_index_path
  end

  def setup_accepted_membership_request
    membership_request = MembershipRequest.new(name: "Judd Nelson", email: "judd@example.com", group: test_group)
    MembershipRequestService.approve(membership_request: membership_request, actor: patrick)
    redirect_to last_email_development_index_path
  end

  def setup_cancelled_invitation
    test_group
    judd
    InvitationService.cancel(invitation: pending_invitation, actor: patrick)
    redirect_to last_email_development_index_path
  end

  def setup_team_invitation_link
    redirect_to InvitationService.shareable_invitation_for(test_group)
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

  def view_homepage_as_visitor
    patrick
    redirect_to root_url
  end

  def view_open_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Open Dirty Dancing Shoes',
    membership_granted_upon: 'request',
    group_privacy: 'open')
    @test_group.add_admin! jennifer
    @test_discussion = Discussion.create!(title: "I carried a watermelon", private: false, author: patrick, group: @test_group)
    CommentService.create(comment: Comment.new(body: "It was real seedy", discussion: @test_discussion), actor: jennifer)
    redirect_to group_url(test_group)
  end

  def view_closed_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @test_group.add_admin! jennifer
    @test_discussion = Discussion.create!(title: "I carried a watermelon", private: false, author: patrick, group: @test_group)
    redirect_to group_url(test_group)
  end

  def view_secret_group_as_non_member
    sign_in patrick
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    redirect_to group_url(@test_group)
  end

  def view_open_group_as_visitor
    @test_group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @test_group.add_admin! jennifer
    @test_discussion = @test_group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    @test_proposal = @test_discussion.motions.create!(name: 'Let\'s go to the moon!', closed_at: 3.days.ago, closing_at: 3.days.ago, author: jennifer)
    @test_proposal.close!
    redirect_to group_url(@test_group)
  end

  def view_closed_group_as_visitor
    @test_group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                membership_granted_upon: 'approval',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @test_group.add_admin! jennifer
    @test_discussion = @test_group.discussions.create!(title: 'This thread is private', private: true, author: jennifer)
    @public_discussion = @test_group.discussions.create!(title: 'This thread is public', private: false, author: jennifer)
    redirect_to group_url(@test_group)
  end

  def view_secret_group_as_visitor
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @test_group.add_admin! patrick
    redirect_to group_url(@test_group)
  end

  def view_proposal_as_visitor
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @test_group.add_admin! patrick
    @test_discussion = @test_group.discussions.create!(title: 'This thread is private', private: true, author: patrick)
    @test_proposal   = @test_discussion.motions.create(name: 'lets go hiking', author: patrick)
    redirect_to motion_url(@test_proposal)
  end

  def setup_open_group
    @test_group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                group_privacy: 'open')
    @test_group.add_admin!  patrick
    @test_group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @test_group)
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_closed_group
    @test_group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    @test_group.add_admin!  patrick
    @test_group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @test_group)
    sign_in patrick
    redirect_to group_url(test_group)
  end

  def setup_secret_group
    @test_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @test_group.add_admin!  patrick
    @test_group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @test_group)
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
    another_test_group.add_member! jennifer
    test_subgroup.add_member! jennifer
    another_test_subgroup
    redirect_to group_url(another_test_group)
  end

  def visit_group_as_subgroup_member
    sign_in jennifer
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
    redirect_to group_previous_proposals_url(test_group)
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

  def setup_reply_email
    sign_in jennifer
    comment = Comment.new(discussion: test_discussion, body: 'Hello Patrick')
    CommentService.create(comment: comment, actor: jennifer)
    reply = Comment.new(discussion: test_discussion, body: 'Hello Jennifer', parent: comment)
    CommentService.create(comment: reply, actor: patrick)
    redirect_to discussion_url(test_discussion)
  end

  def email_settings_as_logged_in_user
    test_group
    sign_in patrick
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end

  def email_settings_as_restricted_user
    test_group
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end

  def setup_all_notifications
    sign_in patrick
    setup_all_notifications_work
    redirect_to discussion_url(test_discussion)
  end

  private

  def ensure_testing_environment
    raise "Do not call me." if Rails.env.production?
  end

  def cleanup_database
    User.delete_all
    Group.delete_all
    Membership.delete_all

    ActionMailer::Base.deliveries = []
  end
end

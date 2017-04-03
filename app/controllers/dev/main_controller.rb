class Dev::MainController < Dev::BaseController
  include Dev::DashboardHelper
  include Dev::NintiesMoviesHelper
  include PrettyUrlHelper

  before_filter :cleanup_database, except: [:last_email, :index, :accept_last_invitation]

  def index
    @routes = self.class.action_methods.select do |action|
      action.starts_with? 'setup'
    end
    render layout: false
  end

  def accept_last_invitation
    InvitationService.redeem(Invitation.last, max)
    redirect_to(create_group)
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
    create_group
    redirect_to new_user_session_url
  end

  def setup_logged_out_member_of_multiple_groups
    patrick
    create_group
    create_another_group
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
    starred_proposal_discussion
    starred_poll_discussion
    starred_discussion
    poll_discussion
    proposal_discussion
    recent_discussion
    old_discussion
    participating_discussion
    muted_discussion
    muted_group_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_as_visitor
    patrick
    recent_discussion
    redirect_to dashboard_url
  end

  def setup_inbox
    sign_in patrick
    starred_discussion; recent_discussion group: create_another_group
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
    create_group.add_member! emilio
    redirect_to group_url(create_group)
  end

  def setup_subgroup
    create_subgroup.add_member! jennifer
    sign_in jennifer
    redirect_to group_url(create_subgroup)
  end

  def setup_experimental_group
    sign_in patrick
    create_group.add_member! emilio
    create_group.update(enable_experiments: true)
    redirect_to group_url(create_group)
  end

  def setup_membership_request_approved_notification
    sign_in max
    membership_request = MembershipRequest.new(user: max, group: create_group)
    MembershipRequestService.approve(membership_request: membership_request, actor: patrick)
    redirect_to group_url(create_group)
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
    create_group.update_attributes(name: 'Ghostbusters', subdomain: 'ghostbusters')
    redirect_to "http://ghostbusters.lvh.me:3000/"
  end

  def setup_group_as_member
    sign_in jennifer
    redirect_to group_url(create_group)
  end

  def setup_group_with_many_discussions
    create_group.add_member! emilio
    40.times do
      discussion = FactoryGirl.build(:discussion,
                                     group: create_group,
                                     private: false,
                                     author: emilio)
      DiscussionService.create(discussion: discussion, actor: emilio)
    end
    redirect_to group_url(create_group, from: 5)
  end

  def setup_discussion_with_many_comments
    create_group.add_member! emilio
    40.times do |i|
      comment = FactoryGirl.build(:comment, discussion: create_discussion, body: "#{i} bottles of beer on the wall")
      CommentService.create(comment: comment, actor: emilio)
    end
    redirect_to discussion_url(create_discussion, from: 5)
  end

  def setup_busy_discussion_with_signed_in_user
    create_group.add_member! emilio
    100.times do |i|
      comment = FactoryGirl.build(:comment, discussion: create_discussion, body: "#{i} bottles of beer on the wall")
      CommentService.create(comment: comment, actor: emilio)
    end
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end

  def setup_public_group_with_public_content
    create_another_group
    create_public_proposal
    sign_in jennifer
    redirect_to discussion_url(create_public_discussion)
  end

  def setup_restricted_profile
    sign_in patrick
    create_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_profile_with_group_visible_to_members
    sign_in patrick
    create_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_admin!(patrick)
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_group_with_empty_draft
    sign_in patrick
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin! patrick
    membership = Membership.find_by(user: patrick, group: @group)
    create_empty_draft
    redirect_to group_url(create_group)
  end

  def setup_multiple_discussions
    sign_in patrick
    create_discussion
    create_public_discussion
    redirect_to discussion_url(create_discussion)
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
    create_group.add_admin! emilio
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_existing_user_invitation
    create_group
    judd
    pending_invitation
    redirect_to dev_last_email_path
  end

  def setup_new_user_invitation
    create_group
    pending_invitation
    redirect_to dev_last_email_path
  end

  def setup_used_invitation
    create_group
    emilio
    InvitationService.redeem(pending_invitation, judd)
    redirect_to dev_last_email_path
  end

  def setup_accepted_membership_request
    membership_request = MembershipRequest.new(name: "Judd Nelson", email: "judd@example.com", group: create_group)
    MembershipRequestService.approve(membership_request: membership_request, actor: patrick)
    redirect_to dev_last_email_path
  end

  def setup_cancelled_invitation
    create_group
    judd
    InvitationService.cancel(invitation: pending_invitation, actor: patrick)
    redirect_to dev_last_email_path
  end

  def setup_team_invitation_link
    redirect_to InvitationService.shareable_invitation_for(create_group)
  end

  def setup_group_for_invitations
    create_group
    create_another_group
    patricks_contact
  end

  def setup_group_with_pending_invitation
    sign_in patrick
    pending_invitation
    redirect_to group_url(create_group)
  end


  def view_open_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
    membership_granted_upon: 'request',
    group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.create!(title: "I carried a watermelon", private: false, author: patrick, group: @group)
    CommentService.create(comment: Comment.new(body: "It was real seedy", discussion: @discussion), actor: jennifer)
    redirect_to group_url(create_group)
  end

  def view_closed_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_admin! jennifer
    @discussion = Discussion.create!(title: "I carried a watermelon", private: false, author: patrick, group: @group)
    redirect_to group_url(create_group)
  end

  def view_secret_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    redirect_to group_url(@group)
  end

  def view_open_group_as_visitor
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    @proposal = @discussion.motions.create!(name: 'Let\'s go to the moon!', closed_at: 3.days.ago, closing_at: 3.days.ago, author: jennifer)
    @proposal.close!
    redirect_to group_url(@group)
  end

  def view_closed_group_as_visitor
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                membership_granted_upon: 'approval',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'This thread is private', private: true, author: jennifer)
    @public_discussion = @group.discussions.create!(title: 'This thread is public', private: false, author: jennifer)
    redirect_to group_url(@group)
  end

  def view_secret_group_as_visitor
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin! patrick
    redirect_to group_url(@group)
  end

  def view_proposal_as_visitor
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin! patrick
    @discussion = @group.discussions.create!(title: 'This thread is private', private: true, author: patrick)
    @proposal   = @discussion.motions.create(name: 'lets go hiking', author: patrick)
    redirect_to motion_url(@proposal)
  end

  def setup_open_group
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                group_privacy: 'open')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_closed_group
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_secret_group
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_closed_group_to_join
    sign_in jennifer
    create_another_group
    create_public_discussion
    private_create_discussion
    create_subgroup
    redirect_to group_url(create_another_group)
  end

  def setup_public_group_to_join_upon_request
    sign_in jennifer
    create_another_group.update(group_privacy: 'open')
    create_another_group.update(membership_granted_upon: 'request')
    create_public_discussion
    redirect_to group_url(create_another_group)
  end

  def setup_group_with_subgroups
    sign_in jennifer
    create_another_group.add_member! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_url(create_another_group)
  end

  def visit_group_as_subgroup_member
    sign_in jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup.add_member! jennifer
    redirect_to group_url(create_another_group)
  end

  def params_membership_granted_upon
    if ['request', 'approval', 'invitation'].include? params[:membership_granted_upon]
      params[:membership_granted_upon]
    else
      'request'
    end
  end

  def setup_discussion
    create_discussion
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end

  def setup_busy_discussion
    create_discussion
    sign_in patrick
    create_all_notifications
    redirect_to discussion_url(create_discussion)
  end

  def setup_proposal
    sign_in patrick
    create_proposal
    redirect_to discussion_url(create_discussion)
  end

  def setup_proposal_with_votes
    sign_in patrick
    create_vote
    create_another_vote
    create_public_discussion.group.add_member! jennifer

    redirect_to discussion_url(create_public_discussion)
  end

  def setup_closed_proposal
    sign_in patrick
    create_proposal
    MotionService.close(create_proposal)
    redirect_to discussion_url(create_discussion)
  end

  def setup_previous_proposal
    sign_in patrick
    create_proposal
    MotionService.close(create_proposal)
    redirect_to group_previous_proposals_url(create_group)
  end

  def setup_proposal_closing_soon
    sign_in patrick
    create_proposal.update_attribute(:closing_at, 6.hours.from_now)
    redirect_to discussion_url(create_discussion)
  end


  def setup_closed_proposal_with_outcome
    sign_in patrick
    MotionService.close(create_proposal)
    MotionService.create_outcome(motion: create_proposal,
                                 params: {outcome: 'Were going hiking tomorrow'},
                                 actor: patrick)
    redirect_to discussion_url(create_discussion)
  end

  def setup_membership_requests
    sign_in patrick
    create_group
    create_another_group
    3.times do
      membership_request_from_logged_out
    end
    membership_request_from_user
    redirect_to group_url(create_group)
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
    comment = Comment.new(discussion: create_discussion, body: 'Hello Patrick')
    CommentService.create(comment: comment, actor: jennifer)
    reply = Comment.new(discussion: create_discussion, body: 'Hello Jennifer', parent: comment)
    CommentService.create(comment: reply, actor: patrick)
    redirect_to discussion_url(create_discussion)
  end

  def email_settings_as_logged_in_user
    create_group
    sign_in patrick
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end

  def email_settings_as_restricted_user
    create_group
    redirect_to email_preferences_url(unsubscribe_token: patrick.unsubscribe_token)
  end

  def setup_all_notifications
    sign_in patrick
    create_all_notifications
    redirect_to discussion_url(create_discussion)
  end

end

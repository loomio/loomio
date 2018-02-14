class Dev::MainController < Dev::BaseController
  include Dev::DashboardHelper
  include Dev::NintiesMoviesHelper
  include PrettyUrlHelper

  before_action :cleanup_database, except: [:last_email, :use_last_login_token, :index, :accept_last_invitation]

  def index
    @routes = self.class.action_methods.select do |action|
      action.starts_with?('setup') || action.starts_with?('view')
    end
    render layout: false
  end

  def setup_discussion_mailer_new_discussion_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!  patrick
    @group.add_member! jennifer

    @discussion = Discussion.create(title: 'What star sign are you?',
                                     group: @group,
                                     description: "Wow, what a __great__ day.",
                                     author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    last_email
  end

  def setup_discussion_mailer_new_comment_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick).set_volume!(:loud)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "Wow, what a __great__ day.",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @comment = Comment.new(author: jennifer, body: "hello _patrick_.", discussion: @discussion)
    CommentService.create(comment: @comment, actor: jennifer)
    last_email
  end

  def setup_discussion_mailer_user_mentioned_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "hey @patrickswayze wanna dance?",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    last_email
  end

  def setup_discussion_mailer_comment_replied_to_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "Wow, what a __great__ day.",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @comment = Comment.new(body: "hello _patrick.", discussion: @discussion)
    CommentService.create(comment: @comment, actor: jennifer)
    @reply_comment = Comment.new(body: "why, hello there jen", parent: @comment, discussion: @discussion)
    CommentService.create(comment: @reply_comment, actor: patrick)
    last_email
  end

  def setup_accounts_merged_email
    UserMailer.accounts_merged(patrick).deliver_now
    last_email
  end

  def accept_last_invitation
    invitation = Invitation.last
    InvitationService.redeem(invitation, max)
    redirect_to(group_url(invitation.group))
  end

  def setup_login_token
    login_token = FactoryBot.create(:login_token, user: patrick)
    redirect_to(login_token_url(login_token.token))
  end

  def setup_used_login_token
    login_token = FactoryBot.create(:login_token, user: patrick, used: true)
    redirect_to(login_token_url(login_token.token))
  end

  def use_last_login_token
    redirect_to(login_token_url(LoginToken.last.token))
  end

  def setup_login
    patrick
    redirect_to new_user_session_url
  end

  def setup_deactivated_user
    patrick.update(deactivated_at: 1.day.ago)
    redirect_to dashboard_url
  end

  def setup_invitation_to_visitor
    invitation = Invitation.create!(
      intent: :join_group,
      inviter: patrick,
      group: create_group,
      recipient_email: "max@example.com",
      recipient_name: "Max Von Sydow"
    )
    redirect_to invitation_url(invitation.token)
  end

  def setup_invitation_to_user
    invitation = Invitation.create!(
      intent: :join_group,
      inviter: patrick,
      group: create_group,
      recipient_email: jennifer.email,
      recipient_name: jennifer.name
    )
    redirect_to invitation_url(invitation.token)
  end

  def setup_invitation_to_user_with_password
    jennifer.update(password: "gh0stmovie")
    setup_invitation_to_user
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
    pinned_discussion
    poll_discussion
    recent_discussion
    # old_discussion
    muted_discussion
    muted_group_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_with_one_thread
    sign_in patrick
    recent_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_as_visitor
    patrick; jennifer
    recent_discussion
    redirect_to dashboard_url
  end

  def setup_explore_as_visitor
    patrick
    recent_discussion
    redirect_to explore_url
  end

  def setup_inbox
    sign_in patrick
    recent_discussion group: create_another_group
    old_discussion; muted_discussion; pinned_discussion
    redirect_to inbox_url
  end

  def setup_new_group
    group = FormalGroup.new(name: 'Fresh group')
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

  def setup_group_with_pinned_discussion
    sign_in patrick
    create_discussion.update(pinned: true)
    redirect_to group_url(create_discussion.group)
  end

  def setup_group_with_restrictive_settings
    sign_in jennifer
    create_stance
    create_discussion
    create_group.update(
      members_can_add_members:       false,
      members_can_edit_discussions:  false,
      members_can_edit_comments:     false,
      members_can_raise_motions:     false,
      members_can_vote:              false,
      members_can_start_discussions: false,
      members_can_create_subgroups:  false
    )
    redirect_to group_url create_group
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

  # to test subdomains in development
  def setup_group_with_handle
    sign_in patrick
    create_group.update_attributes(name: 'Ghostbusters', handle: 'ghostbusters')
    redirect_to "http://ghostbusters.lvh.me:3000/"
  end

  def setup_group_as_member
    sign_in jennifer
    redirect_to group_url(create_group)
  end

  def setup_public_group_with_public_content
    create_another_group
    sign_in jennifer
    redirect_to discussion_url(create_public_discussion)
  end

  def setup_restricted_profile
    sign_in patrick
    create_group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_profile_with_group_visible_to_members
    sign_in patrick
    create_group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_admin!(patrick)
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_group_with_empty_draft
    sign_in patrick
    @group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
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
      explore_group = FormalGroup.new(name: Faker::Name.name, group_privacy: 'open', is_visible_to_public: true)
      GroupService.create(group: explore_group, actor: patrick)
      explore_group.update_attribute(:memberships_count, i)
    end
    FormalGroup.limit(15).update_all(name: 'Footloose')
    redirect_to group_url(FormalGroup.last)
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
    redirect_to create_group.shareable_invitation
  end

  def setup_group_with_pending_invitation
    sign_in patrick
    pending_invitation
    redirect_to group_url(create_group)
  end

  def view_closed_group_with_shareable_link
    redirect_to invitation_url(create_group.shareable_invitation)
  end

  def view_open_group_as_non_member
    sign_in patrick
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes', membership_granted_upon: 'request', group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: "I carried a watermelon", private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: jennifer)
    CommentService.create(comment: Comment.new(body: "It was real seedy", discussion: @discussion), actor: jennifer)
    redirect_to group_url(create_group)
  end

  def view_closed_group_as_non_member
    sign_in patrick
    @group = FormalGroup.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_admin! jennifer
    @discussion = Discussion.create!(title: "I carried a watermelon", private: false, author: patrick, group: @group)
    redirect_to group_url(create_group)
  end

  def view_secret_group_as_non_member
    patrick.update(is_admin: false)
    sign_in patrick
    @group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    redirect_to group_url(@group)
  end

  def view_open_group_as_visitor
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    redirect_to group_url(@group)
  end

  def view_open_discussion_as_visitor
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes',
                           membership_granted_upon: 'request',
                           group_privacy: 'open')
    @group.add_member! patrick
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    redirect_to discussion_url(@discussion)
  end

  def view_closed_group_as_visitor
    @group = FormalGroup.create!(name: 'Closed Dirty Dancing Shoes',
                                membership_granted_upon: 'approval',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_member! patrick
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'This thread is private', private: true, author: jennifer)
    @public_discussion = @group.discussions.create!(title: 'This thread is public', private: false, author: jennifer)
    redirect_to group_url(@group)
  end

  def view_secret_group_as_visitor
    @group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin! patrick
    redirect_to group_url(@group)
  end

  def setup_open_group
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes',
                                group_privacy: 'open')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_closed_group
    @group = FormalGroup.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_secret_group
    @group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
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

  def setup_open_and_closed_discussions
    create_discussion
    create_closed_discussion
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_discussion_for_jennifer
    sign_in jennifer
    redirect_to discussion_url(create_discussion)
  end

  def setup_unread_discussion
    read = Comment.new(discussion: create_discussion, body: "Here is some read content")
    unread = Comment.new(discussion: create_discussion, body: "Here is some unread content")
    another_unread = Comment.new(discussion: create_discussion, body: "Here is some more unread content")
    sign_in patrick

    CommentService.create(comment: read, actor: patrick)
    CommentService.create(comment: unread, actor: jennifer)
    CommentService.create(comment: another_unread, actor: jennifer)
    redirect_to discussion_url(create_discussion)
  end

  def setup_busy_discussion
    create_discussion
    sign_in patrick
    create_all_notifications
    redirect_to discussion_url(create_discussion)
  end

  def setup_all_activity_items
    create_discussion
    sign_in patrick
    create_all_activity_items
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

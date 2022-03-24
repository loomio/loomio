module Dev::Scenarios::Auth
  def setup_invitation_email_to_visitor
    group = create_group
    params = {recipient_emails: ['newuser@example.com'], recipient_message: 'Hey this is the app I told you about. please accept the inviitation!'}

    GroupService.invite(group:group, params: params, actor: group.creator)

    last_email
  end

  def setup_invite_user_with_alternative_email
    group = create_group
    group.update(group_privacy: 'secret')
    user = User.create(email: 'existing-user@example.com',
                       name: 'existing user',
                       email_verified: true,
                       password: 'veryeasytoguess123')

    GroupService.invite(
      group:group,
      params: {
        recipient_message: "hi, please join our sweet group!",
        recipient_emails: ['newuser@example.com']
      },
      actor: group.creator)

    sign_in user if params[:signed_in]

    last_email
  end

  def setup_invite_user_with_correct_email
    group = create_group
    group.update(group_privacy: 'secret')
    user = User.create(email: 'existing-user@example.com',
                       name: 'existing user',
                       email_verified: true,
                       password: 'veryeasytoguess123')

    params = {recipient_emails: ['existing-user@example.com'], recipient_message: "hi, please join our sweet group!"}

    GroupService.invite(group:group, params: params, actor: group.creator)

    sign_in user if params[:signed_in]

    last_email
  end

  def setup_invitation_email_to_user_with_password
    group = create_group
    another_group = saved fake_group
    user = saved fake_user(password: nil, name: 'fake user')
    another_group.add_member! user
    another_group.add_member! group.creator
    user.reload
    group.creator.reload
    params = {recipient_user_ids: [user.id], recipient_message: "click accept,
    please
    thanks" }

    GroupService.invite(group:group, params: params, actor: group.creator)

    last_email
  end

  def setup_membership_request_email
    group = saved fake_group(is_visible_to_public: true, membership_granted_upon: 'approval')
    admin = saved fake_user
    GroupService.create(group: group, actor: admin)
    user = saved fake_user
    membership_request = ::MembershipRequest.new(requestor: user, group: group, introduction: "Hey, I'm a shady person who just wants to post spam into your group!")

    MembershipRequestService.create(
      membership_request: membership_request,
      actor: user
    )
    
    sign_in admin
    last_email
  end

  def setup_deactivated_user
    patrick.update(deactivated_at: 1.day.ago)
    redirect_to dashboard_url
  end

  def setup_login_token
    login_token = FactoryBot.create(:login_token, user: patrick)
    redirect_to(login_token_url(login_token.token))
  end

  def setup_login_token_email
    login_token = FactoryBot.create(:login_token, user: patrick)
    UserMailer.login(patrick.id, login_token.id).deliver
    redirect_to('/dev/last_email')
  end

  def setup_used_login_token
    login_token = FactoryBot.create(:login_token, user: patrick, used: true)
    redirect_to(login_token_url(login_token.token))
  end

  def setup_explore_as_visitor
    patrick
    recent_discussion
    redirect_to explore_url
  end

  def view_closed_group_with_shareable_link
    redirect_to join_url(create_group)
  end

  def view_open_discussion_as_visitor
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                           membership_granted_upon: 'request',
                           group_privacy: 'open')
    @group.add_member! patrick
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: 'I carried a watermelon', private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    redirect_to discussion_url(@discussion)
  end

  def view_closed_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: "I carried a watermelon", private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    redirect_to group_url(@group)
  end

  def view_secret_group_as_non_member
    patrick.update(is_admin: false)
    sign_in patrick
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    redirect_to group_url(@group)
  end

  def view_closed_group_as_visitor
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                membership_granted_upon: 'approval',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private')
    @group.add_member! patrick
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'This thread is private', private: true, author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @public_discussion = @group.discussions.create!(title: 'This thread is public', private: false, author: jennifer)
    DiscussionService.create(discussion: @public_discussion, actor: @public_discussion.author)
    redirect_to group_url(@group)
  end

  def view_secret_group_as_visitor
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    @group.add_admin! patrick
    redirect_to group_url(@group)
  end
end

module Dev::Scenarios::Auth
  def setup_invitation_to_visitor
    membership = FactoryBot.create(:membership,
      user: FactoryBot.create(:user, name: nil, email_verified: false),
      group: create_group
    )
    redirect_to membership_url(membership)
  end

  def setup_invitation_to_user_with_password
    membership = create_group.membership_for(jennifer)
    membership.update(accepted_at: nil)
    redirect_to membership
  end

  def setup_deactivated_user
    patrick.update(deactivated_at: 1.day.ago)
    redirect_to dashboard_url
  end

  def setup_login_token
    login_token = FactoryBot.create(:login_token, user: patrick)
    redirect_to(login_token_url(login_token.token))
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
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes',
                           membership_granted_upon: 'request',
                           group_privacy: 'open')
    @group.add_member! patrick
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    redirect_to discussion_url(@discussion)
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
end

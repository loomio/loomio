module Dev::Scenarios::Group
  def setup_group_super_admin
    patrick.update(is_admin: true)
    sign_in patrick
    create_group.add_member! emilio
    redirect_to group_url(create_group)
  end
  def setup_group
    sign_in patrick
    create_group.add_member! emilio
    redirect_to group_url(create_group)
  end

  def setup_group_with_discussion
    sign_in patrick
    create_group.add_member! emilio
    create_discussion
    redirect_to group_url(create_group)
  end

  def setup_group_with_handle
    sign_in patrick
    group = create_group
    group.update_attributes(name: 'Ghostbusters', handle: 'ghostbusters')
    redirect_to group_url(group)
  end

  def setup_group_with_pending_invitations
    sign_in patrick
    create_group
    other_invite = FactoryBot.create(:user, name: nil, email: "hidden@test.com")
    my_invite    = FactoryBot.create(:user, name: nil, email: "shown@test.com")
    FactoryBot.create :membership, group: create_group, accepted_at: nil, inviter: jennifer, user: other_invite
    FactoryBot.create :membership, group: create_group, accepted_at: nil, inviter: patrick, user: my_invite
    redirect_to group_url(create_group)
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

  def visit_group_as_subgroup_member
    sign_in jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup.add_member! jennifer
    redirect_to group_url(create_another_group)
  end

  def setup_group_with_subgroups
    sign_in jennifer
    create_another_group.add_member! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_url(create_another_group)
  end

  def setup_group_with_subgroups_as_admin
    sign_in jennifer
    create_another_group.add_admin! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_url(create_subgroup)
  end

  def setup_subgroup_with_parent_member_visibility
    sign_in patrick
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes',
                                group_privacy: 'closed')
    @group.add_admin!  jennifer
    @group.add_member! jennifer
    @group.add_member! patrick
    @subgroup = Group.create!(name: 'Johnny Utah',
                                   parent: @group,
                                   discussion_privacy_options: 'public_or_private',
                                   parent_members_can_see_discussions: true,
                                   group_privacy: 'closed', creator: jennifer)
    discussion = FactoryBot.create :discussion, group: @subgroup, title: "Vaya con dios", private: true, author: jennifer
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    redirect_to group_url(@subgroup)
  end

  def setup_group_with_subgroups_as_admin_landing_in_other_subgroup
    sign_in jennifer
    create_another_group.add_admin! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_url(another_create_subgroup)
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
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes', group_privacy: 'closed')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_secret_group
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes', handle: 'secret-shoes', group_privacy: 'secret')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_saml_group
    @group = Group.create!(name: 'Dirty Dancing Shoes', handle: 'dirty-dancing-shoes', group_privacy: params[:privacy] || 'secret')
    @group.create_subscription(plan: 'pp-pro-annual')
    provider_url = "https://saml_provider.example.com"
    # provider_url = 'https://app.onelogin.com/saml/metadata/c5690a10-4e33-4a57-9389-30dd92996629'
    patrick.update(email: params[:email]) if params[:email]

    SamlProvider.create(group: @group, idp_metadata_url: provider_url)
    @group.add_admin! jennifer

    if params[:member]
      membership = @group.add_admin! patrick
      membership.update(saml_session_expires_at: if params[:expired] then 1.minute.ago else 1.day.from_now end)
    end

    sign_in patrick if params[:sign_in]

    if params[:discussion]
      @discussion = Discussion.new(title: "I carried a watermelon", author: jennifer, group: @group)
      DiscussionService.create(discussion: @discussion, actor: jennifer)
      redirect_to discussion_url(@discussion)
    else
      redirect_to group_url(create_group)
    end
  end

  def setup_saml_secret_group_pending_invitation
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes', handle: 'secret-shoes', group_privacy: 'secret')
    SamlProvider.create(group: @group, idp_metadata_url: "https://saml_provider.example.com")
    @group.add_admin! jennifer
    membership = FactoryBot.create :membership, group: @group, accepted_at: nil, inviter: jennifer, user: patrick
    redirect_to membership
  end

  def setup_group_with_multiple_coordinators
    create_group.add_admin! emilio
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_group_with_no_coordinators
    create_group
    @group.admin_memberships.each{|m| m.update(admin: false)}
    sign_in patrick
    redirect_to group_url(create_group)
  end

  def setup_group_with_restrictive_settings
    sign_in max
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
    create_group.add_member! max
    redirect_to group_url create_group
  end

  def view_open_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Open Dirty Dancing Shoes', membership_granted_upon: 'request', group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: "I carried a watermelon", private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: jennifer)
    CommentService.create(comment: Comment.new(body: "It was real seedy", discussion: @discussion), actor: jennifer)
    redirect_to group_url(create_group)
  end

  def view_open_group_as_visitor
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: 'I carried a watermelon', private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    redirect_to group_url(@group)
  end

  def setup_start_thread_form_from_url
    sign_in patrick
    redirect_to "/d/new/?group_id=#{create_group.id}&title=testing title&type=thread"
  end

  def setup_start_poll_form_from_url
    sign_in patrick
    redirect_to "/p/new/count?group_id=#{create_group.id}&title=testing title"
  end
end

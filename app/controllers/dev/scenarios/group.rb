module Dev::Scenarios::Group
  def setup_group
    sign_in patrick
    create_group.add_member! emilio
    redirect_to group_url(create_group)
  end

  def setup_group_with_handle
    sign_in patrick
    create_group.update_attributes(name: 'Ghostbusters', handle: 'ghostbusters')
    redirect_to "http://ghostbusters.lvh.me:3000/"
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
    @group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
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
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes', membership_granted_upon: 'request', group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: "I carried a watermelon", private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: jennifer)
    CommentService.create(comment: Comment.new(body: "It was real seedy", discussion: @discussion), actor: jennifer)
    redirect_to group_url(create_group)
  end

  def view_open_group_as_visitor
    @group = FormalGroup.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = @group.discussions.create!(title: 'I carried a watermelon', private: false, author: jennifer)
    redirect_to group_url(@group)
  end
end

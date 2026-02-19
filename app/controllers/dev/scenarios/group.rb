module Dev::Scenarios::Group
  def setup_group_super_admin
    patrick.update(is_admin: true)
    sign_in patrick
    create_group.add_member! emilio
    redirect_to group_path(create_group)
  end

  def setup_group
    sign_in patrick
    create_group.add_member! emilio
    redirect_to group_path(create_group)
  end

  def setup_group_with_photos
    sign_in patrick
    group = create_group
    group.cover_photo.attach(io: File.open(Rails.root.join('public', 'brand', 'logo_sky_256h.png')), filename: 'cover.png')
    group.add_member! emilio
    redirect_to group_path(group)
  end

  def setup_group_with_received_email
    sign_in patrick
    create_group.add_member! emilio
    5.times do
      name = Faker::Name.name
      email = ReceivedEmail.create(
        body_html: "<html><body>hello everyone.</body></html>",
        headers: {
          from: "\"#{name}\" <#{Faker::Internet.email(name: name)}>",
          to: create_group.handle + "@#{ENV['REPLY_HOSTNAME']}",
          subject: Faker::TvShows::TheFreshPrinceOfBelAir.quote
        }
      )
    end
    ReceivedEmailService.route_all
    redirect_to group_emails_path(create_group)
  end

  def setup_group_with_max_members
    sign_in patrick
    create_group.subscription.update(max_members: 4)
    redirect_to group_memberships_path(create_group)
  end

  def setup_trial_group_with_received_email
    sign_in patrick
    create_group.subscription.update(plan: 'trial')
    create_group.add_member! emilio
    5.times do
      name = Faker::Name.name
      email = ReceivedEmail.create(
        body_html: "<html><body>hello everyone.</body></html>",
        headers: {
          from: "\"#{name}\" <#{Faker::Internet.email(name: name)}>",
          to: create_group.handle + "@#{ENV['REPLY_HOSTNAME']}",
          subject: Faker::TvShows::TheFreshPrinceOfBelAir.quote
        }
      )
    end
    ReceivedEmailService.route_all
    redirect_to group_emails_path(create_group)
  end

  def setup_user_no_group
    sign_in patrick
    redirect_to dashboard_path
  end

  def setup_group_with_discussion
    sign_in patrick
    create_group.add_member! emilio
    create_discussion
    redirect_to group_path(create_group)
  end

  def setup_group_with_handle
    sign_in patrick
    group = create_group
    group.update(name: 'Ghostbusters', handle: 'ghostbusters')
    redirect_to group_path(group)
  end

  def setup_group_with_pending_invitations
    sign_in patrick
    create_group
    other_invite = User.create!(email: "hidden@test.com", email_verified: true)
    my_invite    = User.create!(email: "shown@test.com", email_verified: true)
    Membership.create!(group: create_group, accepted_at: nil, inviter: jennifer, user: other_invite)
    Membership.create!(group: create_group, accepted_at: nil, inviter: patrick, user: my_invite)
    redirect_to group_path(create_group)
  end

  def visit_group_as_subgroup_member
    sign_in jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup.add_member! jennifer
    redirect_to group_path(create_another_group)
  end

  def setup_group_with_subgroups
    sign_in jennifer
    create_another_group.add_member! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_path(create_another_group)
  end

  def setup_group_with_subgroups_as_admin
    sign_in jennifer
    create_another_group.add_admin! jennifer
    create_subgroup.add_member! jennifer
    create_subgroup.add_member! fake_user name: 'only in subgroup'
    another_create_subgroup
    redirect_to group_path(create_subgroup)
  end

  def setup_subgroup_with_parent_member_visibility
    sign_in patrick
    @group = Group.new(name: 'Closed Dirty Dancing Shoes',
                       group_privacy: 'closed',
                       creator: jennifer)
    GroupService.create(group: @group, actor: jennifer)
    @group.add_admin!  jennifer
    @group.add_member! patrick
    @subgroup = Group.new(name: 'Johnny Utah',
                          parent: @group,
                          discussion_privacy_options: 'public_or_private',
                          parent_members_can_see_discussions: true,
                          group_privacy: 'closed',
                          creator: jennifer)
    GroupService.create(group: @subgroup, actor: jennifer)
    discussion = Discussion.new(group: @subgroup, title: "Vaya con dios", private: true, author: jennifer)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    redirect_to group_path(@subgroup)
  end

  def setup_group_with_subgroups_as_admin_landing_in_other_subgroup
    sign_in jennifer
    create_another_group.add_admin! jennifer
    create_subgroup.add_member! jennifer
    another_create_subgroup
    redirect_to group_path(another_create_subgroup)
  end

  def setup_open_group
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                group_privacy: 'open')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_path(create_group)
  end

  def setup_closed_group
    @group = Group.create!(name: 'Closed Dirty Dancing Shoes', group_privacy: 'closed')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_path(create_group)
  end

  def setup_secret_group
    @group = Group.create!(name: 'Secret Dirty Dancing Shoes', handle: 'secret-shoes', group_privacy: 'secret')
    @group.add_admin!  patrick
    @group.add_member! jennifer
    membership = Membership.find_by(user: patrick, group: @group)
    sign_in patrick
    redirect_to group_path(create_group)
  end

  def setup_group_with_multiple_coordinators
    create_group.add_admin! emilio
    sign_in patrick
    redirect_to group_path(create_group)
  end

  def setup_group_with_no_coordinators
    create_group
    @group.admin_memberships.each{|m| m.update(admin: false)}
    sign_in patrick
    redirect_to group_path(create_group)
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
      members_can_start_discussions: false,
      members_can_create_subgroups:  false
    )
    create_group.add_member! max
    redirect_to group_path create_group
  end

  def view_open_group_as_non_member
    sign_in patrick
    @group = Group.create!(name: 'Open Dirty Dancing Shoes', membership_granted_upon: 'request', group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: "I carried a watermelon", private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: jennifer)
    CommentService.create(comment: Comment.new(body: "It was real seedy", parent: @discussion), actor: jennifer)
    redirect_to group_path(create_group)
  end

  def view_open_group_as_visitor
    @group = Group.create!(name: 'Open Dirty Dancing Shoes',
                                membership_granted_upon: 'request',
                                group_privacy: 'open')
    @group.add_admin! jennifer
    @discussion = Discussion.new(title: 'I carried a watermelon', private: false, author: jennifer, group: @group)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    redirect_to group_path(@group)
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

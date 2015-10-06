class StartGroupService

  def self.start_group(group)
    group.subscription = Subscription.new(kind: 'trial', expires_at: 30.days.from_now.to_date)
    group.is_visible_to_public = false
    group.discussion_privacy_options = 'private_only'
    group.save!

    # do not create example discussion if the group is public discussions only
    create_example_content(group) if group.discussion_privacy_options != 'public_only'
  end

  def self.invite_admin_to_group(group: , name:, email:)
    inviter = find_or_create_helper_bot
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: email,
                                                                recipient_name: name)
    InvitePeopleMailer.delay.to_start_group(invitation, inviter.email)
    invitation
  end

  def self.create_example_content(group)
    example_content = ExampleContent.new
    bot = example_content.helper_bot
    bot_membership = group.add_member! bot
    example_content.introduction_thread(group)
    how_it_works_thread = example_content.how_it_works_thread(group)
    example_content.first_comment(how_it_works_thread)
    first_proposal = example_content.first_proposal(how_it_works_thread)
    example_content.first_vote(first_proposal)
    bot_membership.destroy
  end
end

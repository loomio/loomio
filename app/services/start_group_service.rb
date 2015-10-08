class StartGroupService

  def self.start_group(group)
    group.subscription = Subscription.new_trial
    group.is_visible_to_public = false
    group.discussion_privacy_options = 'private_only'
    group.save!

    # do not create example discussion if the group is public discussions only
    ExampleContent.add_to_group(group) if group.discussion_privacy_options != 'public_only'
  end

  def self.invite_admin_to_group(group: , name:, email:)
    inviter = ExampleContent.new.helper_bot
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: email,
                                                                recipient_name: name)
    InvitePeopleMailer.delay.to_start_group(invitation, inviter.email)
    invitation
  end
end

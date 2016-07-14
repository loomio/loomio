class StartGroupService

  def self.start_group(group)
    group.add_default_content!
  end

  def self.invite_admin_to_group(group: , name:, email:)
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: User.helper_bot,
                                                                recipient_email: email,
                                                                recipient_name: name)

    InvitePeopleMailer.delay(priority: 1).to_start_group(invitation: invitation,
                                                         sender_email: inviter.email,
                                                         locale: I18n.locale)
    invitation
  end
end

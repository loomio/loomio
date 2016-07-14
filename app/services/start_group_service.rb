class StartGroupService

  def self.start_group(group)
    group.update(default_group_cover: DefaultGroupCover.sample, subscription: Subscription.new_trial)
    ExampleContent.new(group).add_to_group!
  end

  def self.invite_admin_to_group(group: , name:, email:)
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: User.helper_bot,
                                                                recipient_email: email,
                                                                recipient_name: name)

    InvitePeopleMailer.delay(priority: 1).to_start_group(invitation: invitation,
                                                         sender_email: User.helper_bot_email,
                                                         locale: I18n.locale)
    invitation
  end
end

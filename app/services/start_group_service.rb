class StartGroupService

  def self.start_group(group)
    group.subscription = Subscription.new_trial
    group.default_group_cover = DefaultGroupCover.sample
    group.save!

    ExampleContent.add_to_group(group)
  end

  def self.invite_admin_to_group(group: , name:, email:)
    inviter = ExampleContent.new.helper_bot
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: email,
                                                                recipient_name: name)
                                                                
    InvitePeopleMailer.delay.to_start_group(invitation: invitation,
                                            sender_email: inviter.email,
                                            locale: I18n.locale)
    invitation
  end
end

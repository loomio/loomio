class InvitePeopleMailerPreview < ActionMailer::Preview
  def to_start_group
    group = FactoryGirl.create(:group)
    inviter = FactoryGirl.create(:user)
    sender = FactoryGirl.create(:user)

    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: group.creator.email,
                                                                recipient_name: group.creator.name)
    InvitePeopleMailer.to_start_group(invitation: invitation,
                                      sender_email: sender.email,
                                      locale: sender.locale)
  end

  def to_join_group
    recipient_email = "heythere@comejoinus.com"
    responder = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)

    invitation = InvitationService.create_invite_to_join_group(
                    recipient_email: recipient_email,
                    inviter: responder,
                    group: group,
                    message: "Pleaseeeeee join us!
                              it will fulfill the prophecy and we'll become captain planet")
    InvitePeopleMailer.to_join_group(invitation: invitation,
                                     locale: responder.locale)
  end
end

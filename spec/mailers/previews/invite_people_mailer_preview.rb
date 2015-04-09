class InvitePeopleMailerPreview < ActionMailer::Preview
  def to_start_group
    group = FactoryGirl.create(:group)
    inviter = FactoryGirl.create(:user)
    sender = FactoryGirl.create(:user)

    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: group.group_request.admin_email,
                                                                recipient_name: group.group_request.admin_name)
    InvitePeopleMailer.to_start_group(invitation, sender)
  end

  def to_join_group
    recipient_email = "heythere@comejoinus.com"
    responder = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)

    invitation = InvitationService.create_invite_to_join_group(
                    recipient_email: recipient_email,
                    inviter: responder,
                    group: group)
    message_body = "Pleaseeeeee join us, it will complete the phophecy and we'll become captain planet"
    InvitePeopleMailer.to_join_group(invitation, responder, message_body)
  end

  #def after_membership_request_approval
    #(invitation, sender_email, message_body)
  #end
end

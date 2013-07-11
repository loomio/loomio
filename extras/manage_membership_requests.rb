class ManageMembershipRequests

  def self.approve!(membership_request, options={})
    responder = options[:approved_by]
    requestor = membership_request.requestor
    membership_request.approve!(responder)
    if membership_request.from_a_visitor?
      invitation = CreateInvitation.after_membership_request_approval(
                        recipient_email: membership_request.email,
                        inviter: responder,
                        group: membership_request.group)
      InvitePeopleMailer.delay.after_membership_request_approval(invitation, responder.email,'')
    else
      group = membership_request.group
      membership = group.add_member! requestor
      Events::UserAddedToGroup.publish!(membership)
    end
  end

  def self.ignore!(membership_request, options={})
    responder = options[:ignored_by]
    membership_request.ignore!(responder)
  end
end

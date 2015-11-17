class MembershipRequestService
  def self.create(membership_request:, actor: nil)
    actor ||= LoggedOutUser.new
    membership_request.requestor = actor if actor.is_logged_in?
    return false unless membership_request.valid?
    actor.ability.authorize!(:create, membership_request)

    membership_request.save!
    Events::MembershipRequested.publish!(membership_request)
  end

  def self.approve(membership_request:, actor: )
    actor.ability.authorize! :approve, membership_request
    requestor = membership_request.requestor
    membership_request.approve!(actor)
    if membership_request.from_a_visitor?
      invitation = InvitationService.create_invite_to_join_group(
                        recipient_email: membership_request.email,
                        inviter: actor,
                        group: membership_request.group)
      InvitePeopleMailer.delay.after_membership_request_approval(invitation, actor.email,'')
    else
      group = membership_request.group
      membership = group.add_member! requestor
      Events::MembershipRequestApproved.publish!(membership, actor)
    end
  end

  def self.ignore(membership_request: , actor: )
    actor.ability.authorize! :ignore, membership_request
    membership_request.ignore!(actor)
  end
end

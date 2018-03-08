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
    membership_request.approve!(actor)
    if membership = membership_request.convert_to_membership!
      Events::MembershipRequestApproved.publish!(membership, actor)
    else
      invitation = Invitation.create!(
        recipient_name:  membership_request.name,
        recipient_email: membership_request.email,
        group:           membership_request.group,
        inviter:         actor,
        intent:          :join_group
      )
      InvitePeopleMailer.delay(priority: 1).after_membership_request_approval(invitation, actor.email,'')
    end
  end

  def self.ignore(membership_request: , actor: )
    actor.ability.authorize! :ignore, membership_request
    membership_request.ignore!(actor)
  end
end

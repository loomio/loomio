class MembershipRequestService
  def self.create(membership_request:, actor:)
    membership_request.requestor = actor
    return false unless membership_request.valid?
    actor.ability.authorize!(:create, membership_request)

    membership_request.save!
    Events::MembershipRequested.publish!(membership_request)
  end

  def self.approve(membership_request:, actor: )
    actor.ability.authorize! :approve, membership_request
    membership_request.approve!(actor)
    Events::MembershipRequestApproved.publish!(membership_request.convert_to_membership!, actor)
  end

  def self.ignore(membership_request: , actor: )
    actor.ability.authorize! :ignore, membership_request
    membership_request.ignore!(actor)
  end
end

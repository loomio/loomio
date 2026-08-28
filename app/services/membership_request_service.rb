class MembershipRequestService
  def self.create(membership_request:, actor:)
    membership_request.requestor = actor
    actor.ability.authorize!(:create, membership_request)
    return membership_request unless membership_request.valid?

    MembershipRequest.transaction do
      membership_request.save!
      NotificationService.create!(
        kind: "membership_requested",
        subject: membership_request,
        actor: actor
      )
    end
    membership_request
  end

  def self.approve(membership_request:, actor:)
    actor.ability.authorize! :approve, membership_request
    MembershipRequest.transaction do
      membership_request.approve!(actor)
      membership = membership_request.convert_to_membership!
      NotificationService.create!(
        kind: "membership_request_approved",
        subject: membership,
        actor: actor
      )
    end
    membership_request
  end

  def self.ignore(membership_request:, actor:)
    actor.ability.authorize! :ignore, membership_request
    membership_request.ignore!(actor)
  end
end

class NetworkMembershipRequestService
  def self.approve(network_membership_request: , actor: )
    actor.ability.authorize! :approve, network_membership_request

    ActiveRecord::Base.transaction do
      network_membership_request.responder = actor
      network_membership_request.network.groups << network_membership_request.group
      network_membership_request.approved = true
      network_membership_request.save!
    end
  end

  def self.decline(network_membership_request: , actor: )
    actor.ability.authorize! :decline, network_membership_request

    network_membership_request.responder = actor
    network_membership_request.approved = false
    network_membership_request.save!
  end
end
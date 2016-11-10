class Events::MembershipRequestApproved < Event
  def self.publish!(membership, approver)
    create(kind: "membership_request_approved",
           user: approver,
           eventable: membership).tap { |e| EventBus.broadcast('membership_request_approved_event', e, membership.user) }
  end
end

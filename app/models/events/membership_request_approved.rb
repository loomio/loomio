class Events::MembershipRequestApproved < Event

  def self.publish!(membership, approver)
    event = create!(kind: "membership_request_approved",
                    user: approver,
                    eventable: membership)
    UserMailer.delay.group_membership_approved(membership.user, membership.group)

    event.notify!(membership.user)
    event
  end

  def membership
    eventable
  end
end

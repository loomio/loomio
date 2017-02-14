class Events::MembershipRequestApproved < Event
  def self.publish!(membership, approver)
    create(kind: "membership_request_approved",
           user: approver,
           eventable: membership).tap { |e| EventBus.broadcast('membership_request_approved_event', e) }
  end

  def notification_recipients
    User.where(id: eventable.user_id)
  end
  alias :email_recipients :notification_recipients

  def mailer
    UserMailer
  end
end

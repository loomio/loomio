class Events::MembershipRequestApproved < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership, approver)
    super membership, user: approver
  end

  private

  def notification_recipients
    User.where(id: eventable&.user_id)
  end
  alias :email_recipients :notification_recipients

  def mailer
    UserMailer
  end
end

class Events::MembershipRequestApproved < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership, approver)
    super membership, user: approver
  end

  private
  def email_users!
    email_recipients.active.uniq.pluck(:id).each do |recipient_id|
      EventMailer.event(recipient_id, self.id).deliver_later
    end
  end

  def notification_recipients
    User.where(id: eventable&.user_id)
  end
  alias :email_recipients :notification_recipients
end

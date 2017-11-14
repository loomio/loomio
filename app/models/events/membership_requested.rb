class Events::MembershipRequested < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership_request)
    super membership_request
  end

  private

  def notification_recipients
    eventable.admins.active
  end

  def email_recipients
    notification_recipients
  end

  def notification_actor
    eventable.requestor
  end

  def notification_translation_values
    { name: eventable.requestor&.name || eventable.name, title: eventable.group.full_name }
  end

  def mailer
    GroupMailer
  end
end

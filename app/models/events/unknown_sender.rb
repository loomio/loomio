class Events::UnknownSender < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(received_email)
    super received_email
  end

  private

  def notification_recipients
    eventable.group.admins.active
  end

  def email_recipients
    # we don't want to be sending email as a result of receiving email from an unknown address
    User.none
  end

  def notification_actor
    nil
  end

  def notification_translation_values
    { name: notification_actor&.name, title: eventable.group.full_name }
  end
end

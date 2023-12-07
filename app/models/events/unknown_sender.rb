class Events::UnknownSender < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(received_email)
    super received_email
  end

  def wait_time
    0.minute
  end

  private

  def notification_recipients
    eventable.group.admins.active
  end

  def email_recipients
    Queries::UsersByVolumeQuery.
      email_notifications(eventable.group).
      where(id: notification_recipients.pluck(:id))
  end

  def notification_actor
    nil
  end

  def notification_translation_values
    { name: notification_actor&.name, title: eventable.group.full_name }
  end
end

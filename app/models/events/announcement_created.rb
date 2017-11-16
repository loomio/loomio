class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::RespondToModel

  def self.publish!(announcement)
    super announcement
  end

  private

  def notification_recipients
    eventable.users_to_notify
  end

  def email_recipients
    eventable.users_to_notify.where(email_announcements: true)
  end

  def mailer
    "#{eventable.announceable.class}Mailer".constantize
  end
end

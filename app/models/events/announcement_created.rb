class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::RespondToModel

  def self.publish!(announcement)
    super announcement
  end

  private

  def notification_recipients
    User.where(id: eventable.user_ids)
  end

  def email_recipients
    notification_recipients.where(email_announcements: true)
  end
end

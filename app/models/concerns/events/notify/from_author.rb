module Events::Notify::FromAuthor
  include Events::Notify::InApp
  include Events::Notify::Users
  include Events::Notify::Email

  def email_recipients
    notification_recipients # TODO filter out people who don't want email
  end

  def notification_recipients
    eventable.notified_users
  end

  def invitation_recipients
    eventable.notified_emails
  end
end

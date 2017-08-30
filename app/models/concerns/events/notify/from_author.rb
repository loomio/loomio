module Events::Notify::FromAuthor
  include Events::Notify::InApp
  include Events::Notify::Users
  include Events::Notify::Email

  def email_recipients
    eventable.notified_users.without(
      Queries::UsersByVolumeQuery.mute_or_quiet(eventable.discussion || eventable.group)
    )
  end

  def notification_recipients
    eventable.notified_users
  end

  def invitation_recipients
    eventable.notified_emails
  end
end

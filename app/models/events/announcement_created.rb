class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::ByInvitation
  include Events::Notify::Author
  include Events::RespondToModel

  private

  def notification_recipients
    User.where(id: eventable.user_ids)
  end

  def email_recipients
    notification_recipients.where(email_announcements: true)
  end

  def invitation_recipients
    eventable.invitations
  end

  def notify_author?
    eventable.announceable.is_a?(Outcome) &&
    eventable.announceable.poll.author_receives_outcome
  end
end

class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::ByInvitation
  include Events::Notify::Author

  def calendar_invite
    eventable.announceable.respond_to?(:calendar_invite) &&
    eventable.announceable.calendar_invite
  end

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

  # send outcome_created to author if announcing an appropriate outcome
  def email_author!
    eventable.send(:mailer).send(:outcome_created_author, author, self).deliver_now if notify_author?
  end

  def notify_author?
    eventable.announceable.is_a?(Outcome) &&
    eventable.announceable.poll.author_receives_outcome
  end
end

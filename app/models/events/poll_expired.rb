class Events::PollExpired < Event
  include Events::Notify::FromAuthor
  include Events::Notify::Author
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    poll.notified = poll.notified_when_created
    super poll,
          discussion: poll.discussion,
          created_at: poll.closed_at
  end

  def notify_users!
    super
    notification_for(eventable.author).save
  end

  private

  # the author is always notified above, so don't notify them twice
  def notification_recipients
    super.without(eventable.author)
  end

  def email_recipients
    super.without(eventable.author)
  end
end

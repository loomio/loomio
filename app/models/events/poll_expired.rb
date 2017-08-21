class Events::PollExpired < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    super poll,
          discussion: poll.discussion,
          announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
          created_at: poll.closed_at
  end

  def notify_users!
    super
    notification_for(poll.author).save
  end

  private

  # the author is always notified above, so don't notify them twice
  def notification_recipients
    super.without(poll.author)
  end

  def email_recipients
    super.without(poll.author)
  end

  # don't notify mentioned users for poll expired
  def specified_notification_recipients
    User.none
  end
  alias :specified_email_recipients :specified_notification_recipients
end

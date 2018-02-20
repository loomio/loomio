class Events::PollExpired < Event
  include Events::PollEvent
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::Notify::InApp

  def self.publish!(poll)
    create(kind: "poll_expired",
           eventable: poll,
           parent: poll.created_event,
           announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_expired_event', e) }
  end

  def notify_users!
    super
    notification_for(poll.author).save
  end

  private

  # the author is always notified above, so don't notify them twice
  def notification_recipients
    super.where.not(id: poll.author)
  end

  def email_recipients
    super.where.not(id: poll.author)
  end

  # don't notify mentioned users for poll expired
  def specified_notification_recipients
    User.none
  end
  alias :specified_email_recipients :specified_notification_recipients
end

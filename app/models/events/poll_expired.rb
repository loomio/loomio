class Events::PollExpired < Event
  include Events::PollEvent

  def self.publish!(poll)
    create(kind: "poll_expired",
           eventable: poll,
           discussion: poll.discussion,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_expired_event', e) }
  end

  private

  # notify only the author that the poll has expired
  def notification_recipients
    User.where(id: eventable.author_id)
  end
  alias :email_recipients :notification_recipients

end

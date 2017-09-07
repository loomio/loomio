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

  private

  # 'super' here are the people who were notified when the poll was first created
  def notification_recipients
    users_who_care(super)
  end

  def email_recipients
    users_who_care(super)
  end

  # we also always notified the author of poll expiry (unless they have unsubscribed)
  def users_who_care(relation)
    users_in_any(relation, User.where(id: eventable.author_id)).without(eventable.unsubscribers)
  end
end

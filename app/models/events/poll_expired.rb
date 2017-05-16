class Events::PollExpired < Event
  include Events::PollEvent

  def self.publish!(poll)
    create(kind: "poll_expired",
           eventable: poll,
           discussion: poll.discussion,
           announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
           created_at: poll.closed_at).tap { |e| EventBus.broadcast('poll_expired_event', e) }
  end

  def email_users!
    super
    mailer.poll_expired_author(poll.author, self).deliver_now
  end

  private

  # this gnarly-looking code simply tacks on the poll author as a notification recipient \o/
  def notification_recipients
    User.from("(#{notification_recipients_sql(super)}) as users").uniq
  end

  def notification_recipients_sql(_super)
    [_super, User.where(id: eventable.author_id)].map(&:to_sql).map(&:presence).compact.join(' UNION ')
  end

  # don't notify mentioned users for poll expired
  def specified_notification_recipients
    User.none
  end
  alias :specified_email_recipients :specified_notification_recipients
end

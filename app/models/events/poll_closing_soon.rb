class Events::PollClosingSoon < Event
  include Events::PollEvent

  def self.publish!(poll)
    create(kind: "poll_closing_soon",
           user: poll.author,
           announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end

  def email_users!
    super
    mailer.poll_closing_soon_author(user, self).deliver_now
  end

  private

  # don't notify mentioned users for poll closing soon
  def specified_notification_recipients
    User.none
  end
  alias :specified_email_recipients :specified_notification_recipients
end

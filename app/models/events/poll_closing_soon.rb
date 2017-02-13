class Events::PollClosingSoon < Event
  include PollNotificationEvent

  def self.publish!(poll, make_announcement = false)
    create(kind: "poll_closing_soon",
           user: poll.author,
           announcement: poll.events.find_by(kind: :poll_created)&.announcement,
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end

  def email_users!
    super
    mailer.poll_closing_soon_author(user, self).deliver_now
  end
end

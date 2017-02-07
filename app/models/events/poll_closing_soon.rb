class Events::PollClosingSoon < Event
  def self.publish!(poll, make_announcement = false)
    create(kind: "poll_closing_soon",
           user: poll.author,
           announcement: make_announcement,
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end

  def users_to_notify
    eventable.watchers.without(eventable.participants)
                      .without(eventable.author)
  end
end

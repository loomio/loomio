class Events::NewPoll < Event
  def self.publish!(poll)
    create(kind: "new_poll",
           user: poll.author,
           eventable: poll,
           announcement: poll.make_announcement,
           discussion: poll.discussion,
           created_at: poll.created_at).tap { |e| EventBus.broadcast('new_poll_event', e) }
  end

  def users_to_notify
    eventable.watchers.without(self.user)
  end
end

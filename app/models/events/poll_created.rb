class Events::PollCreated < Event
  def self.publish!(poll)
    create(kind: "poll_created",
           user: poll.author,
           eventable: poll,
           announcement: poll.make_announcement,
           discussion: poll.discussion,
           created_at: poll.created_at).tap { |e| EventBus.broadcast('poll_created_event', e) }
  end

  def users_to_notify
    eventable.watchers.without(self.user)
  end
end

class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::PollEvent
  include Events::Notify::ThirdParty

  def self.publish!(poll, actor)
    create(kind: "poll_created",
           user: actor,
           eventable: poll,
           parent: poll.parent_event,
           announcement: poll.make_announcement,
           discussion: poll.discussion,
           created_at: poll.created_at).tap { |e| EventBus.broadcast('poll_created_event', e) }
  end
end

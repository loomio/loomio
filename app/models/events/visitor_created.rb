class Events::VisitorCreated < Event
  include Events::VisitorEvent

  def self.publish!(visitor, actor, poll)
    create(kind: "visitor_created",
           user: actor,
           custom_fields: {poll_id: poll.id},
           eventable: visitor).tap { |e| EventBus.broadcast('visitor_created_event', e) }
  end
end

class Events::VisitorReminded < Event
  include Events::VisitorEvent

  def self.publish!(visitor, actor, poll)
    create(kind: "visitor_reminded",
           user: actor,
           custom_fields: {poll_id: poll.id},
           eventable: visitor).tap { |e| EventBus.broadcast('visitor_reminded_event', e) }
  end
end

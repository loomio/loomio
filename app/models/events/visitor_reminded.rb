class Events::VisitorReminded < Event
  include Events::EmailUser

  def self.publish!(visitor, actor, poll)
    create(kind: "visitor_created",
           user: actor,
           custom_fields: {poll_id: poll.id},
           eventable: visitor).tap { |e| EventBus.broadcast('visitor_reminded_event', e) }
  end

  def poll
    @poll ||= Poll.find(custom_fields[:poll_id])
  end

  private

  def email_recipients
    Visitor.where(id: eventable_id)
  end
end

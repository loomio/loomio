class VisitorService
  def self.destroy(visitor:, actor:)
    actor.ability.authorize! :destroy, visitor

    visitor.update(revoked: true)
    EventBus.broadcast('visitor_destroy', visitor, actor)
  end

  def self.remind(visitor:, actor:)
    actor.ability.authorize! :remind, visitor
    reminder_event = Events::PollCreated.find_by(kind: :poll_created, eventable: visitor.poll)

    return false unless reminder_event.present?
    PollMailer.delay.poll_created(visitor, reminder_event)

    EventBus.broadcast('visitor_remind', visitor, actor)
  end
end

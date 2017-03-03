class VisitorService
  def self.destroy(visitor:, actor:)
    actor.ability.authorize! :destroy, visitor

    visitor.update(revoked: true)
    EventBus.broadcast('visitor_destroy', visitor, actor)
  end

  def self.update(visitor:, params:, actor:)
    actor.ability.authorize! :update, visitor

    visitor.update(params.slice(:name, :email))
    EventBus.broadcast('visitor_update', visitor, actor)
  end

  def self.remind(visitor:, actor:, poll:)
    actor.ability.authorize! :remind, poll

    return false unless poll_event = Events::PollCreated.find_by(kind: :poll_created, eventable: poll)
    PollMailer.delay.poll_created(visitor, poll_event)

    EventBus.broadcast('visitor_remind', visitor, actor)
  end
end

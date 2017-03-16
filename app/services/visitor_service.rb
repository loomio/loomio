class VisitorService
  def self.create(visitor:, actor:)
    actor.ability.authorize! :create, visitor

    return false unless visitor.valid?

    visitor = visitor.community.visitors.find_by(email: visitor.email) || visitor
    visitor.update!(revoked: false)

    EventBus.broadcast('visitor_create', visitor, actor)
    Events::VisitorCreated.publish!(visitor, actor)
  end

  def self.update(visitor:, params:, actor:)
    actor.ability.authorize! :update, visitor

    visitor.update(params.slice(:name, :email))
    EventBus.broadcast('visitor_update', visitor, actor)
  end

  def self.remind(visitor:, actor:, poll:)
    actor.ability.authorize! :remind, visitor

    EventBus.broadcast('visitor_remind', visitor, actor, poll)
    Events::VisitorReminded.publish!(visitor, actor, poll)
  end

  def self.destroy(visitor:, actor:)
    actor.ability.authorize! :destroy, visitor

    visitor.update(revoked: true)
    EventBus.broadcast('visitor_destroy', visitor, actor)
  end
end

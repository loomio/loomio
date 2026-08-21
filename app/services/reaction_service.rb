class ReactionService
  def self.update(reaction:, params:, actor:)
    actor.ability.authorize! :update, reaction

    reaction.user = actor
    reaction.assign_attributes(params.slice(:reaction))

    unless reaction.valid?
      Sentry.metrics.count("reaction.create_failed", attributes: { columns: reaction.errors.attribute_names.join(',') })
      return false
    end
    event = Reaction.transaction do
      reaction.save!
      Events::ReactionCreated.publish!(reaction)
    end

    Sentry.metrics.count("reaction.create", attributes: { reaction: reaction.reaction })
    EventBus.broadcast 'reaction_create', reaction, actor
    event
  end

  def self.destroy(reaction:, actor:)
    actor.ability.authorize! :destroy, reaction

    reaction.destroy
    Sentry.metrics.count("reaction.destroy", attributes: { reaction: reaction.reaction })
    EventBus.broadcast 'reaction_destroy', reaction, actor
  end
end

class ReactionService
  def self.update(reaction:, params:, actor:)
    actor.ability.authorize! :update, reaction

    reaction.user = actor
    reaction.assign_attributes(params.slice(:reaction))

    return false unless reaction.valid?
    reaction.save!

    EventBus.broadcast 'reaction_create', reaction, actor
    Events::ReactionCreated.publish!(reaction)
  end

  def self.destroy(reaction:, actor:)
    actor.ability.authorize! :destroy, reaction

    reaction.destroy

    EventBus.broadcast 'reaction_destroy', reaction, actor
  end
end

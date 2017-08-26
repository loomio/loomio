class ReactionService
  def self.create(reaction:, actor:)
    actor.ability.authorize! :create, reaction

    reaction.assign_attributes(user: actor)

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

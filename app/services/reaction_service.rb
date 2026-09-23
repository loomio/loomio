class ReactionService
  def self.update(reaction:, params:, actor:)
    actor.ability.authorize! :update, reaction

    reaction.user = actor
    reaction.assign_attributes(params.slice(:reaction))

    unless reaction.valid?
      Sentry.metrics.count("reaction.create_failed", attributes: { columns: reaction.errors.attribute_names.join(',') })
      return reaction
    end
    Reaction.transaction do
      reaction.save!
      NotificationService.create!(
        kind: "reaction_created",
        subject: reaction,
        actor: actor
      )
    end

    Sentry.metrics.count("reaction.create", attributes: { reaction: reaction.reaction })
    publish_reaction(reaction)
    EventBus.broadcast 'reaction_create', reaction, actor
    reaction
  end

  def self.destroy(reaction:, actor:)
    actor.ability.authorize! :destroy, reaction

    reaction.destroy
    Sentry.metrics.count("reaction.destroy", attributes: { reaction: reaction.reaction })
    EventBus.broadcast 'reaction_destroy', reaction, actor
  end

  # Reactions are records, not timeline items. Publish the changed reaction
  # directly to the same group and guest channels previously reached through a
  # notification-only topic_item.
  def self.publish_reaction(reaction)
    MessageChannelService.publish_models([ reaction ], group_id: reaction.group_id) if reaction.group_id

    topic = reaction.reactable.topic if reaction.reactable.respond_to?(:topic)
    topic&.guests&.find_each do |user|
      MessageChannelService.publish_models([ reaction ], user_id: user.id)
    end
  end
  private_class_method :publish_reaction
end

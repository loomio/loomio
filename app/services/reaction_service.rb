class ReactionService
  NOTIFICATION_UPDATE_WINDOW = 2.minutes

  def self.update(reaction:, params:, actor:)
    actor.ability.authorize! :update, reaction

    reaction.user = actor
    reaction.assign_attributes(params.slice(:reaction))

    unless reaction.valid?
      Sentry.metrics.count("reaction.create_failed", attributes: { columns: reaction.errors.attribute_names.join(',') })
      return reaction
    end
    Reaction.transaction do |transaction|
      reaction.save!
      update_notification(reaction, actor, transaction)
      transaction.after_commit do
        Sentry.metrics.count("reaction.create", attributes: { reaction: reaction.reaction })
        publish_reaction(reaction)
        EventBus.broadcast 'reaction_create', reaction, actor
      end
    end

    reaction
  end

  def self.destroy(reaction:, actor:)
    actor.ability.authorize! :destroy, reaction

    reaction.destroy
    Sentry.metrics.count("reaction.destroy", attributes: { reaction: reaction.reaction })
    EventBus.broadcast 'reaction_destroy', reaction, actor
  end

  # Saving the reaction serializes changes to an existing record. Lock its latest
  # notification too, so delivery routing cannot snapshot an intermediate emoji.
  # Keep the original timestamp and read state, and replace only the emoji in
  # localized snapshots; a later reaction change starts a new notification.
  def self.update_notification(reaction, actor, transaction)
    notification = reaction.notifications
      .where(kind: "reaction_created", actor: actor)
      .where(created_at: NOTIFICATION_UPDATE_WINDOW.ago..)
      .order(created_at: :desc, id: :desc)
      .lock.first

    unless notification
      return NotificationService.create!(kind: "reaction_created", subject: reaction, actor: actor)
    end

    value = reaction.reaction.downcase
    notification.update!(translation_values: notification.translation_values.merge("reaction" => value))
    notification.notification_deliveries.each do |delivery|
      delivery.update!(translation_values: delivery.translation_values.merge("reaction" => value))
    end
    transaction.after_commit { publish_notification(notification) }
    notification
  end
  private_class_method :update_notification

  # Refresh only existing in-app recipients who still have access. External
  # deliveries keep their identity and are not sent again for an emoji change.
  def self.publish_notification(notification)
    notification.reload
    return unless NotificationService.group_enabled?(notification.subject)

    notification.notification_deliveries.delivered
      .where(channel: "in_app", recipient_type: "User")
      .includes(:recipient).each do |delivery|
        user = delivery.recipient
        next unless User.active.exists?(id: user.id) && notification.subject.group.memberships.exists?(user: user)
        next if NotificationQuery.currently_accessible_to(user: user, notifications: [ notification ]).empty?

        MessageChannelService.publish_models([ notification ], user_id: user.id)
      end
  end
  private_class_method :publish_notification

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

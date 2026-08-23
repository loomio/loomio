class NotificationService
  # Commit one logical occurrence, then resolve all channel deliveries in the
  # background. Explicit audiences are snapshotted on the notification while
  # implied audiences are derived by the same kind-specific resolver.
  def self.create!(kind:, subject:, actor:,
                   recipient_user_ids: [], recipient_chatbot_ids: [],
                   recipient_message: nil, audience_values: {}, topic_item: nil)
    raise ArgumentError, "subject must be persisted" unless subject&.persisted?
    raise ArgumentError, "kind is required" if kind.blank?
    if topic_item && (!topic_item.persisted? || topic_item.kind != kind || topic_item.itemable != subject)
      raise ArgumentError, "topic_item must be persisted and match the notification kind and subject"
    end

    resolver_class = NotificationDeliveryResolver.class_for(kind)
    resolver_class.validate_subject!(subject)
    translation_values = resolver_class.translation_values(subject, actor)

    notification = Notification.create!(
      actor: actor,
      kind: kind,
      subject: subject,
      topic_item: topic_item,
      translation_values: translation_values,
      recipient_user_ids: Array(recipient_user_ids).compact.map(&:to_i).uniq,
      recipient_chatbot_ids: Array(recipient_chatbot_ids).compact.map(&:to_i).uniq,
      recipient_message: recipient_message.presence,
      audience_values: audience_values
    )

    ResolveNotificationDeliveriesWorker.perform_later(notification.id)
    notification
  end

  def self.mark_as_read(itemable_type, itemable_id, actor_id)
    deliveries = NotificationDelivery
                        .joins(:notification)
                        .where(
                          channel: "in_app",
                          recipient_type: "User",
                          recipient_id: actor_id,
                          viewed_at: nil,
                          notifications: {
                            subject_type: itemable_type,
                            subject_id: itemable_id
                          }
                        )
    notification_ids = deliveries.distinct.pluck(:notification_id)
    deliveries.update_all(viewed_at: Time.current, updated_at: Time.current)
    notifications = Notification.where(id: notification_ids).to_a
    notifications.each(&:reload)
    MessageChannelService.publish_models(notifications, user_id: actor_id)
  end

  def self.viewed_topic_items(actor_id:, topic_id:, sequence_ids:)
    topic_items = TopicItem.includes(:itemable).where(topic_id: topic_id, sequence_id: sequence_ids)
    reactions = Reaction.where(reactable: topic_items.map(&:itemable))
    itemable_ids = Hash.new { |h, k| h[k] = [] }
    topic_items.each { |topic_item| itemable_ids[topic_item.itemable_type] << topic_item.itemable_id }
    reactions.each { |reaction| itemable_ids["Reaction"] << reaction.id }

    notification_scope = Notification.none
    itemable_ids.each_pair do |type, ids|
      notification_scope = notification_scope.or(Notification.where(subject_type: type, subject_id: ids))
    end
    deliveries = NotificationDelivery.where(
      notification_id: notification_scope.select(:id),
      recipient_type: "User",
      recipient_id: actor_id,
      channel: "in_app",
      viewed_at: nil
    )
    notification_ids = deliveries.distinct.pluck(:notification_id)
    deliveries.update_all(viewed_at: Time.current, updated_at: Time.current)
    notifications = Notification.where(id: notification_ids).to_a
    MessageChannelService.publish_models(notifications, user_id: actor_id)
  end

  def self.viewed(user:)
    NotificationDelivery.where(
      recipient: user,
      channel: "in_app",
      status: "delivered",
      viewed_at: nil
    ).update_all(viewed_at: Time.current, updated_at: Time.current)
    notifications = user.notifications.includes(:actor).order(created_at: :desc).limit(30)

    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_models(notifications, user_id: user.id)
  end
end

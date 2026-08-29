class NotificationService
  # Commit one logical occurrence, then route its channel deliveries in the
  # background. Selected recipients and expansion metadata are snapshotted on
  # the notification; each kind-specific router applies its recipient rules.
  def self.create!(kind:, subject:, actor:,
                   recipient_user_ids: [], recipient_chatbot_ids: [],
                   recipient_audience: nil, recipient_message: nil, recipient_context: {})
    raise ArgumentError, "subject must be persisted" unless subject&.persisted?
    raise ArgumentError, "kind is required" if kind.blank?

    subject_model = subject.is_a?(TopicItem) ? subject.itemable : subject

    router_class = NotificationDeliveryRouter.class_for(kind)
    router_class.validate_subject!(subject_model)
    translation_values = router_class.translation_values(subject_model, actor)

    notification = Notification.create!(
      actor: actor,
      kind: kind,
      subject: subject,
      translation_values: translation_values,
      recipient_audience: recipient_audience.presence,
      recipient_user_ids: Array(recipient_user_ids).compact.map(&:to_i).uniq,
      recipient_chatbot_ids: Array(recipient_chatbot_ids).compact.map(&:to_i).uniq,
      recipient_message: recipient_message.presence,
      recipient_context: recipient_context
    )

    RouteNotificationDeliveriesWorker.perform_later(notification.id)
    notification
  end

  def self.mark_as_read(itemable_type, itemable_id, actor_id)
    deliveries = NotificationDelivery
      .where(
        notification_id: Notification.about_identity(itemable_type, itemable_id).select(:id),
        channel: "in_app",
        recipient_type: "User",
        recipient_id: actor_id,
        viewed_at: nil
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

    notification_scope = Notification.where(
      subject_type: "TopicItem",
      subject_id: topic_items.select(:id)
    )
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

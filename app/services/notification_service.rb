class NotificationService
  # Read current group and subscription state so queued work also stops after
  # discard, expiry, cancellation, or hold.
  def self.group_enabled?(subject)
    model = subject.is_a?(TopicItem) ? subject.itemable : subject
    group = model.is_a?(Group) ? model : (model.group if model.respond_to?(:group))
    return true if group.blank?

    Group.enabled.exists?(id: group.id)
  end

  # Commit one logical occurrence, then route its channel deliveries in the
  # background. Selected recipients and expansion metadata are snapshotted on
  # the notification; each kind-specific router applies its recipient rules.
  def self.create!(kind:, subject:, actor:,
                   recipient_user_ids: [], recipient_chatbot_ids: [],
                   recipient_audience: nil, recipient_message: nil, recipient_context: {},
                   skip_invitation_limit: false)
    raise ArgumentError, "subject must be persisted" unless subject&.persisted?
    raise ArgumentError, "kind is required" if kind.blank?

    notification = Notification.new(
      actor: actor,
      kind: kind,
      subject: subject,
      recipient_audience: NotificationAudienceService.serialize(recipient_audience),
      recipient_user_ids: Array(recipient_user_ids).compact.map(&:to_i).uniq,
      recipient_chatbot_ids: Array(recipient_chatbot_ids).compact.map(&:to_i).uniq,
      recipient_message: recipient_message.presence,
      recipient_context: recipient_context
    )
    router = NotificationDeliveryRouter.for(notification)
    locale = actor&.locale || I18n.default_locale
    notification.translation_values = router.translated_values(locale: locale)
    if skip_invitation_limit
      notification.save!
    else
      save_with_invitation_limit!(notification)
    end

    RouteNotificationDeliveriesWorker.perform_later(notification.id)
    notification
  end

  def self.save_with_invitation_limit!(notification)
    unless notification.actor && UserInviter::INVITATION_KINDS.include?(notification.kind)
      return notification.save!
    end

    Notification.transaction do
      UserInviter.check_invitation_limit!(actor: notification.actor, user_ids: notification.recipient_user_ids)
      recipient_ids = notification.recipient_user_ids
      recipient_ids = [ notification.subject_model.user_id ] if notification.kind == 'membership_resent'
      TrialInvitationLimit.reserve!(actor: notification.actor, user_ids: recipient_ids)
      notification.save!
    end
  end
  private_class_method :save_with_invitation_limit!

  def self.mark_as_read(itemable_type, itemable_id, actor_id)
    deliveries = NotificationDelivery
      .where(
        notification_id: Notification.about(itemable_type, itemable_id).select(:id),
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
    NotificationDelivery.delivered.where(
      recipient: user,
      channel: "in_app",
      viewed_at: nil
    ).update_all(viewed_at: Time.current, updated_at: Time.current)
    notifications = user.notifications.includes(:actor).order(created_at: :desc).limit(30)

    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_models(notifications, user_id: user.id)
  end
end

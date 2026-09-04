class NotificationQuery
  # Delivery establishes the recipient boundary, while current authorization
  # prevents an old notification from preserving access after permissions change.
  def self.delivered_to(user:, chain: Notification.all, unseen: false)
    deliveries = NotificationDelivery.delivered.where(
      recipient: user,
      channel: "in_app"
    )
    deliveries = deliveries.where(viewed_at: nil) if unseen

    chain.where(id: deliveries.select(:notification_id))
  end

  def self.currently_accessible_to(user:, notifications:)
    notifications = notifications.to_a
    topic_items = notifications.filter_map do |notification|
      notification.subject if notification.subject.is_a?(TopicItem)
    end
    ActiveRecord::Associations::Preloader.new(
      records: topic_items,
      associations: %i[itemable topic]
    ).call

    topic_ids = notifications.filter_map do |notification|
      notification_topic_id(notification)
    end.uniq
    accessible_topic_ids = TopicQuery.visible_to(user: user)
                                     .unscope(:includes)
                                     .where(id: topic_ids)
                                     .pluck(:id)
                                     .to_set

    poll_ids = notifications.filter_map do |notification|
      notification_poll_id(notification.subject_model)
    end.uniq
    accessible_poll_ids = PollQuery.visible_to(user: user)
                                   .unscope(:includes)
                                   .where(id: poll_ids)
                                   .pluck(:id)
                                   .to_set

    notifications.select do |notification|
      subject = notification.subject_model
      topic_id = notification_topic_id(notification)
      next false if topic_id && !accessible_topic_ids.include?(topic_id)

      poll_id = notification_poll_id(subject)
      next accessible_poll_ids.include?(poll_id) if poll_id

      user.can?(:show, subject)
    end
  end

  def self.notification_topic_id(notification)
    return notification.subject.topic_id if notification.subject.is_a?(TopicItem)

    subject = notification.subject_model
    subject.topic_id if subject.respond_to?(:topic_id)
  end
  private_class_method :notification_topic_id

  def self.notification_poll_id(subject)
    case subject
    when Poll then subject.id
    when Outcome, Stance then subject.poll_id
    end
  end
  private_class_method :notification_poll_id
end

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
    topic_ids = notifications.filter_map do |notification|
      subject = notification.subject_model
      subject.topic&.id if subject.respond_to?(:topic)
    end.uniq
    accessible_topic_ids = TopicQuery.visible_to(user: user)
                                     .unscope(:includes)
                                     .where(id: topic_ids)
                                     .pluck(:id)
                                     .to_set

    notifications.select do |notification|
      subject = notification.subject_model
      topic_id = subject.respond_to?(:topic) ? subject.topic&.id : nil
      next false if topic_id && !accessible_topic_ids.include?(topic_id)

      user.can?(:show, subject)
    end
  end
end

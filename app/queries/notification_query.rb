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
    preload_subject_dependencies(notifications)

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

  # Notifications may point directly at a domain record or at its timeline
  # item. Load the complete topic path once so authorization and URL rendering
  # do not query the same subjects, topics and groups for every notification.
  def self.preload_subject_dependencies(notifications)
    topic_items = notifications.filter_map do |notification|
      notification.subject if notification.subject.is_a?(TopicItem)
    end
    preload(topic_items, [ :itemable, { topic: %i[group topicable] } ])

    models = notifications.map(&:subject_model)
    loop do
      containers = models.grep(Comment) + models.grep(Reaction)
      break if containers.empty?

      comments = containers.grep(Comment)
      reactions = containers.grep(Reaction)
      preload(comments, :parent)
      preload(reactions, :reactable)
      nested_models = comments.map(&:parent) + reactions.map(&:reactable)
      new_models = nested_models.compact - models
      break if new_models.empty?

      models.concat(new_models)
    end

    poll_dependents = models.grep(Outcome) + models.grep(Stance)
    preload(poll_dependents, :poll)
    polls = poll_dependents.map(&:poll)
    topic_owners = models.grep(Discussion) + models.grep(Poll) + polls
    preload(topic_owners.uniq, { topic: %i[group topicable] })
  end
  private_class_method :preload_subject_dependencies

  def self.preload(records, associations)
    return if records.empty?

    ActiveRecord::Associations::Preloader.new(
      records: records,
      associations: associations
    ).call
  end
  private_class_method :preload

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

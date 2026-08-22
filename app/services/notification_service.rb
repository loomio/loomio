class NotificationService
  INDEX_DEDUPLICATION = "index_notifications_on_user_id_and_deduplication_key"

  # Insert event-backed notifications at the database idempotency boundary.
  # Existing event rows remain authoritative for rendering during migration;
  # the copied fields make each new notification independently renderable later.
  # Return only rows inserted by this attempt so retries do not repeat realtime
  # or email side effects.
  def self.create_for_event!(event:, notifications:)
    notifications = Array(notifications)
    return [] if notifications.empty?
    raise ArgumentError, "event must be persisted" unless event.persisted?
    unless notifications.all? { |notification| notification.event_id == event.id }
      raise ArgumentError, "notifications must belong to the delivery event"
    end

    # Older migrations can publish events before the additive delivery columns
    # exist. Preserve the original event-backed insertion path until that schema
    # checkpoint has been crossed.
    unless delivery_fields_available?
      Notification.import(notifications)
      return notifications
    end

    deduplication_key = "event:#{event.id}"
    created_at = Time.current
    notification_ids_inserted = []

    Notification.transaction do
      notifications_by_user_id = notifications.index_by(&:user_id)
      existing_by_user_id = Notification
        .where(event_id: event.id, user_id: notifications_by_user_id.keys)
        .where(deduplication_key: [ nil, deduplication_key ])
        .order(:id)
        .lock
        .group_by(&:user_id)

      # A retry may encounter a notification created before dual-writing was
      # deployed. Adopt that row without treating it as a new delivery.
      existing_by_user_id.each do |user_id, existing_notifications|
        notification = notifications_by_user_id.delete(user_id)
        existing = existing_notifications.find { |record| record.deduplication_key == deduplication_key }
        existing ||= existing_notifications.first
        next if existing.deduplication_key == deduplication_key

        existing.update_columns(
          kind: notification.kind,
          subject_type: event.eventable_type,
          subject_id: event.eventable_id,
          deduplication_key: deduplication_key
        )
      end

      rows = notifications_by_user_id.values.map do |notification|
        {
          user_id: notification.user_id,
          actor_id: notification.actor_id,
          event_id: event.id,
          kind: notification.kind,
          subject_type: event.eventable_type,
          subject_id: event.eventable_id,
          deduplication_key: deduplication_key,
          translation_values: notification.translation_values,
          viewed: notification.viewed,
          created_at: created_at,
          updated_at: created_at
        }
      end

      if rows.any?
        result = Notification.insert_all(
          rows,
          unique_by: INDEX_DEDUPLICATION,
          returning: [ :id ]
        )
        notification_ids_inserted = result.rows.flatten
      end
    end

    Notification.where(id: notification_ids_inserted).order(:id).to_a
  end

  def self.delivery_fields_available?
    Notification.connection.column_exists?(:notifications, :deduplication_key)
  end
  private_class_method :delivery_fields_available?

  def self.mark_as_read(eventable_type, eventable_id, actor_id)
    ids = Notification.joins(:event)
      .where(user_id: actor_id, viewed: false)
      .where('events.eventable_type': eventable_type, 'events.eventable_id': eventable_id).pluck(:id)

    notifications = Notification.where(user_id: actor_id, id: ids, 'viewed': false)
    notifications.update_all(viewed: true)
    notifications.reload
    MessageChannelService.publish_models(notifications, user_id: actor_id)
  end

  def self.viewed_events(actor_id:, topic_id:, sequence_ids:)
    event_ids = []

    events = Event.includes(:eventable).where(topic_id: topic_id, sequence_id: sequence_ids)

    reactions = Reaction.where(reactable: events.map(&:eventable))
    event_ids.concat Event.where(eventable: reactions).pluck(:id)

    eventable_ids = Hash.new { |h, k| h[k] = [] }
    Event.where(topic_id: topic_id, sequence_id: sequence_ids)
         .pluck(:eventable_type, :eventable_id)
         .each { |type, id| eventable_ids[type] << id }

    eventable_ids.each_pair do |type, ids|
      event_ids.concat Notification.joins(:event).where(
        user_id: actor_id,
        viewed: false,
        'events.eventable_type': type,
        'events.eventable_id': ids).pluck('events.id')
    end

    notifications = Notification.where(user_id: actor_id, event_id: event_ids.uniq, viewed: false)
    notifications.update_all(viewed: true)
    notifications.reload
    MessageChannelService.publish_models(notifications, user_id: actor_id)
  end

  def self.viewed(user:)
    user.notifications.where(viewed: false).update_all(viewed: true)
    notifications = user.notifications.includes(:actor, :user).order(created_at: :desc).limit(30)

    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_models(notifications, user_id: user.id)
  end
end

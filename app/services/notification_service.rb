class NotificationService
  def self.mark_as_read(eventable_type, eventable_id, actor_id)
    ids = Notification.joins(:event)
      .where(user_id: actor_id, viewed: false)
      .where('events.eventable_type': eventable_type, 'events.eventable_id': eventable_id).pluck(:id)

    notifications = Notification.where(user_id: actor_id, id: ids, 'viewed': false)
    notifications.update_all(viewed: true)
    notifications.reload
    MessageChannelService.publish_models(notifications, user_id: actor_id)
  end

  def self.viewed_events(actor_id:, discussion_id: , sequence_ids: )
    event_ids = []

    events = Event.includes(:eventable).where(discussion_id: discussion_id, sequence_id: sequence_ids)

    reactions = Reaction.where(reactable: events.map(&:eventable))
    event_ids.concat Event.where(eventable: reactions).pluck(:id)

    eventable_ids = {}

    %w[Comment Discussion Poll Stance Outcome].each do |type|
      eventable_ids[type] = Event.where(
        discussion_id: discussion_id,
        sequence_id: sequence_ids,
        eventable_type: type).pluck(:eventable_id) 
    end

    
    eventable_ids.each_pair do |type, ids|
      event_ids.concat Notification.joins(:event).where(
        user_id: actor_id,
        viewed: false,
        'events.eventable_type': type,
        'events.eventable_id': ids).pluck('events.id')
    end

    notifications = Notification.where(user_id: actor_id).
      where(event_id: event_ids.uniq).
      where('viewed': false)
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

class NotificationService
  def self.viewed_events(actor_id:, discussion_id: , sequence_ids: )
    events = Event.includes(:eventable).where(discussion_id: discussion_id, sequence_id: sequence_ids)
    reactions = Reaction.where(reactable: events.map(&:eventable))

    event_ids = events.pluck(:id).concat Event.where(eventable: reactions).pluck(:id)

    notifications = Notification.where(user_id: actor_id).
      where(event_id: event_ids).
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

class NotificationService
  def self.viewed_events(actor:, events:)
    notifications = Notification.where(user_id: actor.id).
      where(event_id: events.pluck(:id)).
      where('viewed': false)
    notifications.update_all(viewed: true)
    notifications.reload
    MessageChannelService.publish_models(notifications, user_id: actor.id)
  end

  def self.viewed(user:)
    user.notifications.where(viewed: false).update_all(viewed: true)
    notifications = user.notifications.includes(:actor, :user).order(created_at: :desc).limit(30)

    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_models(notifications, user_id: user.id)
  end
end

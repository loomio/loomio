class NotificationService
  def self.viewed(user:)
    user.notifications.where(viewed: false).update_all(viewed: true)
    notifications = user.notifications.includes(:actor, :user).order(created_at: :desc).limit(30)

    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_models(notifications, user_ids: [actor.id])
  end
end

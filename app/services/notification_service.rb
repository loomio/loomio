class NotificationService
  def self.viewed(user:)
    user.notifications.where(viewed: false).update_all(viewed: true)
    EventBus.broadcast 'notification_viewed', user
  end
end

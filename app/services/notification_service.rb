class NotificationService
  def self.mark_as_viewed(user)
    Notification.where(user_id: user.id, viewed: false).update_all(viewed: true)
  end
end

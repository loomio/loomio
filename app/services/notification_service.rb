class NotificationService
  def self.viewed(user:)
    user.notifications.where(viewed: false).update_all(viewed: true)
    # alert clients (say, user's other tabs) that notifications have been read
    MessageChannelService.publish_records(NotificationCollection.new(actor).serialize!, user_ids: [actor.id])
  end
end

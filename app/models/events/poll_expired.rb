class Events::PollExpired < Event
  include Events::Notify::Author
  include Events::Notify::Chatbots
  include Events::Notify::InApp

  def self.publish!(poll)
    super poll,
          user: poll.author,
          topic: nil,
          created_at: poll.closed_at
  end

  # email the author and create an in-app notification
  def email_author!
    return unless eventable.present?

    notifications_created = NotificationService.create_for_event!(
      event: self,
      notifications: [ notification_for(author) ]
    )
    EventMailer.event(author, self).deliver_later if notify_author? && notifications_created.any?
  end

  def notify_author?
    return false unless eventable.present?
    eventable.topic.volume_gte_normal_members.exists?(eventable.author_id)
  end
end

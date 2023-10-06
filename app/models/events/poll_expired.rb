class Events::PollExpired < Event
  include Events::Notify::Author
  include Events::Notify::Chatbots
  include Events::Notify::InApp

  def self.publish!(poll)
    super poll,
          user: poll.author,
          discussion: nil,
          created_at: poll.closed_at
  end

  # email the author and create an in-app notification
  def email_author!
    super
    notification_for(author).save
  end

  def notify_author?
    return false unless eventable.present? && eventable.poll.present?
    Queries::UsersByVolumeQuery.email_notifications(eventable).exists?(eventable.poll.author_id)
  end
end

class Events::PollOptionAdded < Event
  include Events::Notify::Author
  include Events::Notify::InApp

  def self.publish!(poll, actor, poll_option_names = [])
    return unless Array(poll_option_names).any?
    super poll,
          user: (actor unless poll.anonymous?),
          custom_fields: { poll_option_names: poll_option_names }
  end

  private

  def notify_author?
    Queries::UsersByVolumeQuery.email_notifications(eventable).exists?(poll.author_id)
  end
  
  def notification_recipients
    User.where(id: eventable.author_id)
  end
end

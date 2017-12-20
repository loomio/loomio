class Events::PollOptionAdded < Event
  include Events::Notify::Author

  def self.publish!(poll, actor, poll_option_names = [])
    return unless Array(poll_option_names).any?
    super poll,
          user: (actor if actor.is_logged_in?),
          parent: poll.created_event,
          custom_fields: { poll_option_names: poll_option_names }
  end

  private

  # TODO: make poll options added an announcement as well
  def notification_recipients
    poll.participants
  end
  alias :email_recipients :notification_recipients
end

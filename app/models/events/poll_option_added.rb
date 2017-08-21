class Events::PollOptionAdded < Event
  include Events::PollEvent
  include Events::Notify::Author

  def self.publish!(poll, actor, poll_option_names = [])
    return unless Array(poll_option_names).any?
    super poll,
          user: actor,
          custom_fields: {poll_option_names: poll_option_names},
          announcement: poll.make_announcement
  end

  private

  def notification_recipients
    if announcement then poll.participants else User.none end
  end
  alias :email_recipients :notification_recipients
end

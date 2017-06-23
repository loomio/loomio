class Events::PollOptionAdded < Event
  include Events::PollEvent
  include Events::Notify::Visitors

  def self.publish!(poll, actor, poll_option_names = [])
    return unless Array(poll_option_names).any?
    create(kind: "poll_option_added",
           eventable: poll,
           custom_fields: {poll_option_names: poll_option_names},
           announcement: poll.make_announcement).tap { |e| EventBus.broadcast('poll_option_added_event', e) }
  end

  private

  def notification_recipients
    if announcement then poll.participants else User.none end
  end
  alias :email_recipients :notification_recipients

  def email_visitors
    if announcement then poll.visitor_participants else Visitor.none end
  end
end

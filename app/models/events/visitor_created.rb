class Events::VisitorCreated < Event
  include Events::EmailUser

  def self.publish!(visitor, inviter)
    create(kind: "visitor_created",
           user: inviter,
           eventable: visitor).tap { |e| EventBus.broadcast('visitor_created_event', e) }
  end

  private

  def email_users!
    return unless poll = eventable.community.polls.last
    PollMailer.send(:poll_created, eventable, poll).deliver_now
  end
end

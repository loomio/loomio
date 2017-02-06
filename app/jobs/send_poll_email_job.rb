class SendPollEmailJob < ActiveJob::Base
  def perform(event_id)
    return unless event = Event.find_by(id: event_id)
    # NB: polls must operate on event, not eventable, because we need to know about
    # the value of event.announcement
    BaseMailer.send_bulk_mail(to: Queries::UsersToEmailQuery.send(event.kind, event)) do |user|
      PollMailer.delay(priority: 2).send(event.kind, user, event)
    end
  end
end

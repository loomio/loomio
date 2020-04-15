class NotifyWebhooksWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = Event.find(event_id)
    eventable = event.eventable
    if eventable.group
      eventable.group.identities.map { |i| i.notify!(event) }
      eventable.group.webhooks.each { |w| w.publish!(event) }
    end
  end
end

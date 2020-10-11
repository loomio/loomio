class NotifyWebhooksWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = Event.find(event_id)
    eventable = event.eventable
    eventable.group.identities.each do |i|
      i.notify!(event) if i.respond_to? :notify!
    end
    eventable.group.webhooks.each { |w| w.publish!(event) unless w.is_broken }
  end
end

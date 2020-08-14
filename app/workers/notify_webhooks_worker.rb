class NotifyWebhooksWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = Event.find(event_id)
    eventable = event.eventable
    if eventable.group
      eventable.group.identities.each do |i|
        i.notify!(event) if i.respond_to? :notify!
      end
      eventable.group.webhooks.each { |w| w.publish!(event) unless w.is_broken }
      # if eventable.group.is_visible_to_parent_members &&  eventable.group.parent
      #   eventable.group.parent.webhooks.include_subgroups.each { |w| w.publish!(event) }
      # end
    end
  end
end

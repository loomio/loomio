class NotifyChatbotsWorker
  include Sidekiq::Worker

  def perform(event_id)
    event = Event.find(event_id)
    eventable = event.eventable
    eventable.group.chatbots.each { |cb| cb.publish!(event) }
  end
end

class PublishEventWorker
  include Sidekiq::Worker

  def perform(event_id)
    Event.sti_find(event_id).trigger!
  end
end

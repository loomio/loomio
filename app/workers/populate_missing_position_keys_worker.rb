class PopulateMissingPositionKeysWorker
  include Sidekiq::Worker

  def perform(event_id, limit)
    Event.where("discussion_id is not null and position_key is null and events.id >= ?", event_id).
          includes(parent: [:parent]).order('events.id').limit(limit).each do |event|
      event.set_position_and_position_key!
    end
  end
end

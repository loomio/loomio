class EventService
  def self.remove_from_thread(event:, actor:)
    actor.ability.authorize! :remove_from_thread, event
    discussion = event.discussion
    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    event
  end

  def self.readd_to_thread(kind:)
    Event.where(kind: kind, discussion_id: nil).where("sequence_id is not null").find_each do |event|
      next unless event.eventable
      bumped_event_count = Event.where(discussion_id: event.eventable.discussion_id)
           .where("sequence_id >= ?", event.sequence_id)
           .update_all("sequence_id = sequence_id+1")
      if bumped_event_count > 0
        event.update_attribute(:discussion_id, event.eventable.discussion_id)
        event.reload.discussion.update_sequence_info!
      end
    end
  end
end

class EventService
  def self.remove_from_thread(event:, actor:)
    actor.ability.authorize! :remove_from_thread, event
    discussion = event.discussion
    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    event
  end

  def self.restore_poll_expired
    Event.where(kind: "poll_expired", discussion_id: nil).where("sequence_id is not null").find_each do |event|
      Event.where(discussion_id: event.eventable.discussion_id).where("sequence_id >= ?", event.sequence_id).
            update_all("sequence_id = sequence_id+1")
      event.update_attribute(:discussion_id, event.eventable.discussion_id) if event.eventable.discussion_id
    end
  end
end

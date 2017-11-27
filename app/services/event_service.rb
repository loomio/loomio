class EventService
  def self.remove_from_thread(event:, actor:)
    actor.ability.authorize! :remove_from_thread, event
    discussion = event.discussion
    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    event
  end
end

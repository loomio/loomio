class UpdateAllDiscussionItemsWithPositionKey < ActiveRecord::Migration[5.2]
  def change
    execute("UPDATE events
             SET position_key = CONCAT(REPEAT('0',5-LENGTH(CONCAT(position))), position)
             WHERE depth = 1 and position_key IS NULL and discussion_id IS NOT NULL")

    # only need to reset children, where the event has children.. they can be done after the parent.
    parent_ids = Event.where("discussion_id is not null and position_key is null and parent_id is not null").order(:id).pluck(:parent_id).uniq.compact
    Event.where(id: parent_ids).order(:id).each do |parent_event|
      EventService.delay.reset_child_positions(parent_event.id, parent_event.position_key)
    end
  end
end

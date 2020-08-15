class CreateEventsDescendantCount < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :descendant_count, :integer, default: 0, null: false

    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    # new_discussion events
    execute("UPDATE events
             SET descendant_count = (
               SELECT count(id) from events children
               WHERE children.discussion_id = events.eventable_id
             )
             WHERE events.kind = 'new_discussion'")

    execute("UPDATE events
             SET descendant_count = (
               SELECT count(children.id)
               FROM events children
               WHERE
                  children.discussion_id = events.discussion_id AND
                  children.id != events.id AND
                  children.position_key like CONCAT(events.position_key, '%')
              )
             WHERE discussion_id is not null")
  end
end

class AddIndexIndexEventsOnDiscussionIdToEvents < ActiveRecord::Migration
  def change
    add_index "events", ["discussion_id"], :name => "index_events_on_discussion_id"
  end
end

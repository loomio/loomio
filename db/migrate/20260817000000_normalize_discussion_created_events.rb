class NormalizeDiscussionCreatedEvents < ActiveRecord::Migration[8.0]
  INDEX_NAME = "index_events_on_unique_discussion_created_event"

  def up
    DiscussionCreatedEventCleanupService.normalize!

    add_index :events,
              [ :eventable_type, :eventable_id, :kind ],
              unique: true,
              where: "eventable_type = 'Discussion' AND kind = 'new_discussion'",
              name: INDEX_NAME
  end

  def down
    remove_index :events, name: INDEX_NAME
  end
end

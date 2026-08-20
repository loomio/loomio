class NormalizePollCreatedEvents < ActiveRecord::Migration[8.0]
  INDEX_NAME = "index_events_on_unique_poll_created_event"

  def up
    PollCreatedEventCleanupService.normalize!

    add_index :events,
              [ :eventable_type, :eventable_id, :kind ],
              unique: true,
              where: "eventable_type = 'Poll' AND kind = 'poll_created'",
              name: INDEX_NAME
  end

  def down
    remove_index :events, name: INDEX_NAME
  end
end

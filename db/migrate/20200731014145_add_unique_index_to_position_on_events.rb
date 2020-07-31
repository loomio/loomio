class AddUniqueIndexToPositionOnEvents < ActiveRecord::Migration[5.2]
  def change
    add_index :events, ["parent_id", "position"], name: "index_events_on_parent_id_and_position", unique: true, where: "discussion_id IS NOT NULL AND parent_id IS NOT NULL and position != 0"
  end
end

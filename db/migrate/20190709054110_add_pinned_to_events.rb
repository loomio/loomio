class AddPinnedToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :pinned, :boolean, default: false, null: false
    add_index :events, :pinned, name: "index_events_on_pinned_true", where: "(pinned IS TRUE)"
    Event.where(kind: "poll_created").update_all(pinned: true)
  end
end

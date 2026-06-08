class AddEventsIndexIndexes < ActiveRecord::Migration[7.1]
  def change
    # Covers depth-filtered thread navigation with ORDER BY sequence_id.
    # Previously the planner scanned all topic events and filtered depth inline.
    add_index :events, [:topic_id, :depth, :sequence_id],
              name: "index_events_on_topic_id_depth_sequence_id"

    # Covers pinned events queries — partial keeps it tiny since pinned is rare.
    add_index :events, [:topic_id, :sequence_id],
              where: "pinned = TRUE",
              name: "index_events_on_topic_id_sequence_id_pinned"
  end
end

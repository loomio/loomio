require_relative "support/legacy_topic_event_repair_service"

class AddEventParentIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # PostgreSQL needs a complete index on the referencing column to enforce
    # cascading deletes without scanning the events table for every parent.
    # The existing partial (parent_id, topic_id) index excludes rootless events.
    add_index :events, :parent_id, algorithm: :concurrently, if_not_exists: true

    topic_ids = select_values(<<~SQL)
      SELECT DISTINCT child.topic_id
      FROM events child
      LEFT JOIN events parent ON parent.id = child.parent_id
      WHERE child.parent_id IS NOT NULL
        AND parent.id IS NULL
        AND child.topic_id IS NOT NULL
    SQL
    execute(<<~SQL)
      UPDATE events child
      SET parent_id = NULL, depth = 0
      WHERE child.topic_id IS NULL
        AND child.parent_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM events parent WHERE parent.id = child.parent_id)
    SQL
    topic_ids.each { |topic_id| LegacyTopicEventRepairService.repair!(topic_id) }

    add_foreign_key :events,
                    :events,
                    column: :parent_id,
                    on_delete: :cascade,
                    validate: false
  end

  def down
    remove_foreign_key :events, column: :parent_id
    remove_index :events, :parent_id, algorithm: :concurrently, if_exists: true
  end
end

class AddEventParentIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # PostgreSQL needs a complete index on the referencing column to enforce
    # cascading deletes without scanning the events table for every parent.
    # The existing partial (parent_id, topic_id) index excludes rootless events.
    add_index :events, :parent_id, algorithm: :concurrently, if_not_exists: true

    CleanupService.delete_orphan_records

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

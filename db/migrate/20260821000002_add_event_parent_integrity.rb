class AddEventParentIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    CleanupService.delete_orphan_records

    add_foreign_key :events,
                    :events,
                    column: :parent_id,
                    on_delete: :cascade,
                    validate: false
  end

  def down
    remove_foreign_key :events, column: :parent_id
  end
end

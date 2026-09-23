class IndexReceivedEmailGroupReferences < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :received_emails, :group_id, algorithm: :concurrently
  end
end

class AddNotificationEmailSyncDueAt < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :notification_deliveries, :email_sync_due_at, :datetime
    add_index :notification_deliveries, [ :email_sync_due_at, :id ],
      where: 'email_sync_due_at IS NOT NULL', name: 'index_notification_deliveries_on_email_sync_due', algorithm: :concurrently
  end
end

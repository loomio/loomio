class AddNotificationEmailSendCursorIndex < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :notification_deliveries, [:delivered_at, :id],
      where: "channel = 'email' AND delivered_at IS NOT NULL",
      name: :index_notification_deliveries_on_email_send_cursor,
      algorithm: :concurrently
  end
end

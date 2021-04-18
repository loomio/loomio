class AddNotificationsIndex < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    execute "CREATE INDEX CONCURRENTLY ON notifications (user_id, id)"
  end
end

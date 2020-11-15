class DropIndexNotificationsUserAndCreated < ActiveRecord::Migration[5.2]
  def change
    remove_index :notifications, name: :notifications_user_id_created_at_idx
    add_index :notifications, :id, order: {id: :desc}
    execute('vacuum analyze notifications')
  end
end

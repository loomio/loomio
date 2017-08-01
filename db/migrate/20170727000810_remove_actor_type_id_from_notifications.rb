class RemoveActorTypeIdFromNotifications < ActiveRecord::Migration
  def change
    Notification.where(actor_type: 'Visitor').delete_all
    remove_column :notifications, :actor_type, :string, limit: 255
  end
end

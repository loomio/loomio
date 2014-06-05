class AddEmailNotificationDefaultToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :email_notification_default, :boolean, default: true, null: false
  end
end

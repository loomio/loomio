class RemoveUnusedEmailColumns < ActiveRecord::Migration
  def change
    remove_column :groups, :email_new_motion
    remove_column :groups, :email_notification_default
  end
end

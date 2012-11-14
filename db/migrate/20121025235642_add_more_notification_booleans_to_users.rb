class AddMoreNotificationBooleansToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_mention_notifications, :boolean
    add_column :users, :subscribed_to_proposal_closure_notifications, :boolean
    add_column :memberships, :subscribed_to_notification_emails, :boolean
  end
end

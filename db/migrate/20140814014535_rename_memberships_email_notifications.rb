class RenameMembershipsEmailNotifications < ActiveRecord::Migration
  def change
    rename_column :memberships, :subscribed_to_notification_emails, :email_new_discussion_and_proposal_notifications
    add_column    :users, :new_discussion_and_proposal_notifications_enabled, :boolean, default: true, null: false
  end
end

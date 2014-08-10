class ChangeEmailPreferencesColumns < ActiveRecord::Migration
  def change
    rename_column :users, :subscribed_to_mention_notifications, :email_when_mentioned
    rename_column :users, :subscribed_to_missed_yesterday_email, :email_missed_yesterday
    add_column    :users, :email_followed_threads, :boolean, default: true, null: false
    rename_column :users, :subscribed_to_proposal_closure_notifications, :email_when_proposal_closing_soon
  end
end

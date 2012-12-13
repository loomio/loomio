class ChangeUsersToDefaultToSubscribed < ActiveRecord::Migration
  def up
    change_column :users, :subscribed_to_daily_activity_email, :boolean, :null => false, :default => true
    change_column :users, :subscribed_to_proposal_closure_notifications, :boolean, :null => false, :default => true
    change_column :users, :subscribed_to_mention_notifications, :boolean, :null => false, :default => true
  end

  def down
  end
end

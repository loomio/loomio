class RemoveUnusedColumns < ActiveRecord::Migration
  def up
    remove_column :users, :invitation_sent_at
    remove_column :users, :invitation_accepted_at
    remove_column :users, :invitation_limit
    remove_column :users, :invited_by_id
    remove_column :users, :invited_by_type
    remove_column :users, :has_read_system_notice
    remove_column :users, :subscribed_to_daily_activity_email
    remove_column :users, :unconfirmed_email
    remove_column :motions, :close_at_date
    remove_column :motions, :close_at_time
    remove_column :motions, :close_at_time_zone
    remove_column :memberships, :group_last_viewed_at
    remove_column :comments, :title
    remove_column :comments, :lft
    remove_column :comments, :rgt
    drop_table :campaign_signups
  end

  def down
  end
end

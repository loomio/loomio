class MakeUsersDefaultToGetMentionedNotifications < ActiveRecord::Migration
  def up
    User.update_all :subscribed_to_mention_notifications => true
    change_column :users, :subscribed_to_mention_notifications, :boolean, null: false, default: true
  end

  def down
  end
end

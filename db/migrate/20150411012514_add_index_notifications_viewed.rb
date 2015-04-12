class AddIndexNotificationsViewed < ActiveRecord::Migration
  def change
    Notification.where('viewed_at IS NOT NULL').update_all(viewed: true)
  end
end

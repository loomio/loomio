class AddIndexNotificationsViewed < ActiveRecord::Migration
  def change
    Notification.where('id < ?', 2300000).update_all(viewed: true)
    Notification.where('viewed_at IS NOT NULL').update_all(viewed: true)
  end
end

class AddSendDailyActivityEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_daily_activity_email, :boolean
  end
end

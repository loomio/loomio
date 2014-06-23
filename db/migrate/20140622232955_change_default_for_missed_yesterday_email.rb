class ChangeDefaultForMissedYesterdayEmail < ActiveRecord::Migration
  def up
    change_column :users, :subscribed_to_missed_yesterday_email, :boolean, default: true, null: false
    User.where(subscribed_to_missed_yesterday_email: false, subscribed_to_daily_activity_email: true).update_all(subscribed_to_missed_yesterday_email: true)
  end

  def down
  end
end

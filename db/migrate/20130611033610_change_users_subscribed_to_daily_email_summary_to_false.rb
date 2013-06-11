class ChangeUsersSubscribedToDailyEmailSummaryToFalse < ActiveRecord::Migration
  def up
    change_column :users, :subscribed_to_daily_activity_email, :boolean, default: false, null: false
  end

  def down
  end
end

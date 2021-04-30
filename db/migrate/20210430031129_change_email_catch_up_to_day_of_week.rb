class ChangeEmailCatchUpToDayOfWeek < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_catch_up_day, :integer, default: nil
    User.where(email_catch_up: true).update_all(email_catch_up_day: 7)
  end
end

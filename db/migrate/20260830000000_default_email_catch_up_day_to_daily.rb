class DefaultEmailCatchUpDayToDaily < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :email_catch_up_day, from: nil, to: 7
  end
end

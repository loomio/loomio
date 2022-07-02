class AddDateTimeFormatToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :date_time_pref, :string, default: nil
  end
end

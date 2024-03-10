class AddAutodetectTimeZoneBooleanToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :autodetect_time_zone, :boolean, default: true, null: false
  end
end

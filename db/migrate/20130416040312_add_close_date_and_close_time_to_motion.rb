class AddCloseDateAndCloseTimeToMotion < ActiveRecord::Migration
  def change
    rename_column :motions, :close_date, :close_at
    add_column :motions, :close_at_date, :date
    add_column :motions, :close_at_time, :string
    add_column :motions, :close_at_time_zone, :string
  end
end

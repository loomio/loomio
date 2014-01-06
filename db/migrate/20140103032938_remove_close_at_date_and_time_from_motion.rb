class RemoveCloseAtDateAndTimeFromMotion < ActiveRecord::Migration
  def up
    remove_column :motions, :close_at_date
    remove_column :motions, :close_at_time
    remove_column :motions, :close_at_time_zone
  end

  def down
    add_column :motions, :close_at_time_zone, :string
    add_column :motions, :close_at_time, :string
    add_column :motions, :close_at_date, :date
  end
end

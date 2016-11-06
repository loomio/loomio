class RemoveMeasurements < ActiveRecord::Migration
  def change
    drop_table :group_measurements
  end
end

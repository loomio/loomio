class AddDefaultVolumeToStances < ActiveRecord::Migration[5.2]
  def change
    change_column :stances, :volume, :integer, default: 2, null: false
  end
end

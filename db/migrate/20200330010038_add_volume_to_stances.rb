class AddVolumeToStances < ActiveRecord::Migration[5.2]
  def change
    add_column :stances, :volume, :integer
  end
end

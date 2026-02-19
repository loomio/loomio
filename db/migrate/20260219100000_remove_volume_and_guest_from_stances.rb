class RemoveVolumeAndGuestFromStances < ActiveRecord::Migration[7.2]
  def change
    remove_index :stances, name: :stances_guests, if_exists: true
    remove_column :stances, :volume, :integer, default: 2, null: false
    remove_column :stances, :guest, :boolean, default: false, null: false
  end
end

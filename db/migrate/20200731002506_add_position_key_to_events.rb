class AddPositionKeyToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :position_key, :string
    add_index :events, :position_key
  end
end

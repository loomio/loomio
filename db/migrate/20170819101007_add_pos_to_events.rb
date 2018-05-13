class AddPosToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :position, :integer, default: 0, null: false
  end
end

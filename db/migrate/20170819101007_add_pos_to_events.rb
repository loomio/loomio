class AddPosToEvents < ActiveRecord::Migration
  def change
    add_column :events, :position, :integer, default: 0, null: false
  end
end

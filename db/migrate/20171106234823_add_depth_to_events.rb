class AddDepthToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :depth, :integer, default: 0, null: false
  end
end

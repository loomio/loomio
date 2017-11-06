class AddDepthToEvents < ActiveRecord::Migration
  def change
    add_column :events, :depth, :integer, default: 0, null: false
  end
end

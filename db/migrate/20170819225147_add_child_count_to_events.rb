class AddChildCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :child_count, :integer, default: 0, null: false
  end
end

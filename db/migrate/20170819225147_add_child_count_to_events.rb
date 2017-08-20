class AddChildCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :child_count, :integer
  end
end

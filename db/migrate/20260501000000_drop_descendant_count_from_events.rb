class DropDescendantCountFromEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :events, :descendant_count, :integer, default: 0, null: false
  end
end

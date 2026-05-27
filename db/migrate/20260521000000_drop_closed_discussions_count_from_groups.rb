class DropClosedDiscussionsCountFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :closed_discussions_count, :integer, default: 0, null: false if column_exists?(:groups, :closed_discussions_count)
  end
end

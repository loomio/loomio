class AddReadItemsCountToDiscussionReader < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :read_items_count, :integer, :default => 0
  end
end

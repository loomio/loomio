class RemoveSalientItemsCount < ActiveRecord::Migration
  def change
    remove_column :discussions, :salient_items_count
  end
end

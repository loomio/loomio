class ChangeReverseOrderToNewestFirst < ActiveRecord::Migration[5.2]
  def change
    rename_column :discussions, :reverse_order, :newest_first
  end
end

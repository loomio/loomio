class RemoveStars < ActiveRecord::Migration
  def change
    remove_column :discussion_readers, :starred, :boolean
  end
end

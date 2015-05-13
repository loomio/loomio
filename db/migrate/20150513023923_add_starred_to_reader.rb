class AddStarredToReader < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :starred, :boolean, default: false, null: false
  end
end

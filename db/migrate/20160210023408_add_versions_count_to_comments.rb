class AddVersionsCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :versions_count, :integer, default: 0
  end
end

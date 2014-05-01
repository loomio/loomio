class AddCategoryIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :category_id, :integer
    add_index :groups, :category_id
  end
end

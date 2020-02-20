class RemoveTypeFromGroups < ActiveRecord::Migration[5.2]
  def change
    remove_column :groups, :type
  end
end

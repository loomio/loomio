class RemoveGroupPrivacy < ActiveRecord::Migration
  def change
    remove_column :groups, :privacy
  end
end

class RemoveCreatorFromGroups < ActiveRecord::Migration
  def up
    remove_column :groups, :creator_id
  end

  def down
    add_column :groups, :creator_id, :integer
  end
end

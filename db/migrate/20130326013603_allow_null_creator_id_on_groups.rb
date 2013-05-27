class AllowNullCreatorIdOnGroups < ActiveRecord::Migration
  def up
    change_column :groups, :creator_id, :integer, null: true
  end

  def down
    change_column :groups, :creator_id, :integer, null: false
  end
end

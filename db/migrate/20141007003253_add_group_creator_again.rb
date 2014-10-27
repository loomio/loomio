class AddGroupCreatorAgain < ActiveRecord::Migration
  def change
    add_column :groups, :creator_id, :int
  end
end

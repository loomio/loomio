class RemoveDefaultFromGroupRequest < ActiveRecord::Migration
  def up
    change_column_default(:group_requests, :cannot_contribute, nil)
  end

  def down
    change_column_default(:group_requests, :cannot_contribute, false)
  end
end

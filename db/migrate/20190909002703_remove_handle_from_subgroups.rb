class RemoveHandleFromSubgroups < ActiveRecord::Migration[5.2]
  def change
    Group.where('parent_id is not null').update_all(handle: nil)
  end
end

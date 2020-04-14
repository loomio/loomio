class RemoveGuestGroups < ActiveRecord::Migration[5.2]
  def change
    Group.where(type: "GuestGroup").delete_all
    remove_column :groups, :type
  end
end

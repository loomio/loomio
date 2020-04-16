class RemoveGuestGroups < ActiveRecord::Migration[5.2]
  def change
    Group.where(type: "GuestGroup").delete_all
  end
end

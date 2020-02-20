class RemoveTypeFromGroups < ActiveRecord::Migration[5.2]
  def change
    Membership.joins(:group).where(:'groups.type' => "GuestGroup").delete_all
    Group.where(type: 'GuestGroup').delete_all
    remove_column :groups, :type, :string
  end
end

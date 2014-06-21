class AddMembersCanEditOwnMotionsToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :members_can_edit_own_motions, :boolean, default: true, null: false
  end
end

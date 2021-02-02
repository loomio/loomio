class AddMembersCanEditPollsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :members_can_edit_polls, :boolean, null: false, default: false
  end
end

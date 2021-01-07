class AddMembersCanInviteGuestsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :members_can_add_guests, :boolean, default: true, null: false
    change_column :groups, :admins_can_edit_user_content, :boolean, default: true, null: false
    remove_column :groups, :motions_can_be_edited
  end
end

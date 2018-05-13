class AddIndexToInvitationsGroupId < ActiveRecord::Migration[4.2]
  def change
    add_index :invitations, :group_id
  end
end

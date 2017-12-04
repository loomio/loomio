class AddIndexToInvitationsGroupId < ActiveRecord::Migration
  def change
    add_index :invitations, :group_id
  end
end

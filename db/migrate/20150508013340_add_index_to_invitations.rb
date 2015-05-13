class AddIndexToInvitations < ActiveRecord::Migration
  def change
    add_index :invitations, [:invitable_type, :invitable_id]
  end
end

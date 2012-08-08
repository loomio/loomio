class AddInviterIdToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :inviter_id, :integer
    add_index :memberships, :inviter_id
  end
end

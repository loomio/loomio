class AddInvitationIdToMembership < ActiveRecord::Migration
  def change
    add_column :memberships, :invitation_id, :integer, null: true, index: true
  end
end

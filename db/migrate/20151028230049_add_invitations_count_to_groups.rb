class AddInvitationsCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :invitations_count, :integer, default: 0, null: false
  end
end

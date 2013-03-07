class RemoveAccessLevelColumnFromInvitations < ActiveRecord::Migration
  def up
    remove_column :invitations, :access_level
  end

  def down
    add_column :invitations, :access_level, :string, default: "member", null: false
  end
end

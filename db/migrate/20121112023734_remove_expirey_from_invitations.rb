class RemoveExpireyFromInvitations < ActiveRecord::Migration
  def up
    remove_column :invitations, :expirey
  end

  def down
    add_column :invitations, :expirey, :datetime
  end
end

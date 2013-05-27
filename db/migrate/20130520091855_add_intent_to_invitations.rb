class AddIntentToInvitations < ActiveRecord::Migration
  def up
    add_column :invitations, :intent, :string
  end

  def down
    remove_column :invitations, :intent
  end
end

class AddSingleUseAttributeToInvitations < ActiveRecord::Migration
  def change
    add_column    :invitations, :single_use, :boolean, default: true, null: false
    remove_column :invitations, :accepted_by_id
    change_column :invitations, :recipient_email, :string, null: true
    change_column :invitations, :inviter_id, :integer, null: true
  end
end

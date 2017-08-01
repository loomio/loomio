class SetInvitationIntentToBeJoinGroup < ActiveRecord::Migration
  def change
    change_column :invitations, :intent, :string, null: false, default: 'join_group'
  end
end

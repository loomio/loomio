class AddIndexToInvitationsRecipientEmail < ActiveRecord::Migration
  def change
    add_index :invitations, :recipient_email
  end
end

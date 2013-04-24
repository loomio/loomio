class RenameInvitationsRecipientEmailToAdminEmail < ActiveRecord::Migration
  def change
    rename_column :invitations, :recipient_email, :admin_email
  end
end

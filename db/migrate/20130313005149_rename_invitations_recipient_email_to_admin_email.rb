class RenameInvitationsRecipientEmailToAdminEmail < ActiveRecord::Migration
  def change
    if table_exists? :invitations
      rename_column :invitations, :recipient_email, :admin_email
    end
  end
end

class DropInvitationsIfItExists < ActiveRecord::Migration[5.1]
  def change
    drop_table :invitations if table_exists? :invitations
  end
end

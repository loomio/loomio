class AddAllowEmailInvitationsToSubscriptions < ActiveRecord::Migration[8.1]
  def up
    add_column :subscriptions, :allow_email_invitations, :boolean, default: true, null: false
    execute <<~SQL
      UPDATE subscriptions
      SET allow_email_invitations = FALSE
      WHERE plan IN ('trial', 'demo')
        AND state IN ('active', 'pending')
        AND (expires_at IS NULL OR expires_at > NOW())
    SQL
  end

  def down
    remove_column :subscriptions, :allow_email_invitations
  end
end

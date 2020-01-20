class ChangeSamlSessionExpiresAtToAColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :saml_session_expires_at, :datetime
    remove_column :memberships, :custom_fields
  end
end

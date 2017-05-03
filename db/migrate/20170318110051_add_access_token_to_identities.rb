class AddAccessTokenToIdentities < ActiveRecord::Migration
  def change
    add_column :omniauth_identities, :access_token, :string, default: ""
    rename_column :omniauth_identities, :provider, :identity_type
  end
end

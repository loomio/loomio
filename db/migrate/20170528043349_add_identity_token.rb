class AddIdentityToken < ActiveRecord::Migration
  def change
    add_column :invitations, :identity_token, :string, null: true
  end
end

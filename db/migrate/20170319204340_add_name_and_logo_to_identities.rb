class AddNameAndLogoToIdentities < ActiveRecord::Migration
  def change
    add_column :omniauth_identities, :logo, :string, null: true
  end
end

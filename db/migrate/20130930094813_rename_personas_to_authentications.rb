class RenamePersonasToAuthentications < ActiveRecord::Migration
  def up
    rename_table :personas, :omniauth_identities
    add_column :omniauth_identities, :provider, :string
    add_column :omniauth_identities, :uid, :string
    add_column :omniauth_identities, :name, :string
    add_index :omniauth_identities, [:provider, :uid]
  end

  def down
    remove_index :omniauth_identities, :column => [:provider, :uid]
    remove_column :omniauth_identities, :name
    remove_column :omniauth_identities, :uid
    remove_column :omniauth_identities, :provider
    rename_table :omniauth_identities, :personas
  end
end

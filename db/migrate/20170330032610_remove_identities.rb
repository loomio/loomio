class RemoveIdentities < ActiveRecord::Migration
  def change
    drop_table :identities
    add_column :omniauth_identities, :custom_fields, :jsonb, default: {}, null: false
  end
end

class ChangePasskeyCredentialPublicKeyToBinary < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        execute "ALTER TABLE passkey_credentials ALTER COLUMN public_key TYPE bytea USING public_key::bytea"
      end

      dir.down do
        execute "ALTER TABLE passkey_credentials ALTER COLUMN public_key TYPE text USING encode(public_key, 'escape')"
      end
    end

    change_column_null :passkey_credentials, :public_key, false
  end
end

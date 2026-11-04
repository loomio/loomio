class CreatePasskeyCredentials < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :webauthn_id, :string
    add_index :users, :webauthn_id, unique: true

    create_table :passkey_credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id, null: false
      t.binary :public_key, null: false
      t.bigint :sign_count, null: false, default: 0
      t.string :name, null: false
      t.jsonb :transports, null: false, default: []
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :passkey_credentials, :external_id, unique: true
  end
end

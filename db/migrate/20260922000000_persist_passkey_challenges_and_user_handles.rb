class PersistPasskeyChallengesAndUserHandles < ActiveRecord::Migration[8.1]
  def up
    add_column :passkey_credentials, :user_handle, :string
    execute <<~SQL.squish
      UPDATE passkey_credentials
      SET user_handle = users.webauthn_id
      FROM users
      WHERE users.id = passkey_credentials.user_id
    SQL
    change_column_null :passkey_credentials, :user_handle, false

    create_table :passkey_challenges do |t|
      t.string :challenge_digest, null: false
      t.string :ceremony, null: false
      t.references :user, foreign_key: { on_delete: :cascade }
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :passkey_challenges, :challenge_digest, unique: true
    add_index :passkey_challenges, :expires_at
  end

  def down
    drop_table :passkey_challenges
    remove_column :passkey_credentials, :user_handle
  end
end

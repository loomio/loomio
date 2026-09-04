class CreateMobileAuthenticationRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :mobile_devices, id: :uuid, default: -> { "public.gen_random_uuid()" } do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :platform, null: false, default: "ios"
      t.integer :protocol_version, null: false, default: 1
      t.uuid :refresh_family_id, null: false, default: -> { "public.gen_random_uuid()" }
      t.datetime :last_seen_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :mobile_devices, %i[user_id revoked_at]
    add_check_constraint :mobile_devices, "protocol_version > 0", name: "mobile_devices_protocol_version"

    create_table :mobile_authorization_codes do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.string :client_id, null: false
      t.string :redirect_uri, null: false
      t.string :code_challenge, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.timestamps
    end
    add_index :mobile_authorization_codes, :token_digest, unique: true
    add_index :mobile_authorization_codes, :expires_at

    create_table :mobile_refresh_tokens do |t|
      t.references :mobile_device, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.references :parent, foreign_key: { to_table: :mobile_refresh_tokens, on_delete: :nullify }
      t.string :token_digest, null: false
      t.uuid :family_id, null: false
      t.datetime :expires_at, null: false
      t.datetime :idle_expires_at, null: false
      t.datetime :consumed_at
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :mobile_refresh_tokens, :token_digest, unique: true
    add_index :mobile_refresh_tokens, %i[family_id revoked_at]

    create_table :mobile_access_tokens do |t|
      t.references :mobile_device, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.text :scopes, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :mobile_access_tokens, :token_digest, unique: true
    add_index :mobile_access_tokens, :expires_at

    create_table :mobile_web_session_tickets do |t|
      t.references :mobile_device, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.timestamps
    end
    add_index :mobile_web_session_tickets, :token_digest, unique: true
    add_index :mobile_web_session_tickets, :expires_at
  end
end

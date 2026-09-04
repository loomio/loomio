class CreateMobilePushRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :mobile_push_registrations do |t|
      t.references :mobile_device, type: :uuid, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.uuid :registration_id, null: false
      t.text :delivery_key_ciphertext, null: false
      t.timestamps
    end
    add_index :mobile_push_registrations, :registration_id, unique: true

    create_table :mobile_relay_authorizations do |t|
      t.references :mobile_device, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.uuid :registration_id, null: false
      t.text :delivery_key_ciphertext, null: false
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.timestamps
    end
    add_index :mobile_relay_authorizations, :token_digest, unique: true
    add_index :mobile_relay_authorizations, :expires_at
  end
end

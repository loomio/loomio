class CreateSolidCableMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :solid_cable_messages do |t|
      t.binary :channel, limit: 1024, null: false
      t.binary :payload, limit: 512.megabytes, null: false
      t.datetime :created_at, null: false
      t.integer :channel_hash, limit: 8, null: false

      t.index :channel
      t.index :channel_hash
      t.index :created_at
    end
  end
end

class AddNotificationEmailHistory < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :notification_deliveries, :email_message_id, :string
    add_column :notification_deliveries, :provider_message_id, :string
    add_index :notification_deliveries, :provider_message_id, algorithm: :concurrently
    add_index :notification_deliveries, :email_message_id, unique: true, algorithm: :concurrently

    create_table :notification_delivery_events do |t|
      t.references :notification_delivery, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false
      t.string :source_key, null: false
      t.datetime :occurred_at, null: false
      t.text :detail
      t.timestamps
    end
    add_index :notification_delivery_events, [ :notification_delivery_id, :source_key ], unique: true,
      name: 'index_notification_delivery_events_on_source'
  end
end

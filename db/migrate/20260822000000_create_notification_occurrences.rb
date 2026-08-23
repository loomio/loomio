class CreateNotificationOccurrences < ActiveRecord::Migration[8.1]
  def change
    # This table is deliberately named for its migration-time role. The legacy
    # notifications table remains untouched and readable by the old application
    # until cutover, when this table takes the final notifications name.
    create_table :notification_occurrences do |t|
      t.integer :actor_id
      t.string :kind, null: false
      t.string :subject_type, null: false
      t.bigint :subject_id, null: false
      t.string :deduplication_key, null: false
      t.jsonb :translation_values, null: false, default: {}
      t.datetime :deliveries_generated_at
      t.integer :recipient_user_ids, array: true, null: false, default: []
      t.integer :recipient_chatbot_ids, array: true, null: false, default: []
      t.text :recipient_message
      t.jsonb :audience_values, null: false, default: {}
      t.timestamps
    end

    add_index :notification_occurrences,
              :deduplication_key,
              unique: true,
              name: "index_notification_occurrences_on_deduplication_key"
    add_index :notification_occurrences,
              :id,
              where: "deliveries_generated_at IS NULL",
              name: "index_notification_occurrences_pending_resolution"
  end
end

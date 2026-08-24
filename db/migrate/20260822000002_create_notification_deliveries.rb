class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  CHANNELS = %w[in_app email push chatbot].freeze
  STATUSES = %w[pending claimed delivered failed cancelled].freeze

  def change
    create_table :notification_deliveries do |t|
      t.references :notification_occurrence,
                   null: false,
                   foreign_key: { on_delete: :cascade }
      t.references :recipient, polymorphic: true, null: false
      t.string :channel, null: false
      t.string :status, null: false, default: "pending"
      t.datetime :available_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :claimed_at
      t.datetime :delivered_at
      t.datetime :last_attempt_at
      t.datetime :next_attempt_at
      t.integer :attempt_count, null: false, default: 0
      t.string :provider_message_id
      t.text :last_error
      t.timestamps
    end

    add_index :notification_deliveries,
              %i[notification_occurrence_id channel recipient_type recipient_id],
              unique: true,
              name: "index_notification_deliveries_on_occurrence_identity"
    add_index :notification_deliveries,
              %i[status available_at],
              name: "index_notification_deliveries_on_status_and_available_at"

    add_check_constraint :notification_deliveries,
                         "channel IN (#{CHANNELS.map { |channel| quote(channel) }.join(', ')})",
                         name: "notification_deliveries_channel"
    add_check_constraint :notification_deliveries,
                         "status IN (#{STATUSES.map { |status| quote(status) }.join(', ')})",
                         name: "notification_deliveries_status"
    add_check_constraint :notification_deliveries,
                         "attempt_count >= 0",
                         name: "notification_deliveries_attempt_count"
  end
end

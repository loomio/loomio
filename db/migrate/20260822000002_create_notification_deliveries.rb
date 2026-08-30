class CreateNotificationDeliveries < ActiveRecord::Migration[8.1]
  CHANNELS = %w[in_app email push chatbot].freeze

  def change
    create_table :notification_deliveries do |t|
      t.references :notification_occurrence,
                   null: false,
                   foreign_key: { on_delete: :cascade }
      t.references :recipient, polymorphic: true, null: false
      t.string :channel, null: false
      t.datetime :delivered_at
      t.timestamps
    end

    add_index :notification_deliveries,
              %i[notification_occurrence_id channel recipient_type recipient_id],
              unique: true,
              name: "index_notification_deliveries_on_occurrence_identity"

    add_check_constraint :notification_deliveries,
                         "channel IN (#{CHANNELS.map { |channel| quote(channel) }.join(', ')})",
                         name: "notification_deliveries_channel"

  end
end

class RemoveNotificationDeliveryRetryState < ActiveRecord::Migration[8.1]
  STATUSES = %w[pending claimed delivered failed cancelled].freeze

  def up
    remove_check_constraint :notification_deliveries,
                            name: "notification_deliveries_attempt_count",
                            if_exists: true
    remove_check_constraint :notification_deliveries,
                            name: "notification_deliveries_status",
                            if_exists: true
    remove_index :notification_deliveries,
                 name: "index_notification_deliveries_on_status_and_available_at",
                 if_exists: true

    remove_column :notification_deliveries, :attempt_count
    remove_column :notification_deliveries, :available_at
    remove_column :notification_deliveries, :claimed_at
    remove_column :notification_deliveries, :last_attempt_at
    remove_column :notification_deliveries, :last_error
    remove_column :notification_deliveries, :next_attempt_at
    remove_column :notification_deliveries, :provider_message_id
    remove_column :notification_deliveries, :status
  end

  def down
    add_column :notification_deliveries, :status, :string, null: false, default: "pending"
    add_column :notification_deliveries, :available_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" }
    add_column :notification_deliveries, :claimed_at, :datetime
    add_column :notification_deliveries, :last_attempt_at, :datetime
    add_column :notification_deliveries, :next_attempt_at, :datetime
    add_column :notification_deliveries, :attempt_count, :integer, null: false, default: 0
    add_column :notification_deliveries, :provider_message_id, :string
    add_column :notification_deliveries, :last_error, :text

    add_index :notification_deliveries,
              %i[status available_at],
              name: "index_notification_deliveries_on_status_and_available_at"
    add_check_constraint :notification_deliveries,
                         "status IN (#{STATUSES.map { |status| quote(status) }.join(', ')})",
                         name: "notification_deliveries_status"
    add_check_constraint :notification_deliveries,
                         "attempt_count >= 0",
                         name: "notification_deliveries_attempt_count"
  end
end

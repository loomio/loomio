class AddNotificationAudienceContext < ActiveRecord::Migration[7.2]
  def change
    add_column :notification_occurrences, :recipient_message, :text, if_not_exists: true
    add_column :notification_occurrences, :audience_values, :jsonb, null: false, default: {}, if_not_exists: true
  end
end

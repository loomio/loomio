class AddNotificationDeliveryTranslationValues < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_deliveries,
               :translation_values,
               :jsonb,
               null: false,
               default: {},
               if_not_exists: true
  end
end

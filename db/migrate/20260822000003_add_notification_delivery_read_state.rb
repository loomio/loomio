class AddNotificationDeliveryReadState < ActiveRecord::Migration[8.1]
  def change
    add_column :notification_deliveries, :viewed_at, :datetime, if_not_exists: true
  end
end

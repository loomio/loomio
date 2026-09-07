class AddSubscriptionServiceProjection < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :billing_service_subscription_id, :string
    add_column :subscriptions, :billing_service_product_id, :string
    add_column :subscriptions, :billing_service_price_point_id, :string
    add_column :subscriptions, :billing_service_updated_at, :datetime
    add_index :subscriptions, :billing_service_subscription_id, unique: true,
      where: "billing_service_subscription_id IS NOT NULL",
      name: "index_subscriptions_on_billing_service_id"

    create_table :subscription_update_receipts do |t|
      t.string :event_id, null: false
      t.string :payload_digest, null: false
      t.references :subscription, foreign_key: true
      t.datetime :processed_at
      t.timestamps

      t.index :event_id, unique: true
    end
  end
end

class CreatePushSubscriptionRemovals < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscription_removals do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :endpoint_digest, null: false
      t.timestamps
    end

    add_index :push_subscription_removals,
              [:user_id, :endpoint_digest],
              unique: true,
              name: "index_push_subscription_removals_on_user_and_endpoint"
  end
end

class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :endpoint, null: false
      t.string :endpoint_digest, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.datetime :expires_at
      t.string :name
      t.string :user_agent
      t.datetime :last_seen_at
      t.datetime :revoked_at
      t.integer :failure_count, null: false, default: 0
      t.timestamps
    end

    add_index :push_subscriptions,
              :endpoint_digest,
              unique: true,
              where: "revoked_at IS NULL",
              name: "index_active_push_subscriptions_on_endpoint_digest"
    add_index :push_subscriptions, %i[user_id revoked_at]
    add_check_constraint :push_subscriptions,
                         "failure_count >= 0",
                         name: "push_subscriptions_failure_count"
  end
end

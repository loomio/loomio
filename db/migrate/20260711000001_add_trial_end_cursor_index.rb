class AddTrialEndCursorIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :subscriptions,
              [:expires_at, :id],
              where: "plan = 'trial' AND expires_at IS NOT NULL",
              name: :index_subscriptions_on_trial_expiry_for_relay,
              algorithm: :concurrently,
              if_not_exists: true
  end
end

class UpdateSubscriptions < ActiveRecord::Migration
  def change
    rename_column :subscriptions, :expires_on, :expires_at
    add_column :subscriptions, :trial_ended_at, :date
    add_column :subscriptions, :activated_at, :date
    add_column :subscriptions, :chargify_subscription_id, :integer
    add_column :subscriptions, :plan, :string
  end
end

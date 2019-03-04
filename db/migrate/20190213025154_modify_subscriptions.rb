class ModifySubscriptions < ActiveRecord::Migration[5.2]
  def change
    remove_column :subscriptions, :kind
    remove_column :subscriptions, :trial_ended_at
    remove_column :subscriptions, :activated_at
    change_column :subscriptions, :plan,           :string, default: "free"
    change_column :subscriptions, :expires_at,     :datetime
    change_column :subscriptions, :payment_method, :string, default: "none"
  end
end

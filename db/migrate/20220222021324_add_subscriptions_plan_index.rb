class AddSubscriptionsPlanIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :subscriptions, :plan
  end
end

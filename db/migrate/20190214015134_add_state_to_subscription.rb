class AddStateToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :state, :string, default: "active", null: false
  end
end

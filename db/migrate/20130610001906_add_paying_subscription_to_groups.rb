class AddPayingSubscriptionToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :paying_subscription, :boolean, default: false, null: false
  end
  def down
    remove_column :groups, :paying_subscription
  end
end

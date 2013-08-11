class RemovePayingSubscriptionFromGroupRequests < ActiveRecord::Migration
  def up
    remove_column :group_requests, :paying_subscription
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

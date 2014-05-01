class AddPayingSubscriptionToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :paying_subscription, :boolean
  end
end

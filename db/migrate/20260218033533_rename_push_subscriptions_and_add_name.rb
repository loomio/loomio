class RenamePushSubscriptionsAndAddName < ActiveRecord::Migration[8.0]
  def change
    rename_table :web_push_subscriptions, :push_subscriptions
    add_column :push_subscriptions, :name, :string
  end
end

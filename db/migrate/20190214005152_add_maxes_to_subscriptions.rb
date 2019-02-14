class AddMaxesToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :max_threads, :integer, default: nil
    add_column :subscriptions, :max_members, :integer, default: nil
    add_column :subscriptions, :max_orgs,    :integer, default: nil
  end
end

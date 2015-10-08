class DropAndRecreateSubscriptions < ActiveRecord::Migration
  def change
    drop_table :subscriptions
    create_table :subscriptions do |t|
      t.string :kind
      t.date :expires_on
    end

    add_index :subscriptions, :kind
    add_column :groups, :subscription_id, :integer
  end
end

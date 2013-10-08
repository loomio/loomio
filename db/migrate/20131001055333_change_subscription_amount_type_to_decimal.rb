class ChangeSubscriptionAmountTypeToDecimal < ActiveRecord::Migration
  def up
    change_column :subscriptions, :amount, :decimal, :precision => 8, :scale => 2
  end

  def down
    change_column :subscriptions, :amount, :integer
  end
end

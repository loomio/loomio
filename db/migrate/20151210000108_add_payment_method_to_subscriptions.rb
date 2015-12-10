class AddPaymentMethodToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :payment_method, :string, null: false, default: 'chargify'
  end
end

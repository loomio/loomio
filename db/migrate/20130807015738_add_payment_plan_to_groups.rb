class AddPaymentPlanToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :payment_plan, :string, default: 'pwyc'
    Group.where("id > 1550").where(paying_subscription: true).update_all(payment_plan: 'subscription')
    remove_column :groups, :paying_subscription
  end

  def down
    remove_column :groups, :payment_plan
  end
end

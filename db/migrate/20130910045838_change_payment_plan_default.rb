class ChangePaymentPlanDefault < ActiveRecord::Migration
  def up
    change_column_default(:groups, :payment_plan, "undetermined")
  end

  def down
  end
end

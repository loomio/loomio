class AddLeadStatusToSubscriptions < ActiveRecord::Migration[7.2]
  def change
    add_column :subscriptions, :lead_status, :string
  end
end

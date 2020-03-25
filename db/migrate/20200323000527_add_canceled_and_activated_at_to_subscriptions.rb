class AddCanceledAndActivatedAtToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :canceled_at, :datetime
    add_column :subscriptions, :activated_at, :datetime
  end
end

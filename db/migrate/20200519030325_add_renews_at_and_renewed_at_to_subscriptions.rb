class AddRenewsAtAndRenewedAtToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :renews_at, :datetime
    add_column :subscriptions, :renewed_at, :datetime
  end
end

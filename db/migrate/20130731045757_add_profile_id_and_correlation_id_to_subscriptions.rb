class AddProfileIdAndCorrelationIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :profile_id, :string
  end
end

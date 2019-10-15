class AddMembersCountToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :members_count, :integer
  end
end

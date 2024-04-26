class AddAllowSubgroupsToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :allow_subgroups, :boolean, default: true, null: false
  end
end

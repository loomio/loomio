class AddIsCommercialToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :is_commercial, :boolean
  end
end

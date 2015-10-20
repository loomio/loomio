class AddCountersToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :motions_count, :integer, default: 0, null: false
  end
end

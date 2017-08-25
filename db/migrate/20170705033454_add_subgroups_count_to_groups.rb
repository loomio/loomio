class AddSubgroupsCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :subgroups_count, :integer, null: false, default: 0
  end
end

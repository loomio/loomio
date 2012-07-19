class AddMembershipsCountToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :memberships_count, :integer, :default => 0, :null => false
    Group.reset_column_information
    Group.all.each do |group|
      group.memberships_count = group.memberships.count
      group.save!
    end
  end
  def down
    remove_column :groups, :memberships_count
  end
end

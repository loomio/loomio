class AddMotionsCount < ActiveRecord::Migration
  def up
    add_column :groups, :motions_count, :integer, :default => 0, :null => false
    Group.reset_column_information
    Group.all.each do |group|
      group.motions_count = group.motions.count
      group.save!
    end
  end
  def down
    remove_column :groups, :motions_count
  end
end

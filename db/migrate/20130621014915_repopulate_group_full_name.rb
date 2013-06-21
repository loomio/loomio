class RepopulateGroupFullName < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'
  end

  def up
    Group.reset_column_information
    Group.where(parent_id: nil).find_each do |group|
      group.full_name = group.name
      group.save!
      group.subgroups.each do |subgroup|
        subgroup.full_name = group.name + " - " + subgroup.name
        subgroup.save!
      end
    end
  end

  def down
  end
end

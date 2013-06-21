class RepopulateGroupFullName < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'
  end

  def up
    Group.where(parent_id: nil).find_each do |group|
      group.full_name = group.name
      group.save(validate: false)
      group.subgroups.each do |subgroup|
        subgroup.full_name = group.name + " - " + subgroup.name
        subgroup.save(validate: false)
      end
    end
  end

  def down
  end
end

class PopulateGroupFullName < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'
    def update_full_names
      update_attribute(:full_name, name)
      subgroups.each do |subgroup|
        subgroup.update_attribute(:full_name, name + " - " + subgroup.name)
      end
    end
  end

  def up
    Group.where(parent_id: nil).find_each do |group|
      group.update_full_names
    end
  end

  def down
  end
end

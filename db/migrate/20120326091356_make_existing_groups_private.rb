class MakeExistingGroupsPrivate < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end
  def up
    Group.all.each do |group|
      group.viewable_by = :members
      group.save
    end
  end

  def down
  end
end

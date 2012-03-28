class MakeExistingGroupsPrivate < ActiveRecord::Migration
  def up
    Group.all.each do |group|
      group.viewable_by = :members
      group.save
    end
  end

  def down
  end
end

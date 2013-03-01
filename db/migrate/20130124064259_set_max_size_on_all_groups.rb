class SetMaxSizeOnAllGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def up
    Group.all.each do |group|
      if group.parent_id == nil
        if group.max_size == nil
          group.max_size = group.memberships_count * 2
          group.max_size = 50 if group.max_size < 50
        end
      else
        group.max_size = nil
      end
      group.save
    end
  end

  def down
  end
end

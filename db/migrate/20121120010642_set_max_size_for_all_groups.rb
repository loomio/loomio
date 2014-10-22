class SetMaxSizeForAllGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def up
    Group.update_all "max_size = (memberships_count * 2)"
    Group.update_all "max_size = 50", "max_size < 50"
  end

  def down
    Group.update_all "max_size = Null"
  end
end

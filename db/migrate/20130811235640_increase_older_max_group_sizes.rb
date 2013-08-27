class IncreaseOlderMaxGroupSizes < ActiveRecord::Migration
  def up
    Group.where('max_size < 300').update_all(max_size: 300)
  end

  def down
  end
end

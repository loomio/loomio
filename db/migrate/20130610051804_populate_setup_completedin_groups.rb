class PopulateSetupCompletedinGroups < ActiveRecord::Migration
  def up
    Group.update_all(:next_steps_completed => true)
  end

  def down
    Group.update_all(:next_steps_completed => false)
  end
end

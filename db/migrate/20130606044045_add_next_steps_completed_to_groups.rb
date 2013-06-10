class AddNextStepsCompletedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :next_steps_completed, :boolean, :default => false, :null => false
  end
end

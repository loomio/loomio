class AddTasksRemind < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :remind, :integer, default: nil
  end
end

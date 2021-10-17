class AddTasksRemind < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :remind, :integer, default: nil
    add_column :tasks, :remind_at, :datetime, default: nil
    add_index :tasks, :done
    add_index :tasks, :remind_at
  end
end

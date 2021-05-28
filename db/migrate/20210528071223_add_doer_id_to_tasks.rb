class AddDoerIdToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :doer_id, :integer
  end
end

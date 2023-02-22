class GroupsChangeNewThreadsMaxDepth < ActiveRecord::Migration[6.1]
  def change
    change_column :groups, :new_threads_max_depth, :integer, default: 3, null: false
    Group.where(new_threads_max_depth: 2).update_all(new_threads_max_depth: 3)
  end
end

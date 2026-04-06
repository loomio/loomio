class RemoveNewThreadsDefaultsFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :new_threads_max_depth, :integer, default: 3, null: false
    remove_column :groups, :new_threads_newest_first, :boolean, default: false, null: false
  end
end

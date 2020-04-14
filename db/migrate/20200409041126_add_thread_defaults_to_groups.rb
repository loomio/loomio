class AddThreadDefaultsToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :new_threads_max_depth, :integer, default: 2, null: false
    add_column :groups, :new_threads_newest_first, :boolean, default: false, null: false
  end
end

class RemoveActivityFromDiscussions < ActiveRecord::Migration
  def up
    remove_column :discussions, :activity
  end

  def down
    add_column :discussions, :activity, :integer
  end
end

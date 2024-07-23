class RemoveDiscussionsPinned < ActiveRecord::Migration[7.0]
  def change
    remove_column :discussions, :pinned, :boolean
  end
end

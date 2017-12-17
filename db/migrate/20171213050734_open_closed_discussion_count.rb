class OpenClosedDiscussionCount < ActiveRecord::Migration
  def change
    add_column :groups, :open_discussions_count, :integer, default: 0, null: false
    add_column :groups, :closed_discussions_count, :integer, default: 0, null: false
    rename_column :discussions, :archived_at, :closed_at
    remove_column :discussions, :is_deleted, :boolean
    remove_column :discussions, :closed, :boolean
  end
end

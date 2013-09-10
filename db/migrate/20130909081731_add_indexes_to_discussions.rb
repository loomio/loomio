class AddIndexesToDiscussions < ActiveRecord::Migration
  def change
    add_index :discussions, [:is_deleted, :id]
    add_index :discussions, [:is_deleted, :group_id]
    add_index :groups, [:archived_at, :id]
    add_index :memberships, [:group_id, :user_id, :archived_at, :access_level], name: 'index_cool_guy'
  end
end

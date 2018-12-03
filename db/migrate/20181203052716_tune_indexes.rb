class TuneIndexes < ActiveRecord::Migration[5.1]
  def change
    remove_index :memberships, name: :active_memberships
    remove_column :memberships, :is_suspended
    add_index    :memberships, ["archived_at"], where: "archived_at IS NULL"
    remove_index :groups, name: :index_groups_on_archived_at
    add_index    :groups, ['archived_at'], name: :index_groups_on_archived_at, where: "archived_at IS NULL"
    add_index    :events, ['parent_id', 'discussion_id'], where: 'discussion_id IS NOT NULL'
    add_index    :groups, :type
  end
end

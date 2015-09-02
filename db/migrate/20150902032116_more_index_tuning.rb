class MoreIndexTuning < ActiveRecord::Migration
  def change
    remove_index :groups, name: "index_groups_on_archived_at_and_id"
    remove_index :discussions, name: "index_discussions_on_is_deleted_and_id"
    remove_index :discussions, name: "index_discussions_on_is_deleted_and_group_id"
  end
end

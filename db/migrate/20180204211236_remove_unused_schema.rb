class RemoveUnusedSchema < ActiveRecord::Migration[5.1]
  def change
    remove_column :discussion_readers, :last_read_sequence_id
    remove_column :discussion_readers, :read_salient_items_count
    remove_column :discussion_readers, :read_items_count
    remove_column :discussions,        :salient_items_count
    remove_column :users,              :angular_ui_enabled

    drop_table :comment_hierarchies if table_exists? :comment_hierarchies
    drop_table :contacts            if table_exists? :contacts
    drop_table :poll_communities    if table_exists? :poll_communities
    drop_table :themes              if table_exists? :themes
  end
end

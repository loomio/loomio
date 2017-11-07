class RemoveDiscussionReaderColumns < ActiveRecord::Migration
  def change
    remove_column :discussion_readers, :last_read_sequence_id
    remove_column :discussion_readers, :read_salient_items_count
  end
end

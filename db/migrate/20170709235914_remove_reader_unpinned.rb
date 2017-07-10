class RemoveReaderUnpinned < ActiveRecord::Migration
  def change
    remove_column :discussion_readers, :reader_unpinned
  end
end

class AddReadSequenceIdRangesToDiscussionReaders < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :read_ranges_string, :string
  end
end

class AddReadSequenceIdRangesToDiscussionReaders < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :read_ranges_string, :string
    exec("update discussion_readers SET read_ranges_string = ('1,' || last_read_sequence_id)")
  end
end

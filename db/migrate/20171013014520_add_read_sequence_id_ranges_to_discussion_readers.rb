class AddReadSequenceIdRangesToDiscussionReaders < ActiveRecord::Migration[4.2]
  def change
    add_column :discussion_readers, :read_ranges_string, :string
    # execute("UPDATE discussion_readers SET read_ranges_string = ('1-' || last_read_sequence_id)")
  end
end

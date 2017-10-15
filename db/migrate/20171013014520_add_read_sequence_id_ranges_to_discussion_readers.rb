class AddReadSequenceIdRangesToDiscussionReaders < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :read_sequence_id_ranges, :string
  end
end

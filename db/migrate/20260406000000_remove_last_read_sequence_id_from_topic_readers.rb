class RemoveLastReadSequenceIdFromTopicReaders < ActiveRecord::Migration[7.0]
  def change
    remove_column :topic_readers, :last_read_sequence_id, :integer, default: 0, null: false
  end
end

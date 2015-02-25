class AddLastSequenceIdToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :last_sequence_id, :integer, default: 0, null: false
    add_column :discussions, :first_sequence_id, :integer, default: 0, null: false
    add_column :discussion_readers, :last_read_sequence_id, :integer, default: 0, null: false
    add_column :discussions, :last_item_at, :datetime
    add_column :discussions, :salient_items_count, :integer, default: 0, null: false
    add_column :discussion_readers, :read_salient_items_count, :integer, default: 0, null: false
    change_column :discussion_readers, :read_comments_count, :integer, default: 0, null: false
  end
end

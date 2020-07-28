class AddIndexesToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_index :discussion_readers, :inviter_id
    add_index :discussion_readers, :accepted_at
    add_index :discussion_readers, :revoked_at
  end
end

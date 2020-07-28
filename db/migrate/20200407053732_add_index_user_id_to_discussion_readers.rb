class AddIndexUserIdToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_index :discussion_readers, :user_id
  end
end

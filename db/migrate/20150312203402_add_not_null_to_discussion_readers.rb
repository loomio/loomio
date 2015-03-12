class AddNotNullToDiscussionReaders < ActiveRecord::Migration
  def change
    change_column :discussion_readers, :user_id, :integer, null: false
    change_column :discussion_readers, :discussion_id, :integer, null: false
  end
end

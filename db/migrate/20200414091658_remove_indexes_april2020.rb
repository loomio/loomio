class RemoveIndexesApril2020 < ActiveRecord::Migration[5.2]
  def change
    remove_index :events, name: :index_events_on_kind
    remove_index :comments, name: :index_comments_on_created_at
    remove_index :comments, name: :index_comments_on_commentable_id
    remove_index :comments, name: :index_comments_on_user_id
    remove_index :comments, name: :index_comments_on_parent_id
    remove_index :discussion_readers, name: :revoked_at_null
    remove_index :discussion_readers, name: :accepted_at_null
    remove_index :discussion_readers, name: :index_discussion_readers_on_inviter_id
    remove_index :discussion_readers, name: :index_discussion_readers_on_user_id
    remove_index :discussion_readers, name: :index_discussion_readers_on_revoked_at
    remove_index :discussion_readers, name: :index_discussion_readers_on_accepted_at
    remove_index :discussion_readers, name: :index_motion_read_logs_on_discussion_id
  end
end

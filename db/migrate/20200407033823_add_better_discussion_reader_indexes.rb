class AddBetterDiscussionReaderIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :discussion_readers, :inviter_id, name: :inviter_id_not_null, where: 'inviter_id IS NOT NULL'
    add_index :discussion_readers, :accepted_at, name: :accepted_at_null, where: 'accepted_at IS NULL'
    add_index :discussion_readers, :revoked_at, name: :revoked_at_null, where: 'revoked_at IS NULL'
  end
end

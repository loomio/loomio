class AddInviterIdToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_column :discussion_readers, :inviter_id, :integer
  end
end

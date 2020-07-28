class AddRevokedAtToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    add_column :discussion_readers, :revoked_at, :datetime
  end
end

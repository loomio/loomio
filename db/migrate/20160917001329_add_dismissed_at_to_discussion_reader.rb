class AddDismissedAtToDiscussionReader < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :dismissed_at, :datetime
  end
end

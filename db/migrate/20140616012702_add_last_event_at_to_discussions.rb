class AddLastEventAtToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :last_activity_at, :datetime
    Discussion.update_all('last_activity_at = last_comment_at')
  end

  def down
    remove_column :discussions, :last_activity_at, :datetime
  end
end

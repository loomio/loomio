class AddLastNonCommentActivityAtToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :last_non_comment_activity_at, :datetime, null: false, default: 8.days.ago
  end
end

class AddLastCommentAtToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :last_comment_at, :datetime

    Discussion.reset_column_information
    Discussion.all.each do |discussion|
      discussion.last_comment_at = discussion.latest_comment_time
      discussion.save(:validate => false)
    end
  end

  def down
    remove_column :discussions, :last_comment_at
  end
end

class AddCommentCountToDiscussions < ActiveRecord::Migration
  def up
    add_column :discussions, :comments_count, :integer, default: 0, null: false
  end

  def down
    remove_column :discussions, :comments_count
  end
end

class ChangeMotionsDiscussionUrlDefault < ActiveRecord::Migration
  def up
    # Motion.update_all(discussion_url: "", discussion_url: nil)
    change_column_null("motions", "discussion_url", false, "")
    change_column_default("motions", "discussion_url", "")
  end
  def down
    change_column_default("motions", "discussion_url", nil)
  end
end

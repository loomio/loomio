class RemoveDiscussionUrlFromMotions < ActiveRecord::Migration
  def up
    remove_column :motions, :discussion_url
  end

  def down
    add_column :motions, :discussion_url, :string
  end
end

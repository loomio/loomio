class AddDiscussionUrlToMotions < ActiveRecord::Migration
  def change
    add_column :motions, :discussion_url, :string
  end
end

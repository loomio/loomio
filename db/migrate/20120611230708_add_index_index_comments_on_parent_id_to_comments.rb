class AddIndexIndexCommentsOnParentIdToComments < ActiveRecord::Migration
  def change
    add_index "comments", ["parent_id"], :name => "index_comments_on_parent_id"
  end
end

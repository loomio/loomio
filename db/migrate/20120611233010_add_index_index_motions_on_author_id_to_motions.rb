class AddIndexIndexMotionsOnAuthorIdToMotions < ActiveRecord::Migration
  def change
    add_index "motions", ["author_id"], :name => "index_motions_on_author_id"
  end
end

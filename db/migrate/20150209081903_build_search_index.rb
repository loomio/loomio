class BuildSearchIndex < ActiveRecord::Migration
  def change
    drop_table :motion_search_vectors
    drop_table :comment_search_vectors
  end
end

class BuildSearchIndex < ActiveRecord::Migration
  def change
    drop_table :motion_search_vectors
    drop_table :comment_search_vectors
    SearchService.rebuild_search_index!
  end
end

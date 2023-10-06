class RemoveDiscussionSearchVectors < ActiveRecord::Migration[7.0]
  def change
    drop_table :discussion_search_vectors
  end
end

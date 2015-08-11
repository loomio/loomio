class AddDiscussionSearchIndex < ActiveRecord::Migration
  def change
    add_index :discussion_search_vectors, :discussion_id
    add_index :users, :deactivated_at
    add_index :discussion_readers, :volume
    add_index :discussion_readers, :starred
    add_index :discussion_readers, :participating
  end
end

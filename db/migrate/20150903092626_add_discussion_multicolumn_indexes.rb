class AddDiscussionMulticolumnIndexes < ActiveRecord::Migration
  def change
    add_index :discussions, [:is_deleted, :archived_at]
    add_index :discussion_readers, [:user_id, :volume]
    add_index :memberships, [:user_id, :volume]
    remove_index :discussions, :last_activity_at
    add_index :discussions, :last_activity_at, order: {last_activity_at: :desc}
    remove_index :events, :sequence_id
    add_index :events, :sequence_id, order: {sequence_id: :asc}
  end
end

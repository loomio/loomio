class RemoveUnneededIndexes202104 < ActiveRecord::Migration[6.0]
  def change
    remove_index :events, name: "index_events_on_discussion_id", column: :discussion_id
    remove_index :memberships, name: "index_memberships_on_group_id", column: :group_id
    remove_index :memberships, name: "index_memberships_on_user_id", column: :user_id
    remove_index :poll_unsubscriptions, name: "index_poll_unsubscriptions_on_poll_id", column: :poll_id
    remove_index :tags, name: "index_tags_on_group_id", column: :group_id
  end
end

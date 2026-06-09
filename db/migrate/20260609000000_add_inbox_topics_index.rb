class AddInboxTopicsIndex < ActiveRecord::Migration[7.1]
  def change
    # Lets Postgres satisfy group_id IN (...) + ORDER BY last_activity_at DESC together
    # instead of scanning all topics ordered by last_activity_at and filtering after.
    add_index :topics, [:group_id, :last_activity_at],
              order: { last_activity_at: :desc },
              where: "discarded_at IS NULL",
              name: "index_topics_on_group_last_activity_inbox"

    # Lets the guest-access arm of the inbox UNION look up a user's guest topic_readers
    # instantly rather than scanning all 130K+ guest rows.
    add_index :topic_readers, [:user_id, :topic_id],
              where: "guest = TRUE",
              name: "index_topic_readers_guest_user_id"
  end
end

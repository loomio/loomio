class AddInactiveOrphanCleanupIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  INDEXES = {
    attachments: %i[user_id],
    comments: %i[user_id discarded_by],
    discussion_templates: %i[author_id discarded_by],
    discussions: %i[discarded_by],
    groups: %i[creator_id],
    memberships: %i[revoker_id],
    notifications: %i[actor_id],
    outcomes: %i[author_id],
    polls: %i[discarded_by],
    stance_receipts: %i[voter_id inviter_id],
    stances: %i[inviter_id revoker_id redactor_id],
    tasks: %i[doer_id],
    topic_readers: %i[user_id revoker_id],
    topics: %i[locker_id discarded_by],
    users: %i[deactivator_id]
  }.freeze

  def up
    INDEXES.each do |table, columns|
      columns.each do |column|
        add_index table, column, algorithm: :concurrently, if_not_exists: true
      end
    end
    add_index :notifications,
              :recipient_user_ids,
              using: :gin,
              algorithm: :concurrently,
              if_not_exists: true
  end

  def down
    remove_index :notifications,
                 :recipient_user_ids,
                 algorithm: :concurrently,
                 if_exists: true
    INDEXES.reverse_each do |table, columns|
      columns.reverse_each do |column|
        remove_index table, column, algorithm: :concurrently, if_exists: true
      end
    end
  end
end

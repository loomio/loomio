# This is lifecycle housekeeping for inactive users, not integrity repair. It
# intentionally destroys users through the normal callback graph.
module InactiveUserCleanupService
  USER_REFERENCES = {
    chatbots: %i[author_id],
    comments: %i[user_id discarded_by],
    demos: %i[author_id],
    discussion_templates: %i[author_id discarded_by],
    discussions: %i[author_id discarded_by],
    topic_items: %i[user_id],
    groups: %i[creator_id],
    member_email_aliases: %i[user_id author_id],
    membership_requests: %i[requestor_id responder_id],
    memberships: %i[user_id inviter_id revoker_id],
    notifications: %i[actor_id],
    outcomes: %i[author_id],
    poll_templates: %i[author_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
    stance_receipts: %i[voter_id inviter_id],
    stances: %i[participant_id inviter_id revoker_id],
    tasks: %i[author_id doer_id],
    tasks_users: %i[user_id],
    topic_readers: %i[user_id inviter_id revoker_id],
    user_deactivation_responses: %i[user_id],
    webhooks: %i[author_id actor_id]
  }.freeze

  def self.destroy_orphan_users
    user_ids = orphan_user_ids

    if user_ids.empty?
      puts "No orphan users to delete"
      return
    end

    User.where(id: user_ids).find_each do |user|
      PaperTrail::Version.where(item_type: "User", item_id: user.id).delete_all
      PgSearch::Document.where(author_id: user.id).delete_all

      PaperTrail.request(enabled: false) { user.destroy! }
    end

    puts "Deleted #{user_ids.size} orphan users" unless Rails.env.test?
  end

  def self.orphan_user_ids(last_sign_in_before: 1.year.ago)
    scope = USER_REFERENCES.reduce(User.where(deactivated_at: nil).where("last_sign_in_at < ?", last_sign_in_before)) do |scope, (table, columns)|
      columns.reduce(scope) do |column_scope, column|
        column_scope.where("NOT EXISTS (SELECT 1 FROM #{table} WHERE #{table}.#{column} = users.id)")
      end
    end
    scope.where(<<~SQL.squish).pluck(:id)
      NOT EXISTS (
        SELECT 1 FROM notification_deliveries
        WHERE notification_deliveries.recipient_type = 'User'
          AND notification_deliveries.recipient_id = users.id
      )
    SQL
  end
end

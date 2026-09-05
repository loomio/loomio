# This is lifecycle housekeeping for inactive users, not integrity repair. It
# intentionally destroys users through the normal callback graph.
module InactiveUserCleanupService
  USER_REFERENCES = {
    attachments: %i[user_id],
    bookmarks: %i[user_id],
    blazer_audits: %i[user_id],
    blazer_checks: %i[creator_id],
    blazer_dashboards: %i[creator_id],
    blazer_queries: %i[creator_id],
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
    omniauth_identities: %i[user_id],
    oauth_access_grants: %i[resource_owner_id],
    oauth_access_tokens: %i[resource_owner_id],
    poll_templates: %i[author_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
    stance_receipts: %i[voter_id inviter_id],
    stances: %i[participant_id inviter_id revoker_id redactor_id],
    subscriptions: %i[owner_id],
    tasks: %i[author_id doer_id],
    tasks_users: %i[user_id],
    topic_readers: %i[user_id inviter_id revoker_id],
    topics: %i[locker_id discarded_by],
    user_deactivation_responses: %i[user_id],
    users: %i[deactivator_id],
    webhooks: %i[author_id actor_id]
  }.freeze

  def self.destroy_orphan_users
    user_ids = orphan_user_ids

    if user_ids.empty?
      puts "No orphan users to delete"
      return
    end

    count = 0
    user_ids.each do |id|
      CleanupService.with_write_lock(USER_REFERENCES.keys + %i[users sessions login_tokens push_subscriptions notification_deliveries notifications oauth_applications active_storage_attachments versions pg_search_documents]) do
        user = orphan_users.where(id: id).first
        next unless user

        PaperTrail::Version.where(item_type: "User", item_id: user.id).delete_all
        PgSearch::Document.where(author_id: user.id).delete_all
        PaperTrail.request(enabled: false) { user.destroy! }
        count += 1
      end
    end

    puts "Deleted #{count} orphan users" unless Rails.env.test?
  end

  def self.orphan_user_ids(inactive_before: 1.year.ago)
    orphan_users(inactive_before: inactive_before).pluck(:id)
  end

  def self.orphan_users(inactive_before: 1.year.ago)
    inactive_users = User.where(is_admin: false).where(
      "GREATEST(created_at, current_sign_in_at, last_sign_in_at, last_seen_at) < :cutoff",
      cutoff: inactive_before
    )
    scope = USER_REFERENCES.reduce(inactive_users) do |scope, (table, columns)|
      columns.reduce(scope) do |column_scope, column|
        column_scope.where("NOT EXISTS (SELECT 1 FROM #{table} cleanup_references WHERE cleanup_references.#{column} = users.id)")
      end
    end
    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM notification_deliveries
        WHERE notification_deliveries.recipient_type = 'User'
          AND notification_deliveries.recipient_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM oauth_applications
        WHERE owner_type = 'User' AND owner_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM active_storage_attachments
        WHERE record_type = 'User' AND record_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM notifications
        WHERE users.id = ANY(recipient_user_ids)
      )
    SQL
  end
end

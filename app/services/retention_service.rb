# Lifecycle retention for groups, subgroups, threads, and inactive accounts.
module RetentionService
  UNUSED_GROUP_DISCARD_LIMIT = 1_000
  INACTIVE_ORPHAN_USER_LIMIT = 1_000
  INACTIVE_ORPHAN_USER_RETENTION = 90.days
  EMPTY_GROUP_SUBSCRIPTION_PLANS = %w[free trial].freeze
  EMPTY_GROUP_RETENTION = 60.days
  EXPIRED_TRIAL_RETENTION = 60.days
  EXPIRED_TRIAL_WARNING_LIMIT = 100
  DISCARDED_GROUP_DESTRUCTION_LIMIT = 500

  USER_REFERENCES = {
    anonymous_poll_voters: %i[voter_id inviter_id],
    bookmarks: %i[user_id],
    chatbots: %i[author_id],
    comments: %i[user_id discarded_by],
    discussion_templates: %i[author_id discarded_by hider_id],
    discussions: %i[author_id discarded_by],
    email_suppressions: %i[cleared_by_id],
    group_follows: %i[user_id],
    topic_items: %i[user_id],
    groups: %i[creator_id],
    member_email_aliases: %i[user_id author_id],
    membership_requests: %i[requestor_id responder_id],
    memberships: %i[user_id inviter_id revoker_id],
    notifications: %i[actor_id],
    outcomes: %i[author_id],
    omniauth_identities: %i[user_id],
    poll_templates: %i[author_id discarded_by hider_id],
    polls: %i[author_id discarded_by],
    reactions: %i[user_id],
    stances: %i[participant_id inviter_id revoker_id redactor_id],
    subscriptions: %i[owner_id],
    tasks: %i[author_id doer_id],
    tasks_users: %i[user_id],
    topic_readers: %i[user_id inviter_id revoker_id],
    topics: %i[locker_id discarded_by],
    users: %i[deactivator_id]
  }.freeze

  # Legacy associations lack foreign keys, so row locks alone cannot exclude
  # new references during destructive eligibility checks. Keep these sections
  # short: skip locks held by existing writers, and release promptly so new
  # writers can proceed. These locks are for maintenance, not request paths.
  def self.with_write_lock(tables)
    ActiveRecord::Base.transaction(requires_new: true) do
      names = tables.map(&:to_s).uniq.sort.map { |table| ActiveRecord::Base.connection.quote_table_name(table) }
      begin
        ActiveRecord::Base.connection.execute("LOCK TABLE #{names.join(', ')} IN SHARE ROW EXCLUSIVE MODE NOWAIT")
      rescue ActiveRecord::LockWaitTimeout => error
        Rails.logger.info("Retention lock deferred: #{error.message}")
        raise ActiveRecord::Rollback
      end
      yield
    end
  end

  # Destroy accounts outside the retention period only when they have no
  # durable association with the application. Administrators are always kept;
  # their removal requires an explicit administrative action.
  def self.destroy_inactive_orphan_users(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago)
    user_ids = inactive_orphan_user_ids(inactive_before: inactive_before)

    return if user_ids.empty?

    count = 0
    user_ids.each do |id|
      with_write_lock(USER_REFERENCES.keys + %i[users sessions login_tokens push_subscriptions notification_deliveries notifications active_storage_attachments versions pg_search_documents]) do
        user = inactive_orphan_users(inactive_before: inactive_before).where(id: id).first
        next unless user

        PaperTrail::Version.where(item_type: "User", item_id: user.id).delete_all
        PgSearch::Document.where(author_id: user.id).delete_all
        PaperTrail.request(enabled: false) { user.destroy! }
        count += 1
      end
    end

    puts "Destroyed #{count} inactive orphan users" if count.positive? && !Rails.env.test?
  end

  def self.inactive_orphan_user_ids(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago, limit: INACTIVE_ORPHAN_USER_LIMIT)
    inactive_orphan_users(inactive_before: inactive_before).order(:id).limit(limit).pluck(:id)
  end

  def self.inactive_orphan_users(inactive_before: INACTIVE_ORPHAN_USER_RETENTION.ago)
    inactive_users = User.where(is_admin: false).where(
      "GREATEST(created_at, current_sign_in_at, last_sign_in_at, last_seen_at) < :cutoff",
      cutoff: inactive_before
    )
    scope = USER_REFERENCES.reduce(inactive_users) do |scope, (table, columns)|
      columns.reduce(scope) do |column_scope, column|
        column_scope.where("NOT EXISTS (SELECT 1 FROM #{table} retention_references WHERE retention_references.#{column} = users.id)")
      end
    end
    scope.where(<<~SQL.squish)
      NOT EXISTS (
        SELECT 1 FROM notification_deliveries
        WHERE notification_deliveries.recipient_type = 'User'
          AND notification_deliveries.recipient_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM active_storage_attachments
        WHERE record_type = 'User' AND record_id = users.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM notifications
        WHERE recipient_user_ids @> ARRAY[users.id]::integer[]
      )
    SQL
  end

  def self.audit_empty_groups(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    validate_empty_group_plan!(plan: plan, limit: limit)
    trees = group_retention_trees(plan: plan, before: before, only_unused: true)
    trees = trees.first(limit).to_h if limit
    {
      plan: plan.to_s,
      before: before.iso8601,
      root_ids: trees.keys,
      group_ids: trees.values.flatten,
      trees: trees
    }
  end

  def self.discard_empty_groups!(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    audit = audit_empty_groups(plan: plan, before: before, limit: limit)
    return { discarded_roots: 0 } if audit[:root_ids].empty?

    # Recheck the candidate trees while writes to their eligibility data are locked.
    with_write_lock(%i[groups subscriptions topics]) do
      trees = group_retention_trees(plan: plan, before: before, only_unused: true, root_ids: audit[:root_ids])
      Group.kept.where(id: trees.values.flatten).update_all(discarded_at: Time.current, discarded_by: nil)
      { discarded_roots: trees.size }
    end || { discarded_roots: 0 }
  end

  def self.discard_unused_trials_and_warn_expired_trials(retention:, now: Time.current)
    discard_empty_groups!(plan: :trial, before: now - retention, limit: UNUSED_GROUP_DISCARD_LIMIT)
    warn_and_discard_expired_trial_groups(now: now, retention: retention)
  end

  def self.warn_and_discard_expired_trial_groups(now: Time.current, retention: EXPIRED_TRIAL_RETENTION)
    before = now - retention
    trees = group_retention_trees(plan: :trial, before: before, only_unused: false)
    # Reserve the first places in each daily batch for newly eligible trials.
    recently_expired = Subscription.sanitize_sql_array([
      "CASE WHEN subscriptions.expires_at > ? THEN 0 ELSE 1 END", before - 1.day
    ])
    group_ids = expired_trial_groups(now: now, retention: retention).where(id: trees.keys)
      .reorder(Arel.sql(recently_expired), "subscriptions.expires_at", :id)
      .limit(EXPIRED_TRIAL_WARNING_LIMIT).pluck(:id)
    group_ids.each do |group_id|
      WarnAndDiscardExpiredTrialGroupWorker.perform_later(group_id, only_unused: false)
    end
    { queued_groups: group_ids.size }
  end

  def self.deletable_discarded_groups(now: Time.current)
    delay_days = AppConfig.discarded_group_deletion_after_days
    return Group.none unless delay_days

    discarded_before = now - delay_days.days
    Group.discarded.parents_only.where(discarded_at: ..discarded_before)
         .where(discarded_group_tree_deletable_sql, cutoff: discarded_before, now: now)
  end

  def self.deletable_discarded_subgroups(now: Time.current)
    delay_days = AppConfig.discarded_subgroup_deletion_after_days
    return Group.none unless delay_days

    discarded_before = now - delay_days.days
    Group.discarded.where.not(parent_id: nil).where(discarded_at: ..discarded_before)
         .where("EXISTS (SELECT 1 FROM groups parent WHERE parent.id = groups.parent_id AND parent.discarded_at IS NULL)")
         .where(discarded_group_tree_deletable_sql, cutoff: discarded_before, now: now)
  end

  def self.deletable_discarded_threads(now: Time.current)
    delay_days = AppConfig.discarded_thread_deletion_after_days
    return Topic.none unless delay_days

    discarded_before = now - delay_days.days
    Topic.where.not(discarded_at: nil).where(discarded_at: ..discarded_before).where(<<~SQL.squish)
      topics.group_id IS NULL OR EXISTS (
        SELECT 1 FROM groups g WHERE g.id = topics.group_id AND g.discarded_at IS NULL
      )
    SQL
  end

  def self.discarded_group_tree_deletable_sql
    <<~SQL.squish
      NOT EXISTS (
        SELECT 1 FROM subscriptions s
        WHERE s.id = groups.subscription_id
          AND (s.chargify_subscription_id IS NOT NULL OR s.billing_service_subscription_id IS NOT NULL)
          AND s.state IN ('active', 'pending', 'past_due', 'on_hold')
          AND (s.expires_at IS NULL OR s.expires_at > :now)
      )
      AND NOT EXISTS (
        SELECT 1 FROM groups child
        WHERE child.parent_id = groups.id
          AND (child.discarded_at IS NULL OR child.discarded_at > :cutoff
               OR (child.subscription_id IS NOT NULL AND child.subscription_id IS DISTINCT FROM groups.subscription_id))
      )
    SQL
  end
  private_class_method :discarded_group_tree_deletable_sql

  def self.destroy_discarded_groups(now: Time.current, root_ids: nil)
    return 0 unless AppConfig.discarded_group_deletion_after_days

    dispatch_destruction_jobs(worker: DestroyGroupWorker, scope: deletable_discarded_groups(now: now), ids: root_ids)
  end

  def self.destroy_discarded_subgroups(now: Time.current, subgroup_ids: nil)
    return 0 unless AppConfig.discarded_subgroup_deletion_after_days

    dispatch_destruction_jobs(worker: DestroyGroupWorker, scope: deletable_discarded_subgroups(now: now), ids: subgroup_ids)
  end

  def self.destroy_discarded_threads(now: Time.current, topic_ids: nil)
    return 0 unless AppConfig.discarded_thread_deletion_after_days

    dispatch_destruction_jobs(worker: DestroyTopicWorker, scope: deletable_discarded_threads(now: now), ids: topic_ids)
  end

  def self.dispatch_destruction_jobs(worker:, scope:, ids: nil)
    SolidQueue::Job.transaction do
      connection = SolidQueue::Job.connection
      next 0 unless connection.select_value("SELECT pg_try_advisory_xact_lock(hashtextextended('loomio_discarded_group_dispatch', 0))")

      pending = SolidQueue::Job.where(queue_name: "group_destruction", finished_at: nil)
      remaining = DISCARDED_GROUP_DESTRUCTION_LIMIT - pending.count
      next 0 unless remaining.positive?

      queued_ids = pending.where(class_name: worker.name).map { |job| job.arguments.fetch("arguments").first }
      records = scope.where.not(id: queued_ids)
      records = records.where(id: ids) if ids
      records.order(:discarded_at, :id).limit(remaining).count do |record|
        worker.perform_later(record.id, record.discarded_at.iso8601(6))
      end
    end
  end
  private_class_method :dispatch_destruction_jobs

  def self.topic_version_record_ids(topic_ids)
    discussions = Discussion.where(topic_id: topic_ids)
    polls = Poll.where(topic_id: topic_ids)
    stances = Stance.where(poll_id: polls.select(:id))
    outcomes = Outcome.where(poll_id: polls.select(:id))
    comment_ids = TopicItem.where(topic_id: topic_ids, itemable_type: "Comment").distinct.pluck(:itemable_id)

    record_ids = { Topic => topic_ids, Comment => comment_ids }
    [discussions, polls, stances, outcomes].each do |scope|
      record_ids[scope.klass] = scope.ids
    end
    record_ids
  end

  def self.delete_destroyed_versions!(record_ids)
    record_ids.each do |model, ids|
      ids.each_slice(1_000) do |batch|
        # Preserve history for any record that survived the cascade. This also
        # includes events filtered out of the normal history view.
        survivors = model.unscoped.where(id: batch).select(:id)
        PaperTrail::Version.where(item_type: model.polymorphic_name, item_id: batch).where.not(item_id: survivors).delete_all
      end
    end
  end

  def self.expired_trial_groups(now: Time.current, retention: EXPIRED_TRIAL_RETENTION)
    Group.kept.parents_only.joins(:subscription)
         .where(subscriptions: { plan: "trial", expires_at: ..(now - retention) })
         .order("subscriptions.expires_at", :id)
  end

  def self.group_retention_trees(plan:, before:, only_unused:, root_ids: nil)
    plan = plan.to_s
    validate_empty_group_plan!(plan: plan)
    lifecycle_condition = case plan
    when "free" then "s.plan = 'free' AND g.created_at <= :before"
    when "trial" then "s.plan = 'trial' AND s.expires_at <= :before"
    end
    root_condition = root_ids.nil? ? "" : Group.sanitize_sql_array(["AND g.id IN (?)", root_ids])
    topic_operator = only_unused ? "NOT EXISTS" : "EXISTS"
    sql = Group.sanitize_sql_array([ <<~SQL, { before: before } ])
      WITH roots AS (
        SELECT g.id, g.subscription_id FROM groups g
        JOIN subscriptions s ON s.id = g.subscription_id
        WHERE g.parent_id IS NULL AND g.discarded_at IS NULL
          AND #{lifecycle_condition} #{root_condition}
          AND s.chargify_subscription_id IS NULL AND s.billing_service_subscription_id IS NULL
          AND NOT EXISTS (SELECT 1 FROM groups other WHERE other.parent_id IS NULL
            AND other.subscription_id = s.id AND other.id != g.id)
      ), tree AS (
        SELECT id AS root_id, id AS group_id FROM roots
        UNION ALL
        SELECT r.id AS root_id, g.id AS group_id FROM roots r JOIN groups g ON g.parent_id = r.id
      ), used_roots AS (
        SELECT t.root_id FROM tree t JOIN topics ON topics.group_id = t.group_id
      ), excluded_roots AS (
        SELECT t.root_id FROM tree t JOIN groups g ON g.id = t.group_id
        JOIN roots r ON r.id = t.root_id
        WHERE g.id != r.id AND g.subscription_id IS NOT NULL AND g.subscription_id != r.subscription_id
      )
      SELECT t.root_id, t.group_id FROM tree t
      WHERE NOT EXISTS (SELECT 1 FROM excluded_roots e WHERE e.root_id = t.root_id)
        AND #{topic_operator} (SELECT 1 FROM used_roots u WHERE u.root_id = t.root_id)
      ORDER BY t.root_id, t.group_id
    SQL
    Group.connection.select_all(sql).to_a.group_by { |row| row["root_id"] }
         .transform_values { |rows| rows.map { |row| row["group_id"] } }
  end

  def self.validate_empty_group_plan!(plan:, limit: nil)
    raise ArgumentError, "plan must be free or trial" unless EMPTY_GROUP_SUBSCRIPTION_PLANS.include?(plan.to_s)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0
  end
end

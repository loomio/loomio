# Soft-discard lifecycle for unused and expired trial groups.
module TrialExpirationService
  UNUSED_GROUP_DISCARD_LIMIT = 1_000
  EMPTY_GROUP_SUBSCRIPTION_PLANS = %w[free trial].freeze
  EMPTY_GROUP_RETENTION = 60.days
  EXPIRED_TRIAL_RETENTION = 60.days
  EXPIRED_TRIAL_WARNING_LIMIT = 100

  def self.audit_empty_groups(plan:, before: EMPTY_GROUP_RETENTION.ago, limit: nil)
    validate_empty_group_plan!(plan: plan, limit: limit)
    trees = eligible_trees(plan: plan, before: before, only_unused: true)
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
    PurgeService.with_write_lock(%i[groups subscriptions topics]) do
      trees = eligible_trees(plan: plan, before: before, only_unused: true, root_ids: audit[:root_ids])
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
    trees = eligible_trees(plan: :trial, before: before, only_unused: false)
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

  def self.expired_trial_groups(now: Time.current, retention: EXPIRED_TRIAL_RETENTION)
    Group.kept.parents_only.joins(:subscription)
         .where(subscriptions: { plan: "trial", expires_at: ..(now - retention) })
         .order("subscriptions.expires_at", :id)
  end

  def self.eligible_trees(plan:, before:, only_unused:, root_ids: nil)
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

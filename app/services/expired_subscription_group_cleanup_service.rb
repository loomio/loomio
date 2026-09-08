# Warns and schedules deletion for root groups whose trial or cancellation has
# been inactive for the retention period. Topic-free expired trials are omitted
# because EmptyTrialCleanupService owns their immediate deletion path.
module ExpiredSubscriptionGroupCleanupService
  RETENTION_PERIOD = 60.days
  REASONS = %w[trial_expired subscription_canceled].freeze
  LIFECYCLE_ORDER_SQL = "CASE WHEN subscriptions.state = 'canceled' " \
                        "THEN subscriptions.canceled_at ELSE subscriptions.expires_at END, groups.id".freeze

  def self.audit(as_of: Time.current, limit: nil)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0

    groups = candidate_groups(as_of: as_of)
    groups = groups.limit(limit) if limit
    entries = groups.map do |group|
      reason = deletion_reason(group.subscription, as_of: as_of)
      {
        group_id: group.id,
        subscription_id: group.subscription_id,
        reason: reason,
        lifecycle_at: lifecycle_at(group.subscription, reason).iso8601,
        usage: GroupUsageSummary.for(group)
      }
    end
    { as_of: as_of.iso8601, retention_days: RETENTION_PERIOD.in_days.to_i, groups: entries }
  end

  def self.warn_and_schedule!(io:, as_of: Time.current, limit: nil)
    plan = audit(as_of: as_of, limit: limit)
    log(io, type: "plan", at: Time.current.iso8601, **plan)
    result = { warned_groups: 0, skipped_groups: 0 }

    plan[:groups].each do |entry|
      group = candidate_groups(as_of: as_of, group_id: entry[:group_id]).first
      reason = group && deletion_reason(group.subscription, as_of: as_of)
      unless group && reason == entry[:reason]
        result[:skipped_groups] += 1
        log(io, type: "skipped", group_id: entry[:group_id], reason: "no longer eligible")
        next
      end

      GroupService.warn_then_destroy_subscription(group: group, reason: reason)
      result[:warned_groups] += 1
      log(io, type: "warned", at: Time.current.iso8601, **entry)
    end

    log(io, type: "complete", at: Time.current.iso8601, **result)
    result
  rescue StandardError => error
    log(io, type: "failed", at: Time.current.iso8601, error: error.class.name, message: error.message)
    raise
  end

  def self.candidate_groups(as_of:, group_id: nil)
    cutoff = as_of - RETENTION_PERIOD
    expired_trials = Subscription.where(plan: "trial", expires_at: ..cutoff)
    old_cancellations = Subscription.where(state: "canceled", canceled_at: ..cutoff)
    empty_trial_ids = EmptyTrialCleanupService.candidate_trees(expires_before: cutoff).keys

    scope = Group.kept.parents_only.joins(:subscription)
                 .merge(expired_trials.or(old_cancellations))
                 .where.not(id: empty_trial_ids)
                 .order(Arel.sql(LIFECYCLE_ORDER_SQL))
    group_id ? scope.where(id: group_id) : scope
  end

  def self.deletion_reason(subscription, as_of:)
    return nil unless subscription

    cutoff = as_of - RETENTION_PERIOD
    return "subscription_canceled" if subscription.state == "canceled" && subscription.canceled_at && subscription.canceled_at <= cutoff
    return "trial_expired" if subscription.plan == "trial" && subscription.expires_at && subscription.expires_at <= cutoff

    nil
  end

  def self.lifecycle_at(subscription, reason)
    reason == "subscription_canceled" ? subscription.canceled_at : subscription.expires_at
  end

  def self.log(io, entry)
    io.puts(entry.to_json)
    io.flush
  end

  private_class_method :lifecycle_at, :log
end

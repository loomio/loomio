# Cleans up root groups whose trial expired before the retention cutoff.
# Topic-free trees are deleted immediately. Groups containing topics are
# warned and discarded, leaving permanent deletion to a later incineration
# process.
module TrialGroupCleanupService
  RETENTION_PERIOD = 60.days
  REASON = "trial_expired"

  def self.run!(io:, as_of: Time.current, warning_limit:)
    cutoff = as_of - RETENTION_PERIOD
    deleted = EmptyGroupCleanupService.delete!(cohort: :trial, io: io, before: cutoff)
    warned = warn!(io: io, as_of: as_of, limit: warning_limit)
    { deleted: deleted, warned: warned }
  end

  def self.audit(as_of: Time.current, limit: nil)
    raise ArgumentError, "limit must be positive" if limit && limit <= 0

    groups = candidate_groups(as_of: as_of)
    groups = groups.limit(limit) if limit
    entries = groups.map do |group|
      {
        group_id: group.id,
        subscription_id: group.subscription_id,
        reason: REASON,
        lifecycle_at: group.subscription.expires_at.iso8601,
        usage: GroupUsageSummary.for(group)
      }
    end
    { as_of: as_of.iso8601, retention_days: RETENTION_PERIOD.in_days.to_i, groups: entries }
  end

  def self.warn!(io:, as_of: Time.current, limit: nil)
    plan = audit(as_of: as_of, limit: limit)
    log(io, type: "plan", at: Time.current.iso8601, **plan)
    result = { warned_groups: 0, skipped_groups: 0 }

    plan[:groups].each do |entry|
      group = candidate_groups(as_of: as_of, group_id: entry[:group_id]).first
      unless group
        result[:skipped_groups] += 1
        log(io, type: "skipped", group_id: entry[:group_id], reason: "no longer eligible")
        next
      end

      GroupService.warn_and_discard_expired_trial(group: group)
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
    empty_trial_ids = EmptyGroupCleanupService.candidate_trees(cohort: :trial, before: cutoff).keys
    eligible_trial_ids = EmptyGroupCleanupService.eligible_trees(cohort: :trial, before: cutoff).keys

    scope = Group.kept.parents_only.joins(:subscription)
                 .merge(expired_trials)
                 .where(id: eligible_trial_ids)
                 .where.not(id: empty_trial_ids)
                 .order("subscriptions.expires_at", :id)
    group_id ? scope.where(id: group_id) : scope
  end

  def self.deletion_reason(subscription, as_of:)
    return nil unless subscription

    cutoff = as_of - RETENTION_PERIOD
    return REASON if subscription.plan == "trial" && subscription.expires_at && subscription.expires_at <= cutoff

    nil
  end

  def self.log(io, entry)
    io.puts(entry.to_json)
    io.flush
  end

  private_class_method :log
end

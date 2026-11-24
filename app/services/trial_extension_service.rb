# Extends a hosted free trial to 30 days and unlocks Pro features (subgroups
# and guests) once 3 distinct accepted organisation members have voted in a
# proposal or poll.
class TrialExtensionService
  REQUIRED_PARTICIPANTS = 3
  EXTENDED_TRIAL_DAYS = 30

  def self.check!(group)
    return false unless AppConfig.app_features[:subscriptions] && group.present?

    root = group.parent_or_self
    subscription = root.subscription
    return false unless eligible?(subscription)
    return false unless participants_count(root) >= REQUIRED_PARTICIPANTS

    extended = false
    subscription.with_lock do
      next unless eligible?(subscription)

      extended_until = [ subscription.expires_at, Time.current ].compact.max + EXTENDED_TRIAL_DAYS.days
      subscription.update!(
        expires_at: extended_until,
        allow_subgroups: true,
        allow_guests: true,
        trial_extended_at: Time.current
      )
      extended = true
    end

    return false unless extended

    MessageChannelService.publish_models([ root.reload ], group_id: root.id)
    Sentry.metrics.count("trial.extended")
    true
  end

  # Counts distinct accepted organisation members (capped at REQUIRED_PARTICIPANTS)
  # who have cast a stance or submitted an anonymous ballot in any kept poll
  # within the organisation.
  def self.participants_count(group)
    return 0 unless group.present?

    root = group.parent_or_self
    group_ids = root.id_and_subgroup_ids
    return 0 if group_ids.empty?

    member_ids = Membership.active.accepted.where(group_id: group_ids).select(:user_id)
    scopes = [
      Stance.latest.where(revoked_at: nil).where.not(cast_at: nil)
        .joins(poll: :topic)
        .where(polls: { discarded_at: nil }, topics: { group_id: group_ids }, participant_id: member_ids)
        .select("stances.participant_id AS participant_id"),
      AnonymousPollVoter.where(ballot_submitted: true)
        .joins(poll: :topic)
        .where(polls: { discarded_at: nil }, topics: { group_id: group_ids }, voter_id: member_ids)
        .select("anonymous_poll_voters.voter_id AS participant_id")
    ]

    sql = "SELECT COUNT(*) FROM (#{scopes.map(&:to_sql).join(' UNION ')} LIMIT #{REQUIRED_PARTICIPANTS}) participants"
    ApplicationRecord.connection.select_value(sql).to_i
  end

  def self.eligible?(subscription)
    subscription.present? && subscription.trial? && subscription.is_active? && subscription.trial_extended_at.nil?
  end
  private_class_method :eligible?
end

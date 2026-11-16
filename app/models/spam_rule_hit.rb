class SpamRuleHit < ApplicationRecord
  belongs_to :spam_rule
  ACTIONS = %w[signup sign_in access invitation email content].freeze

  # Atomic minute totals retain activity without storing addresses or one row
  # per blocked attempt. Counters survive concurrent requests and cache resets.
  def self.record!(rule_id:, action:, count: 1, at: Time.current)
    raise ArgumentError, 'Unknown spam action' unless ACTIONS.include?(action)
    upsert_all([
      { spam_rule_id: rule_id, action: action, bucket_at: at.beginning_of_minute, count: count, last_matched_at: at }
    ], unique_by: [ :spam_rule_id, :action, :bucket_at ], on_duplicate: Arel.sql(
      'count = spam_rule_hits.count + EXCLUDED.count, last_matched_at = GREATEST(spam_rule_hits.last_matched_at, EXCLUDED.last_matched_at)'
    ))
  end

  def self.purge_expired!
    where('bucket_at < ?', 30.days.ago.beginning_of_minute).in_batches.delete_all
  end

  def self.activity(rule_ids, now: Time.current)
    where(spam_rule_id: rule_ids).where('bucket_at >= ?', (now - 30.days).beginning_of_minute)
      .group(:spam_rule_id, :action).pluck(:spam_rule_id, :action,
        Arel.sql(sanitize_sql_array([ 'COALESCE(SUM(count) FILTER (WHERE bucket_at >= ?), 0)', (now - 1.hour).beginning_of_minute ])),
        Arel.sql(sanitize_sql_array([ 'COALESCE(SUM(count) FILTER (WHERE bucket_at >= ?), 0)', (now - 24.hours).beginning_of_minute ])),
        Arel.sql('SUM(count)'), Arel.sql('MAX(last_matched_at)')).group_by(&:first)
  end
end

class SpamRules
  class Denied < StandardError; end

  class Context < ActiveSupport::CurrentAttributes
    attribute :running, :rules, :hits
  end

  # Share one fresh rule snapshot per HTTP request/job. Flush metrics after
  # domain transactions finish so rejected operations still appear in totals.
  def self.with_context
    return yield if Context.running
    pending_hits = {}
    Context.set(running: true, rules: nil, hits: pending_hits) do
      begin
        yield
      ensure
        # Some workers reset all CurrentAttributes before returning. Retain
        # this operation's counters independently of that framework reset.
        pending_hits.values.group_by { |rule_id, action, at| [ rule_id, action, at.beginning_of_minute ] }.each do |(rule_id, action, _minute), hits|
          SpamRuleHit.record!(rule_id: rule_id, action: action, count: hits.length, at: hits.map(&:last).max)
        rescue ActiveRecord::ActiveRecordError => error
          Rails.logger.error("spam activity recording failed: #{error.class}")
        end
      end
    end
  end

  def self.rules
    return SpamRule.active.order(:id).to_a unless Context.running
    Context.rules ||= SpamRule.active.order(:id).to_a
  end

  def self.blocked?(value, target:, action:)
    return false if value.blank?
    matches = rules.select { |rule| rule.active? && rule.matches?(value, target: target) }
    matches.each do |rule|
      # Validation may check both a name and an email more than once. Signup,
      # sign-in and access count once per rule per operation; batch invitations
      # and mail count each blocked address once.
      subject = value.to_s.downcase if %w[invitation email].include?(action)
      key = [ rule.id, action, subject ]
      if Context.running
        Context.hits[key] ||= [ rule.id, action, Time.current ]
      else
        SpamRuleHit.record!(rule_id: rule.id, action: action)
      end
    end
    matches.any?
  end

  def self.authorize_email!(email, action:)
    raise Denied if blocked?(email, target: :email, action: action)
  end
end

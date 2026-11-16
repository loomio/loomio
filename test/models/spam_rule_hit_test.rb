require 'test_helper'

class SpamRuleHitTest < ActiveSupport::TestCase
  test 'minute buckets yield separate hour day and month totals by action' do
    freeze_time
    rule = spam_rules(:legacy_regex)
    [ [ 10.minutes.ago, 2 ], [ 2.hours.ago, 3 ], [ 2.days.ago, 4 ], [ 31.days.ago, 100 ] ].each do |at, count|
      SpamRuleHit.record!(rule_id: rule.id, action: 'access', count: count, at: at)
    end
    SpamRuleHit.record!(rule_id: rule.id, action: 'signup', count: 6)
    rows = SpamRuleHit.activity([ rule.id ]).fetch(rule.id)
    assert_equal [ 2, 5, 9 ], rows.find { |row| row[1] == 'access' }.slice(2, 3)
    assert_equal [ 6, 6, 6 ], rows.find { |row| row[1] == 'signup' }.slice(2, 3)
    assert_equal 10.minutes.ago, rows.find { |row| row[1] == 'access' }.last
    assert_equal 2, rows.length
  end

  test 'increments share a bucket and do not move last matched time backwards' do
    rule = spam_rules(:legacy_regex)
    at = Time.current.beginning_of_minute + 40.seconds
    SpamRuleHit.record!(rule_id: rule.id, action: 'access', at: at)
    SpamRuleHit.record!(rule_id: rule.id, action: 'access', at: at - 10.seconds)
    hit = rule.hits.sole
    assert_equal 2, hit.count
    assert_equal at, hit.last_matched_at
    assert_equal at.beginning_of_minute, hit.bucket_at
  end

  test 'expired metric buckets are removed without deleting rules' do
    freeze_time
    rule = spam_rules(:legacy_regex)
    SpamRuleHit.record!(rule_id: rule.id, action: 'email', at: 31.days.ago)
    SpamRuleHit.record!(rule_id: rule.id, action: 'email', at: 1.day.ago)
    SpamRuleHit.purge_expired!
    assert_equal 1, rule.hits.count
    assert SpamRule.exists?(rule.id)
  end
end

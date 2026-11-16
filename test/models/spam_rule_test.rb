require 'test_helper'

class SpamRuleTest < ActiveSupport::TestCase
  test 'domains are normalized and only match complete email domains' do
    rule = SpamRule.create!(kind: 'email_domain', pattern: ' Example.COM ')
    assert_equal 'example.com', rule.pattern
    assert rule.matches?('USER@EXAMPLE.COM', target: :email)
    %w[user@sub.example.com user@notexample.com user@example.com.evil example.com].each do |value|
      assert_not rule.matches?(value, target: :email), value
    end
    assert_not rule.matches?('user@example.com', target: :content)
  end

  test 'IP rules cover individual addresses networks IPv6 and mapped addresses' do
    ipv4 = SpamRule.new(kind: 'ip', pattern: '198.51.100.0/24')
    assert ipv4.valid?
    assert ipv4.matches?('198.51.100.7', target: :ip)
    assert ipv4.matches?('::ffff:198.51.100.7', target: :ip)
    assert_not ipv4.matches?('198.51.101.7', target: :ip)
    assert_not ipv4.matches?('198.51.100.7', target: :content)
    assert_not ipv4.matches?('bad-address', target: :ip)
    ipv6 = SpamRule.new(kind: 'ip', pattern: '2001:db8::/32')
    assert ipv6.matches?('2001:db8::1234', target: :ip)
    assert_not ipv6.matches?('2001:db9::1', target: :ip)
  end

  test 'invalid kinds regexes addresses domains and expiry cannot be saved' do
    [ [ 'unknown', 'test' ], [ 'ip', 'not-an-ip' ], [ 'ip', '198.51.100.0/33' ],
     [ 'regex', '[' ], [ 'email_domain', '@example.com' ], [ 'email_domain', 'example..com' ],
     [ 'email_domain', '*.example.com' ], [ 'email_domain', '-example.com' ] ].each do |kind, pattern|
      rule = SpamRule.new(kind: kind, pattern: pattern)
      assert_not rule.valid?, "#{kind}: #{pattern}"
    end
    assert_not SpamRule.new(kind: 'regex', pattern: 'valid', expires_at: 'not-a-date').valid?
  end

  test 'expiry and discard govern both active query and predicate' do
    rule = SpamRule.create!(kind: 'regex', pattern: 'blocked')
    assert rule.active?
    assert_includes SpamRule.active, rule
    rule.update!(expires_at: Time.current)
    assert_not rule.active?
    assert_not_includes SpamRule.active, rule
    rule.update!(expires_at: 1.day.from_now)
    rule.discard!
    assert_not rule.active?
    rule.undiscard!
    assert rule.active?
  end

  test 'legacy regexes retain email and model text validation' do
    rule = spam_rules(:legacy_regex)
    assert rule.matches?('someone@DIIDE.COM', target: :email)
    assert rule.matches?('About diide.com', target: :content)
    assert_not User.new(email: 'someone@diide.com').valid?
    group = Group.new(name: 'About diide.com')
    assert_not group.valid?
    assert_includes group.errors[:name], 'no spam'
    poll = Poll.new(title: 'About diide.com')
    assert_not poll.valid?
    assert_includes poll.errors[:title], 'no spam'
  end

  test 'regex matching is case insensitive and bounded by a timeout' do
    rule = SpamRule.new(kind: 'regex', pattern: 'SHADY')
    assert rule.matches?('shady sender', target: :content)
    slow = Object.new
    slow.define_singleton_method(:match?) { |_value| raise Regexp::TimeoutError }
    Regexp.stub(:new, slow) { assert rule.matches?('shady sender', target: :content) }
    assert_includes rule.match_error, 'timed out'
  end
end

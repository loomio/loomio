require 'test_helper'

class SpamRulesTest < ActiveSupport::TestCase
  setup do
    @rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
  end

  test 'a new request snapshot sees edits expiry and disables without restarting' do
    SpamRules.with_context { assert SpamRules.blocked?('a@blocked.example', target: :email, action: 'access') }
    @rule.update!(pattern: 'other.example')
    SpamRules.with_context do
      assert_not SpamRules.blocked?('a@blocked.example', target: :email, action: 'access')
      assert SpamRules.blocked?('a@other.example', target: :email, action: 'access')
    end
    @rule.discard!
    SpamRules.with_context { assert_not SpamRules.blocked?('a@other.example', target: :email, action: 'access') }
  end

  test 'repeated checks are deduplicated within an operation and fresh actions count again' do
    SpamRules.with_context do
      3.times { assert SpamRules.blocked?('a@blocked.example', target: :email, action: 'signup') }
      assert SpamRules.blocked?('b@blocked.example', target: :email, action: 'signup')
      SpamRules.with_context { assert SpamRules.blocked?('a@blocked.example', target: :email, action: 'signup') }
    end
    assert_equal 1, @rule.hits.sum(:count)
    SpamRules.with_context { SpamRules.blocked?('a@blocked.example', target: :email, action: 'signup') }
    assert_equal 2, @rule.hits.sum(:count)
  end

  test 'an attempted operation is counted even when domain changes roll back' do
    assert_no_difference 'User.count' do
      SpamRules.with_context do
        User.transaction do
          User.create!(email: 'unrelated@example.com')
          SpamRules.authorize_email!('a@blocked.example', action: 'sign_in')
        end
      rescue SpamRules::Denied
        # The guard fails the whole operation; its activity survives rollback.
      end
    end
    assert_equal 1, @rule.hits.where(action: 'sign_in').sum(:count)
    assert_nil SpamRules::Context.running
  end

  test 'allowed traffic and testing a rule do not create activity' do
    assert_no_difference 'SpamRuleHit.count' do
      SpamRules.with_context { assert_not SpamRules.blocked?('a@example.com', target: :email, action: 'access') }
      assert @rule.matches?('a@blocked.example', target: :email)
    end
  end

  test 'worker current-attribute resets do not lose pending activity or break completion' do
    SpamRules.with_context do
      assert SpamRules.blocked?('a@blocked.example', target: :email, action: 'access')
      SpamRules::Context.reset
    end
    assert_equal 1, @rule.hits.where(action: 'access').sum(:count)
    assert_nil SpamRules::Context.running
  end

  test 'all matching active rules receive activity without double counting' do
    other = SpamRule.create!(kind: 'regex', pattern: '@blocked\\.example\\z')
    inactive = SpamRule.create!(kind: 'regex', pattern: 'blocked', expires_at: 1.minute.ago)
    SpamRules.with_context { SpamRules.blocked?('a@blocked.example', target: :email, action: 'access') }
    assert_equal 1, @rule.hits.sum(:count)
    assert_equal 1, other.hits.sum(:count)
    assert_equal 0, inactive.hits.sum(:count)
  end

  test 'one rule query is shared by repeated checks in the same operation' do
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_event, _start, _finish, _id, payload|
      queries << payload[:sql] if payload[:sql].start_with?('SELECT') && payload[:sql].include?('"spam_rules"')
    end
    SpamRules.with_context { 20.times { SpamRules.blocked?('a@example.com', target: :email, action: 'access') } }
    assert_equal 1, queries.length
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test 'SSO linkage rejects a banned address without creating a user or identity' do
    assert_no_difference [ 'User.count', 'Identity.count' ] do
      assert_raises(SpamRules::Denied) do
        IdentityService.link_or_create(identity_params: { email: 'person@blocked.example', name: 'A person',
          uid: 'blocked-sso', identity_type: 'google' }, current_user: nil)
      end
    end
  end

  test 'activity in a long operation keeps the time each block actually happened' do
    freeze_time do
      first_at = Time.current
      SpamRules.with_context do
        SpamRules.blocked?('first@blocked.example', target: :email, action: 'email')
        travel 2.hours
        SpamRules.blocked?('second@blocked.example', target: :email, action: 'email')
      end
      hits = @rule.hits.order(:bucket_at)
      assert_equal [ first_at.beginning_of_minute, Time.current.beginning_of_minute ], hits.pluck(:bucket_at)
      assert_equal [ first_at, Time.current ], hits.pluck(:last_matched_at)
    end
  end
end

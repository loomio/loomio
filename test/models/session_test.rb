require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  setup do
    @retention_before = ENV.delete('LOOMIO_SESSION_RETENTION_DAYS')
  end

  teardown do
    @retention_before.nil? ? ENV.delete('LOOMIO_SESSION_RETENTION_DAYS') : ENV['LOOMIO_SESSION_RETENTION_DAYS'] = @retention_before
  end

  test 'revocation retains the session metadata and immediately removes push credentials' do
    user = users(:member_loud)
    record = user.sessions.create!(ip_address: '192.0.2.1', user_agent: 'Test browser', created_at: 90.days.ago)
    started_at = record.created_at
    subscription = create_push_subscription(user: user, session: record,
      endpoint: 'https://fcm.googleapis.com/fcm/send/revoked-session', p256dh_key: 'key', auth_key: 'auth')

    freeze_time do
      assert_no_difference 'Session.count' do
        record.revoke!
      end
      assert_equal Time.current, record.reload.revoked_at
      assert_equal user.id, record.user_id
      assert_equal '192.0.2.1', record.ip_address
      assert_equal 'Test browser', record.user_agent
      assert_equal started_at, record.created_at
      refute record.active?
      refute Session.active.exists?(record.id)
      refute PushSubscription.exists?(subscription.id)
    end
  end

  test 'repeated revocation preserves the original logout time' do
    record = users(:member_loud).sessions.create!
    record.revoke!
    revoked_at = record.revoked_at

    travel 1.day do
      record.revoke!
      assert_equal revoked_at, record.reload.revoked_at
    end
  end

  test 'purging uses revocation time and never expires an active session' do
    freeze_time do
      user = users(:member_loud)
      expired = user.sessions.create!(created_at: 100.days.ago, revoked_at: 60.days.ago)
      retained = user.sessions.create!(created_at: 100.days.ago, revoked_at: 59.days.ago)
      active = user.sessions.create!(created_at: 100.days.ago)

      assert_difference 'Session.count', -1 do
        Session.purge_revoked!
      end
      refute Session.exists?(expired.id)
      assert Session.exists?(retained.id)
      assert active.reload.active?
    end
  end

  test 'retention setting changes purge timing and zero purges only revoked sessions' do
    user = users(:member_loud)
    record = user.sessions.create!(revoked_at: 3.days.ago)
    active = user.sessions.create!
    ENV['LOOMIO_SESSION_RETENTION_DAYS'] = '2'
    Session.purge_revoked!
    refute Session.exists?(record.id)

    record = user.sessions.create!
    record.revoke!
    ENV['LOOMIO_SESSION_RETENTION_DAYS'] = '0'
    Session.purge_revoked!
    refute Session.exists?(record.id)
    assert active.reload.active?
  end

  test 'a retained session cannot register, reconcile or revoke push credentials' do
    user = users(:member_loud)
    record = user.sessions.create!
    stale = Session.find(record.id)
    record.revoke!
    params = { endpoint: 'https://fcm.googleapis.com/fcm/send/stale-session', p256dh_key: 'key', auth_key: 'auth' }

    assert_raises(ActiveRecord::RecordNotFound) do
      PushSubscriptionService.create_or_update!(session: stale, params: params, user_agent: 'Stale browser')
    end
    assert_raises(ActiveRecord::RecordNotFound) do
      PushSubscriptionService.reconcile!(session: stale, params: params, user_agent: 'Stale browser')
    end
    assert_raises(ActiveRecord::RecordNotFound) do
      PushSubscriptionService.revoke!(session: stale, id: 0)
    end
    assert_empty record.push_subscriptions
  end

  test 'push delivery excludes subscriptions linked to a revoked session' do
    user = users(:member_loud)
    record = user.sessions.create!
    subscription = create_push_subscription(user: user, session: record,
      endpoint: 'https://fcm.googleapis.com/fcm/send/inactive-session', p256dh_key: 'key', auth_key: 'auth')
    record.update!(revoked_at: Time.current)

    refute PushSubscription.active.exists?(subscription.id)
    refute subscription.reload.active?
  end

  test 'permanent account deletion removes both active and retained sessions' do
    user = User.create!(name: 'Session user', email: 'retained-session@example.com')
    active = user.sessions.create!
    revoked = user.sessions.create!(revoked_at: 1.day.ago)

    assert_difference 'Session.count', -2 do
      user.destroy!
    end
    refute Session.exists?(active.id)
    refute Session.exists?(revoked.id)
  end
end

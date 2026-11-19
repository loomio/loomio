require 'test_helper'

class TrialInvitationLimitTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @billing_env = ENV.slice('CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS')
    ENV.delete('CHARGIFY_API_KEY')
    ENV['LOOMIO_SUBSCRIPTIONS'] = 'enabled'
    Current.reset
    Current.request_ip = '198.51.100.25'
    @actor, @group = trial('first')
    @other, @other_group = trial('second')
    @subject = topic_items(:discussion_created_topic_item)
    @ids = Array.new(51) { |i| User.create!(email: "ip-recipient-#{i}@example.com").id }
    clear_enqueued_jobs
  end

  teardown do
    Current.reset
    %w[CHARGIFY_API_KEY LOOMIO_SUBSCRIPTIONS].each do |key|
      @billing_env.key?(key) ? ENV[key] = @billing_env[key] : ENV.delete(key)
    end
  end

  test 'trial accounts at the same IP share ten recipients and cannot queue the eleventh' do
    notify(@actor, @ids.first(5))
    notify(@other, @ids.slice(5, 5))

    assert_no_difference [ 'Notification.count', 'TrialInvitationRecipient.count' ] do
      assert_no_enqueued_jobs only: RouteNotificationDeliveriesWorker do
        assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
      end
    end
  end

  test 'repeat recipients count once across accounts and repeated invitations update their row' do
    notify(@actor, @ids.first(10))
    3.times { notify(@other, [ @ids.first ]) }
    assert_equal 11, TrialInvitationRecipient.count
    assert_equal 10, TrialInvitationRecipient.distinct.count(:recipient_id)
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'separate IPs have separate allowances' do
    notify(@actor, @ids.first(10))
    Current.request_ip = '198.51.100.26'
    notify(@other, @ids.slice(10, 10))
    assert_equal 20, TrialInvitationRecipient.count
  end

  test 'IPv4 mapped IPv6 addresses share the IPv4 allowance' do
    notify(@actor, @ids.first(10))
    Current.request_ip = '::ffff:198.51.100.25'
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'equivalent IPv6 spellings share one allowance' do
    Current.request_ip = '2001:0db8:0000:0000:0000:0000:0000:0001'
    notify(@actor, @ids.first(10))
    Current.request_ip = '2001:db8::1'
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'the shared allowance expires after a rolling day without waiting for cleanup' do
    freeze_time do
      notify(@actor, @ids.first(10))
      travel 24.hours - 1.second
      assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
      travel 2.seconds
      notify(@other, @ids.slice(10, 10))
    end
  end

  test 'repeated contact renews only that recipients rolling window' do
    freeze_time do
      notify(@actor, @ids.first(10))
      travel 23.hours
      notify(@actor, [ @ids.first ])
      travel 2.hours
      notify(@other, @ids.slice(10, 9))
      assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[19] ]) }
    end
  end

  test 'trial extension immediately raises both user and IP allowances to fifty' do
    notify(@actor, @ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify(@actor, [ @ids[10] ]) }
    @group.subscription.update!(max_members: 50)
    notify(@actor, @ids.first(50))
    assert_equal 50, TrialInvitationRecipient.distinct.count(:recipient_id)
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids.last ]) }
  end

  test 'the highest current trial allowance at the IP applies without adding trials together' do
    @group.subscription.update!(max_members: 12)
    @other_group.subscription.update!(max_members: 11)
    notify(@actor, @ids.first(8))
    notify(@other, @ids.slice(8, 4))
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[12] ]) }
  end

  test 'extension of another participating trial is read from its current subscription' do
    notify(@actor, @ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
    @group.subscription.update!(max_members: 50)
    notify(@other, [ @ids[10] ])
  end

  test 'an unlimited eligible trial leaves the shared IP allowance unlimited' do
    @group.subscription.update!(max_members: nil)
    notify(@actor, @ids.first(50))
    notify(@other, [ @ids.last ])
    assert_equal 51, TrialInvitationRecipient.distinct.count(:recipient_id)
  end

  test 'expired or disabled historical trials cannot raise the IP allowance' do
    @group.subscription.update!(max_members: 50)
    notify(@actor, [ @ids.first ])
    @group.subscription.update!(state: 'on_hold')
    notify(@other, @ids.slice(1, 9))
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'an unrelated extended trial does not raise the shared allowance' do
    _user, group = trial('unrelated')
    group.subscription.update!(max_members: 50)
    notify(@actor, @ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'a paid actor neither consumes nor checks the trial IP allowance' do
    notify(@other, @ids.first(10))
    @group.subscription.update!(plan: 'pro')
    assert @actor.reload.is_paying?
    assert_no_difference 'TrialInvitationRecipient.count' do
      notify(@actor, @ids.slice(10, 20))
    end
  end

  test 'installations without subscriptions do not use the IP allowance' do
    ENV.delete('LOOMIO_SUBSCRIPTIONS')
    assert_no_difference 'TrialInvitationRecipient.count' do
      notify(@actor, @ids.first(20))
    end
  end

  test 'background invitations use the recorded sign in IP when there is no request' do
    Current.request_ip = nil
    @actor.update!(current_sign_in_ip: '198.51.100.25')
    @other.update!(current_sign_in_ip: '198.51.100.25')
    notify(@actor, @ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify(@other, [ @ids[10] ]) }
  end

  test 'membership resends count their actual recipient even without explicit recipient IDs' do
    notify(@actor, @ids.first(10))
    membership = @other_group.add_member!(User.find(@ids[10]))
    assert_raises(ThrottleService::LimitReached) do
      NotificationService.create!(kind: 'membership_resent', subject: membership, actor: @other)
    end
  end

  test 'rolling back an invitation releases its IP slots and queues no deliveries' do
    assert_no_difference [ 'TrialInvitationRecipient.count', 'Notification.count' ] do
      assert_no_enqueued_jobs only: RouteNotificationDeliveriesWorker do
        Notification.transaction do
          notify(@actor, @ids.first(10))
          raise ActiveRecord::Rollback
        end
      end
    end
    notify(@other, @ids.slice(10, 10))
  end

  test 'purging expires old entries while retaining recent and refreshed invitations' do
    freeze_time do
      notify(@actor, @ids.first(3))
      travel 23.hours
      notify(@actor, [ @ids.first ])
      travel 2.hours
      assert_difference 'TrialInvitationRecipient.count', -2 do
        TrialInvitationRecipient.purge_expired!
      end
      assert_equal [ @ids.first ], TrialInvitationRecipient.pluck(:recipient_id)
    end
  end

  test 'hard deleting users cleans up their quota records' do
    notify(@actor, @ids.first(2))
    User.find(@ids.first).destroy!
    assert_equal [ @ids.second ], TrialInvitationRecipient.pluck(:recipient_id)
    @actor.destroy!
    assert_empty TrialInvitationRecipient.all
  end

  test 'concurrent accounts cannot both reserve the final IP slot' do
    notify(@actor, @ids.first(9))
    third, = trial('third')
    ready, start, results = Queue.new, Queue.new, Queue.new
    subject_id = @subject.id
    threads = [ [ @other.id, @ids[9] ], [ third.id, @ids[10] ] ].map do |actor_id, recipient_id|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          Current.set(request_ip: '198.51.100.25') do
            ready << true
            start.pop
            NotificationService.create!(kind: 'discussion_announced', subject: TopicItem.find(subject_id),
              actor: User.find(actor_id), recipient_user_ids: [ recipient_id ])
            results << :created
          end
        rescue ThrottleService::LimitReached
          results << :limited
        rescue => error
          results << error
        end
      end
    end
    2.times { ready.pop }
    2.times { start << true }
    threads.each { |thread| assert thread.join(10), 'invitation request did not finish' }
    assert_equal [ :created, :limited ], 2.times.map { results.pop }.sort
    assert_equal 10, TrialInvitationRecipient.distinct.count(:recipient_id)
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
  end

  private

  def trial(name)
    user = User.create!(name: name, email: "ip-#{name}@example.com", email_verified: true)
    group = Group.create!(name: name, creator: user, group_privacy: 'secret',
      subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 10))
    group.add_admin!(user)
    [ user, group ]
  end

  def notify(actor, ids)
    NotificationService.create!(kind: 'discussion_announced', subject: @subject, actor: actor, recipient_user_ids: ids)
  end
end

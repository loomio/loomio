require 'test_helper'

class NotificationInvitationLimitTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @billing_env = ENV.slice('CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS')
    ENV.delete('CHARGIFY_API_KEY')
    ENV['LOOMIO_SUBSCRIPTIONS'] = 'enabled'
    @actor = users(:user)
    @group = topics(:discussion_topic).group
    @subject = topic_items(:discussion_created_topic_item)
    @recipient_ids = (1..12).map do |index|
      User.create!(email: "quota-recipient-#{index}@example.com").id
    end
    assert_not @actor.is_paying?
  end

  teardown do
    %w[CHARGIFY_API_KEY LOOMIO_SUBSCRIPTIONS].each do |key|
      @billing_env.key?(key) ? ENV[key] = @billing_env[key] : ENV.delete(key)
    end
  end

  test 'the tenth recipient is allowed and the eleventh is rejected before routing' do
    notify(@recipient_ids.first(9))
    notify([ @recipient_ids[9] ])

    assert_no_difference 'Notification.count' do
      assert_no_enqueued_jobs(only: RouteNotificationDeliveriesWorker) do
        assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids[10] ]) }
      end
    end
  end

  test 'one bulk request cannot exceed the account allowance' do
    assert_no_difference 'Notification.count' do
      assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    end
  end

  test 'the allowance does not reset after a day or a cache clear' do
    notify(@recipient_ids.first(10))
    Rails.cache.clear

    travel 2.days do
      assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
    end
  end

  test 'only invitation records still in the database consume allowance' do
    notification = notify(@recipient_ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }

    notification.destroy!

    assert_difference 'Notification.count', 1 do
      notify([ @recipient_ids.last ])
    end
  end

  test 'recipient IDs are deduplicated per invitation and self invitations do not count' do
    notification = notify([ @actor.id, *@recipient_ids.first(9), *@recipient_ids.first(9) ])
    assert_equal 10, notification.recipient_user_ids.length
    notify([ @recipient_ids[9] ])

    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids[10] ]) }
  end

  test 'repeat notifications to existing recipients do not consume extra slots' do
    notify(@recipient_ids.first(10))
    12.times { notify([ @recipient_ids.first ]) }

    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'the same person invited to multiple records only counts once' do
    12.times do
      Notification.create!(actor: @actor, subject: @group, kind: 'membership_created',
        recipient_user_ids: [ @recipient_ids.first ])
      notify([ @recipient_ids.first ])
    end

    notify(@recipient_ids.slice(1, 9))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'accounts already over ten can still notify existing recipients' do
    Notification.create!(actor: @actor, subject: @subject, kind: 'discussion_announced', recipient_user_ids: @recipient_ids)
    notify(@recipient_ids)

    newcomer = User.create!(email: 'new-person-after-limit@example.com')
    assert_raises(ThrottleService::LimitReached) { notify([ newcomer.id ]) }
  end

  test 'group thread poll and outcome invitation records share one allowance' do
    kinds = %w[membership_created discussion_announced poll_announced outcome_announced]
    kinds.each_with_index do |kind, index|
      subject = kind == 'membership_created' ? @group : @subject
      Notification.create!(actor: @actor, subject: subject, kind: kind,
        recipient_user_ids: @recipient_ids.slice(index * 2, 2))
    end
    notify(@recipient_ids.slice(8, 2))

    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'memberships and guest invitations count even if revoked or never emailed' do
    @recipient_ids.first(5).each do |id|
      Membership.create!(group: @group, user_id: id, inviter: @actor, revoked_at: Time.current)
    end
    @recipient_ids.slice(5, 5).each do |id|
      TopicReader.create!(topic: @subject.topic, user_id: id, inviter: @actor, guest: true, revoked_at: Time.current)
    end

    notify(@recipient_ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'identified and anonymous voter invitations count without notification records' do
    polls = [ false, true ].map do |anonymous|
      PollService.create(params: { title: 'Invited electorate', group_id: @group.id, poll_type: 'proposal',
        specified_voters_only: true, anonymous: anonymous, poll_option_names: [ 'Agree' ],
        closing_at: 2.days.from_now, notify_on_open: false }, actor: users(:admin))
    end
    @recipient_ids.first(5).each do |id|
      Stance.create!(poll: polls.first, participant_id: id, inviter: @actor)
    end
    @recipient_ids.slice(5, 5).each do |id|
      AnonymousPollVoter.create!(poll: polls.last, voter_id: id, inviter: @actor)
    end

    notify(@recipient_ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'other actors and ordinary conversation notifications do not consume the allowance' do
    Notification.create!(actor: users(:alien), subject: @subject, kind: 'discussion_announced', recipient_user_ids: @recipient_ids)
    Notification.create!(actor: @actor, subject: @subject, kind: 'user_mentioned', recipient_user_ids: @recipient_ids)

    notify(@recipient_ids.first(10))
  end

  test 'both managed billing integrations enable the allowance' do
    [ 'CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS' ].each do |key|
      ENV.delete('CHARGIFY_API_KEY')
      ENV.delete('LOOMIO_SUBSCRIPTIONS')
      ENV[key] = 'enabled'

      assert AppConfig.app_features[:subscriptions]
      assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    end
  end

  test 'private installations do not have the account allowance' do
    ENV.delete('CHARGIFY_API_KEY')
    ENV.delete('LOOMIO_SUBSCRIPTIONS')

    assert_not AppConfig.app_features[:subscriptions]
    notify(@recipient_ids)
  end

  test 'active paid group membership bypasses the allowance' do
    @group.update!(subscription: Subscription.create!(plan: 'pro', state: 'active'))

    assert @actor.reload.is_paying?
    notify(@recipient_ids)
  end

  test 'extending an active trial immediately raises the distinct recipient allowance' do
    subscription = Subscription.create!(plan: 'trial', state: 'active', max_members: 10)
    @group.update!(subscription: subscription)
    notify(@recipient_ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids[10] ]) }

    subscription.update!(max_members: 50)
    ids = @recipient_ids + Array.new(39) do |index|
      User.create!(email: "extended-trial-recipient-#{index}@example.com").id
    end
    notify(ids.first(50))
    notify(ids.first(50))

    assert_no_difference 'Notification.count' do
      assert_raises(ThrottleService::LimitReached) { notify([ ids.last ]) }
    end
  end

  test 'multiple active trials use the highest allowance instead of adding them' do
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 11))
    other_group = groups(:alien_group)
    other_group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 12))
    other_group.add_member!(@actor)

    notify(@recipient_ids)

    newcomer = User.create!(email: 'beyond-largest-trial@example.com')
    assert_raises(ThrottleService::LimitReached) { notify([ newcomer.id ]) }
  end

  test 'subgroup members inherit their active parent trial allowance' do
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 12))
    memberships(:user_membership).update!(revoked_at: Time.current)

    notify(@recipient_ids)

    newcomer = User.create!(email: 'beyond-parent-trial@example.com')
    assert_raises(ThrottleService::LimitReached) { notify([ newcomer.id ]) }
  end

  test 'an unlimited active trial retains its unlimited invitation allowance' do
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: nil))

    notify(@recipient_ids)
  end

  test 'smaller trial member limits do not lower the default invitation allowance' do
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 3))

    notify(@recipient_ids.first(10))
    assert_raises(ThrottleService::LimitReached) { notify([ @recipient_ids.last ]) }
  end

  test 'disabled trials cannot raise the invitation allowance' do
    subscription = Subscription.create!(plan: 'trial', state: 'active', max_members: 50)
    @group.update!(subscription: subscription)

    %w[on_hold past_due canceled].each do |state|
      subscription.update!(state: state)
      assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    end
    subscription.update!(state: 'active', expires_at: 1.day.ago)
    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    subscription.update!(expires_at: 1.day.from_now)
    @group.update!(discarded_at: Time.current)
    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }

    @group.update!(discarded_at: nil)
    notify(@recipient_ids)
  end

  test 'revoked memberships and discarded subgroups cannot raise the invitation allowance' do
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 50))
    memberships(:user_membership).update!(revoked_at: Time.current)
    memberships(:user_subgroup_membership).update!(revoked_at: Time.current)

    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }

    memberships(:user_subgroup_membership).update!(revoked_at: nil)
    groups(:subgroup).update!(discarded_at: Time.current)
    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }

    groups(:subgroup).update!(discarded_at: nil)
    notify(@recipient_ids)
  end

  test 'trials in unrelated groups cannot raise the invitation allowance' do
    groups(:alien_group).update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 50))

    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
  end

  test 'expired paused and trial groups do not bypass the allowance' do
    subscription = Subscription.create!(plan: 'pro', state: 'on_hold')
    @group.update!(subscription: subscription)

    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    subscription.update!(state: 'active', expires_at: 1.day.ago)
    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
    subscription.update!(plan: 'trial', expires_at: nil, max_members: 10)
    assert_raises(ThrottleService::LimitReached) { notify(@recipient_ids) }
  end

  test 'a rolled back invitation does not consume allowance' do
    Notification.transaction do
      notify(@recipient_ids.first(10))
      raise ActiveRecord::Rollback
    end

    notify(@recipient_ids.first(10))
  end

  test 'concurrent requests cannot both take the final available recipient' do
    notify(@recipient_ids.first(9))
    ready = Queue.new
    start = Queue.new
    results = Queue.new
    actor_id = @actor.id
    subject_id = @subject.id
    threads = @recipient_ids.last(2).map do |recipient_id|
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop
          NotificationService.create!(kind: 'discussion_announced', subject: TopicItem.find(subject_id),
            actor: User.find(actor_id), recipient_user_ids: [ recipient_id ])
          results << :created
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
    assert_equal 10, Notification.where(actor_id: @actor.id).distinct.pluck(Arel.sql('unnest(recipient_user_ids)')).length
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
  end

  private

  def notify(ids)
    NotificationService.create!(kind: 'discussion_announced', subject: @subject,
      actor: @actor, recipient_user_ids: ids)
  end
end

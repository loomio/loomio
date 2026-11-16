require 'test_helper'

class Api::V1::InvitationLimitTest < ActionController::TestCase
  tests Api::V1::AnnouncementsController

  setup do
    @billing_env = ENV.slice('CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS')
    ENV.delete('CHARGIFY_API_KEY')
    ENV['LOOMIO_SUBSCRIPTIONS'] = 'enabled'
    @actor = users(:admin)
    @group = topics(:discussion_topic).group
    @group.update!(subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 10))
    @discussion = DiscussionService.create(params: { title: 'Invitation limit' }, actor: @actor)
    @history = Notification.create!(kind: 'discussion_announced', actor: @actor, subject: @discussion.created_topic_item,
      recipient_user_ids: User.where.not(id: @actor.id).limit(9).pluck(:id))
    assert_equal 9, @history.recipient_user_ids.length
    assert_not @actor.is_paying?
    sign_in @actor
    clear_enqueued_jobs
  end

  teardown do
    %w[CHARGIFY_API_KEY LOOMIO_SUBSCRIPTIONS].each do |key|
      @billing_env.key?(key) ? ENV[key] = @billing_env[key] : ENV.delete(key)
    end
  end

  test 'a rejected direct invitation batch rolls back users readers and notifications' do
    assert_rejected_without_changes(topic_id: @discussion.topic_id)
  end

  test 'a rejected group invitation batch rolls back users memberships and notifications' do
    # Leave room in the group's member limit so this exercises the account's
    # distinct-invitee limit rather than the separate group subscription check.
    limit = @group.all_memberships.count + recipients.length
    @group.subscription.update!(max_members: limit)
    @history.update!(recipient_user_ids: User.where.not(id: @actor.id).limit(limit).pluck(:id))
    assert_equal limit, @history.recipient_user_ids.length

    assert_rejected_without_changes(group_id: @group.id)
  end

  test 'a rejected poll invitation batch rolls back voters readers and notifications' do
    poll = PollService.create(params: {
      title: 'Vote invitation', poll_type: 'proposal', topic_id: @discussion.topic_id,
      specified_voters_only: true, poll_option_names: [ 'Agree' ], closing_at: 3.days.from_now
    }, actor: @actor)

    assert_rejected_without_changes(poll_id: poll.id, notify_recipients: true)
  end

  test 'a rejected anonymous poll invitation batch rolls back its electorate too' do
    poll = PollService.create(params: {
      title: 'Anonymous invitation', poll_type: 'proposal', topic_id: @discussion.topic_id,
      specified_voters_only: true, anonymous: true,
      poll_option_names: [ 'Agree' ], closing_at: 3.days.from_now
    }, actor: @actor)

    assert_rejected_without_changes(poll_id: poll.id, notify_recipients: true)
  end

  test 'silent poll invitations cannot bypass the limit' do
    poll = PollService.create(params: {
      title: 'Silent invitation', poll_type: 'proposal', topic_id: @discussion.topic_id,
      specified_voters_only: true, anonymous: true,
      poll_option_names: [ 'Agree' ], closing_at: 3.days.from_now
    }, actor: @actor)

    assert_rejected_without_changes(poll_id: poll.id, notify_recipients: false)
  end

  test 'one final invitation succeeds and subsequent invitations are rejected' do
    post :create, params: { topic_id: @discussion.topic_id, recipient_emails: [ 'final-recipient@example.com' ] }
    assert_response :success
    assert @discussion.topic.topic_readers.guests.joins(:user).exists?(users: { email: 'final-recipient@example.com' })
    3.times do
      post :create, params: { topic_id: @discussion.topic_id, recipient_emails: [ 'final-recipient@example.com' ] }
      assert_response :success
    end

    assert_rejected_without_changes(topic_id: @discussion.topic_id)
  end

  test 'membership in an active paid group permits more invitations' do
    @group.subscription.update!(plan: 'pro')

    assert_difference 'User.count', 2 do
      post :create, params: { topic_id: @discussion.topic_id, recipient_emails: recipients }
    end
    assert_response :success
  end

  test 'extending a trial immediately permits additional direct invitations' do
    assert_rejected_without_changes(topic_id: @discussion.topic_id)
    @group.subscription.update!(max_members: 50)

    assert_difference 'User.count', 2 do
      post :create, params: { topic_id: @discussion.topic_id, recipient_emails: recipients }
    end

    assert_response :success
    assert_equal 2, @discussion.topic.topic_readers.guests.joins(:user).where(users: { email: recipients }).count
  end

  test 'a private installation permits more invitations' do
    ENV.delete('LOOMIO_SUBSCRIPTIONS')

    post :create, params: { topic_id: @discussion.topic_id, recipient_emails: recipients }

    assert_response :success
  end

  private

  def recipients
    [ 'blocked-recipient-one@example.com', 'blocked-recipient-two@example.com' ]
  end

  def assert_rejected_without_changes(params)
    counts = %w[User.count Membership.count TopicReader.count Stance.count AnonymousPollVoter.count Notification.count NotificationDelivery.count]
    assert_no_difference counts do
      assert_no_enqueued_jobs(only: RouteNotificationDeliveriesWorker) do
        post :create, params: params.merge(recipient_emails: recipients)
      end
    end

    assert_response :too_many_requests
    assert_equal I18n.t('errors.invitation_rate_limit_reached_contact_support'), response.parsed_body.dig('flash', 'error')
    assert_not_includes response.parsed_body.dig('flash', 'error'), 'Daily'
  end
end

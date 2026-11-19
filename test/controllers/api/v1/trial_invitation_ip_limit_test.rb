require 'test_helper'

class Api::V1::TrialInvitationIpLimitTest < ActionController::TestCase
  tests Api::V1::AnnouncementsController

  setup do
    @billing_env = ENV.slice('CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS')
    ENV.delete('CHARGIFY_API_KEY')
    ENV['LOOMIO_SUBSCRIPTIONS'] = 'enabled'
    @actor = User.create!(name: 'Trial admin', email: 'ip-trial-admin@example.com', email_verified: true)
    @group = Group.create!(name: 'IP trial', creator: @actor, group_privacy: 'secret',
      subscription: Subscription.create!(plan: 'trial', state: 'active', max_members: 10))
    @group.add_admin!(@actor)
    @discussion = DiscussionService.create(params: { title: 'IP allowance' }, actor: @actor)
    @request.remote_addr = '198.51.100.45'
    Current.set(request_ip: '198.51.100.45') do
      NotificationService.create!(kind: 'discussion_announced', subject: @discussion.created_topic_item,
        actor: users(:user), recipient_user_ids: Array.new(10) { |i| User.create!(email: "other-ip-invite-#{i}@example.com").id })
    end
    sign_in @actor
    clear_enqueued_jobs
  end

  teardown do
    %w[CHARGIFY_API_KEY LOOMIO_SUBSCRIPTIONS].each do |key|
      @billing_env.key?(key) ? ENV[key] = @billing_env[key] : ENV.delete(key)
    end
  end

  test 'the IP allowance rejects a direct invitation without creating users readers notifications or jobs' do
    assert_rejected(topic_id: @discussion.topic_id)
  end

  test 'the IP allowance rejects group invitations atomically' do
    assert_rejected(group_id: @group.id)
  end

  test 'the IP allowance rejects poll and anonymous poll invitations atomically' do
    [ false, true ].each do |anonymous|
      poll = PollService.create(params: { title: 'IP electorate', topic_id: @discussion.topic_id,
        poll_type: 'proposal', specified_voters_only: true, anonymous: anonymous,
        poll_option_names: [ 'Agree' ], closing_at: 2.days.from_now }, actor: @actor)
      assert_rejected(poll_id: poll.id, notify_recipients: true)
    end
  end

  test 'a trial extension immediately permits the rejected IP invitation' do
    assert_rejected(topic_id: @discussion.topic_id)
    @group.subscription.update!(max_members: 50)
    assert_difference 'User.count', 1 do
      post :create, params: { topic_id: @discussion.topic_id, recipient_emails: [ 'new-ip-invite@example.com' ] }
    end
    assert_response :success
    assert TrialInvitationRecipient.where(actor: @actor).exists?
    assert_nil Current.request_ip
  end

  test 'Cloudflare edge requests use the client IP' do
    @request.remote_addr = '173.245.48.10'
    @request.env['HTTP_CF_CONNECTING_IP'] = '198.51.100.45'
    assert_rejected(topic_id: @discussion.topic_id)
  end

  test 'an untrusted peer cannot spoof the Cloudflare header to evade its IP allowance' do
    @request.env['HTTP_CF_CONNECTING_IP'] = '198.51.100.99'
    assert_rejected(topic_id: @discussion.topic_id)
  end

  private

  def assert_rejected(params)
    counts = %w[User.count Membership.count TopicReader.count Stance.count AnonymousPollVoter.count Notification.count NotificationDelivery.count TrialInvitationRecipient.count]
    assert_no_difference counts do
      assert_no_enqueued_jobs only: RouteNotificationDeliveriesWorker do
        post :create, params: params.merge(recipient_emails: [ 'new-ip-invite@example.com' ])
      end
    end
    assert_response :too_many_requests
    assert_equal I18n.t('errors.invitation_rate_limit_reached_contact_support'), response.parsed_body.dig('flash', 'error')
    assert_nil Current.request_ip
  end
end

require 'test_helper'
require 'aws-sdk-sesv2'

class SesNotificationEmailServiceTest < ActiveSupport::TestCase
  setup do
    @recipient = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    @delivery = NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email',
      email_address: @recipient.email, provider_message_id: 'ses-message', delivered_at: 2.minutes.ago,
      email_sync_due_at: Time.current)
    @client = Aws::SESV2::Client.new(region: 'us-east-1', stub_responses: true)
  end

  test 'confirmed server delivery is stored with the provider timestamp and stops polling' do
    time = 1.minute.ago
    stub_insights([{type: 'DELIVERY', timestamp: time}, {type: 'OPEN', timestamp: Time.current}])
    2.times { SesNotificationEmailService.sync!(@delivery, client: @client) }
    event = @delivery.events.sole
    assert_equal 'delivered', event.kind
    assert_in_delta time.to_f, event.occurred_at.to_f, 0.01
    assert_nil @delivery.reload.email_sync_due_at
    assert_equal 'delivered', @delivery.email_status
    assert_equal({message_id: 'ses-message'}, @client.api_requests.first.fetch(:params))
  end

  test 'API and forwarded feedback do not apply suppression twice for the same delivery' do
    stub_insights([{type: 'BOUNCE', timestamp: Time.current,
      details: {bounce: {bounce_type: 'Permanent', bounce_sub_type: 'General', diagnostic_code: '550 Unknown mailbox'}}}])
    assert_difference -> { @recipient.reload.bounces_count }, 1 do
      2.times { SesNotificationEmailService.sync!(@delivery, client: @client) }
      NotificationEmailEventService.record!(delivery: @delivery, kind: 'bounced', source_key: 'email:report-1',
        occurred_at: Time.current)
    end
    assert_equal 2, @delivery.events.count
    assert_includes @delivery.events.first.detail, '550'
  end

  test 'complaints update the existing suppression policy' do
    stub_insights([{type: 'COMPLAINT', timestamp: Time.current,
      details: {complaint: {complaint_feedback_type: 'abuse'}}}])
    assert_difference -> { @recipient.reload.complaints_count }, 1 do
      SesNotificationEmailService.sync!(@delivery, client: @client)
    end
    assert_equal 'complained', @delivery.events.sole.kind
  end

  test 'pending insights and delayed delivery keep polling without inventing failure' do
    stub_insights([{type: 'SEND', timestamp: 1.minute.ago}, {type: 'DELIVERY_DELAY', timestamp: Time.current}])
    assert_no_difference -> { @recipient.reload.bounces_count } do
      SesNotificationEmailService.sync!(@delivery, client: @client)
    end
    assert_equal 'delayed', @delivery.events.sole.kind
    assert_operator @delivery.reload.email_sync_due_at, :>, Time.current
  end

  test 'not found is retried and messages outside retention stop without a delivery claim' do
    @client.stub_responses(:get_message_insights, 'NotFoundException')
    assert_no_difference 'NotificationDeliveryEvent.count' do
      SesNotificationEmailService.sync!(@delivery, client: @client)
    end
    assert_operator @delivery.reload.email_sync_due_at, :>, Time.current
    @delivery.update!(delivered_at: 31.days.ago)
    SesNotificationEmailService.sync!(@delivery, client: @client)
    assert_nil @delivery.reload.email_sync_due_at
    assert_equal 1, @client.api_requests.count
  end

  test 'another recipient or provider message ID cannot supply this delivery evidence' do
    @client.stub_responses(:get_message_insights,
      {message_id: 'wrong-message', insights: []},
      {message_id: 'ses-message', insights: [{destination: users(:alien).email, events: [{type: 'DELIVERY', timestamp: Time.current}]}]})
    2.times do
      assert_raises RuntimeError do
        SesNotificationEmailService.sync!(@delivery, client: @client)
      end
    end
    assert_empty @delivery.events
    assert @delivery.reload.email_sync_due_at.present?
  end

  test 'missing permission does not mutate the email status' do
    @client.stub_responses(:get_message_insights, 'AccessDeniedException')
    assert_raises Aws::SESV2::Errors::AccessDeniedException do
      SesNotificationEmailService.sync!(@delivery, client: @client)
    end
    assert_empty @delivery.events
  end

  test 'the recurring worker is optional bounded and spaces requests' do
    original = ENV['SES_MESSAGE_INSIGHTS_REGION']
    ENV.delete('SES_MESSAGE_INSIGHTS_REGION')
    worker = SyncNotificationEmailsWorker.new
    SesNotificationEmailService.stub(:client, -> { raise 'should not create a client' }) { worker.perform }
    ENV['SES_MESSAGE_INSIGHTS_REGION'] = 'us-east-1'
    notifications = 21.times.map { Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin)) }
    notifications.each do |notification|
      NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email',
        provider_message_id: 'ses-message', email_address: @recipient.email, delivered_at: 2.minutes.ago, email_sync_due_at: 1.minute.ago)
    end
    stub_insights([{type: 'DELIVERY', timestamp: Time.current}])
    waits = []
    SesNotificationEmailService.stub(:client, @client) do
      worker.stub(:sleep, ->(seconds) { waits << seconds }) { worker.perform }
    end
    assert_equal 20, @client.api_requests.count
    assert_equal [1] * 19, waits
    assert_equal 2, NotificationDelivery.where.not(email_sync_due_at: nil).count
  ensure
    original.nil? ? ENV.delete('SES_MESSAGE_INSIGHTS_REGION') : ENV['SES_MESSAGE_INSIGHTS_REGION'] = original
  end

  private

  def stub_insights(events)
    @client.stub_responses(:get_message_insights, message_id: 'ses-message',
      insights: [{destination: @delivery.email_address, events: events}])
  end
end

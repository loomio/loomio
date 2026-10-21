require 'test_helper'

class DeliverNotificationEmailWorkerTest < ActiveSupport::TestCase
  setup do
    @recipient = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin),
      recipient_user_ids: [@recipient.id], recipient_message: 'A new invitation')
    @delivery = NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email')
  end

  test 'sending stores the message ID without subject or recipient address snapshots' do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      2.times { DeliverNotificationEmailWorker.perform_now(@delivery.id) }
    end
    mail = ActionMailer::Base.deliveries.last
    @delivery.reload
    assert_equal mail.message_id, @delivery.email_message_id
    refute @delivery.has_attribute?(:email_address)
    refute @delivery.has_attribute?(:email_subject)
    assert_equal 'sent', @delivery.events.sole.kind
    assert @delivery.delivered_at.present?
    assert_nil @delivery.provider_message_id
  end

  test 'suppressed mail is not marked sent' do
    EmailSuppressionService.record!(email: @recipient.email, reason: 'complaint', source_key: 'test:complaint')
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DeliverNotificationEmailWorker.perform_now(@delivery.id)
    end
    assert_nil @delivery.reload.delivered_at
    assert_equal 'skipped', @delivery.events.sole.kind
  end

  test 'the SMTP response supplies the SES message ID rather than the local Message-ID' do
    transport = NotificationSmtpDelivery.new(address: 'email-smtp.us-east-1.amazonaws.com')
    def transport.deliver!(message)
      @response = Net::SMTP::Response.parse("250 Ok ses-assigned-message-id\r\n")
    end
    using_smtp(transport) { DeliverNotificationEmailWorker.perform_now(@delivery.id) }

    assert_equal 'ses-assigned-message-id', @delivery.reload.provider_message_id
    refute_equal @delivery.email_message_id, @delivery.provider_message_id
  end

  test 'a delayed SMTP attempt keeps its message ID when the worker retries' do
    transport = NotificationSmtpDelivery.new(address: 'email-smtp.us-east-1.amazonaws.com')
    message_ids = []
    transport.define_singleton_method(:deliver!) do |message|
      message_ids << message.message_id
      raise Net::SMTPServerBusy, '451 Try again later' if message_ids.length == 1

      @response = Net::SMTP::Response.parse("250 Ok retry-provider-id\r\n")
    end

    using_smtp(transport) do
      assert_raises(Net::SMTPServerBusy) { DeliverNotificationEmailWorker.new.perform(@delivery.id) }
      assert_nil @delivery.reload.delivered_at
      assert_equal 'delayed', @delivery.events.sole.kind
      assert_includes @delivery.events.sole.detail, '451 Try again later'
      DeliverNotificationEmailWorker.new.perform(@delivery.id)
    end

    assert_equal [@delivery.reload.email_message_id] * 2, message_ids
    assert @delivery.delivered_at.present?
    assert_equal 'retry-provider-id', @delivery.provider_message_id
    assert_equal %w[delayed sent], @delivery.events.order(:id).pluck(:kind)
  end

  test 'an SMTP rejection records the actual error and remains available to retry' do
    transport = NotificationSmtpDelivery.new(address: 'smtp.example.test')
    transport.define_singleton_method(:deliver!) { |_| raise Net::SMTPFatalError, '554 Message rejected' }

    using_smtp(transport) do
      assert_raises(Net::SMTPFatalError) { DeliverNotificationEmailWorker.new.perform(@delivery.id) }
    end

    assert_nil @delivery.reload.delivered_at
    assert @delivery.email_message_id.present?
    assert_equal 'rejected', @delivery.events.sole.kind
    assert_includes @delivery.events.sole.detail, '554 Message rejected'
  end

  test 'completion cannot restore identifiers when redaction happens during SMTP' do
    transport = NotificationSmtpDelivery.new(address: 'email-smtp.us-east-1.amazonaws.com')
    recipient = @recipient
    transport.define_singleton_method(:deliver!) do |_message|
      RedactUserWorker.perform_now(recipient.id, recipient.id, false)
      @response = Net::SMTP::Response.parse("250 Ok private-provider-id\r\n")
    end

    using_smtp(transport) { DeliverNotificationEmailWorker.new.perform(@delivery.id) }

    assert_nil @recipient.reload.email
    assert_nil @delivery.reload.email_message_id
    assert_nil @delivery.provider_message_id
    assert_empty @delivery.events
  end

  private

  def using_smtp(transport)
    NotificationMailer.stub(:delivery_method, :smtp) do
      NotificationMailer.stub(:smtp_settings, transport.settings) do
        NotificationSmtpDelivery.stub(:new, transport) { yield }
      end
    end
  end
end

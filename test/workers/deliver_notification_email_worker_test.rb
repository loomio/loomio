require 'test_helper'

class DeliverNotificationEmailWorkerTest < ActiveSupport::TestCase
  setup do
    @recipient = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin),
      recipient_user_ids: [@recipient.id], recipient_message: 'A new invitation')
    @delivery = NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email')
  end

  test 'sending stores exact recipient subject and message ID and records submission once' do
    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      2.times { DeliverNotificationEmailWorker.perform_now(@delivery.id) }
    end
    mail = ActionMailer::Base.deliveries.last
    @delivery.reload
    assert_equal mail.message_id, @delivery.email_message_id
    assert_equal @recipient.email, @delivery.email_address
    assert_equal mail.subject, @delivery.email_subject
    assert_equal 'sent', @delivery.events.sole.kind
    assert @delivery.delivered_at.present?
    assert_nil @delivery.provider_message_id
  end

  test 'suppressed mail is not marked sent' do
    @recipient.update!(complaints_count: 1)
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
    NotificationSmtpDelivery.stub(:new, transport) do
      mail = NotificationMailer.notification(@delivery.id).message
      mail.delivery_method(:smtp, address: 'email-smtp.us-east-1.amazonaws.com')
      delivery = Object.new
      delivery.define_singleton_method(:message) { mail }
      delivery.define_singleton_method(:deliver_now) { mail.deliver }
      NotificationMailer.stub(:notification, delivery) do
        DeliverNotificationEmailWorker.perform_now(@delivery.id)
      end
    end
    assert_equal 'ses-assigned-message-id', @delivery.reload.provider_message_id
    refute_equal @delivery.email_message_id, @delivery.provider_message_id
  end
end

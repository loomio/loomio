require 'test_helper'

class ProductionEmailFeedbackTest < ActionMailbox::TestCase
  setup do
    @recipient = users(:member_normal)
    @recipient.update!(email: 'recipient@example.test')
  end

  test 'a production hard bounce authenticates and links its SES message to the delivery' do
    delivery = delivery_for('ses_hard_bounce')
    assert_difference 'EmailSuppression.count', 1 do
      receive_fixture('ses_hard_bounce')
    end
    event = delivery.events.sole
    assert_equal 'bounced', event.kind
    assert_equal 'Permanent', event.bounce_type
    assert_includes event.detail, '5.1.1'
    assert_equal event.id, EmailSuppression.for_address(@recipient.email).sole.notification_delivery_event_id
    assert @recipient.email_delivery_blocked?
    assert ReceivedEmail.last.released?
  end

  test 'a production SMTP 550 failure with DSN status 4.4.7 remains transient' do
    delivery = delivery_for('ses_transient_failure')
    assert_no_difference 'EmailSuppression.count' do
      receive_fixture('ses_transient_failure')
    end
    event = delivery.events.sole
    assert_equal 'bounced', event.kind
    assert_equal 'Transient', event.bounce_type
    assert_includes event.detail, '550 4.4.7'
    refute @recipient.email_delivery_blocked?
    assert ReceivedEmail.last.released?
  end

  test 'a production complaint matches the SES ID in its attached original message' do
    delivery = delivery_for('ses_complaint')
    receive_fixture('ses_complaint')
    event = delivery.events.sole
    assert_equal 'complained', event.kind
    assert_includes event.detail, 'abuse'
    assert_equal event.id, EmailSuppression.for_address(@recipient.email).sole.notification_delivery_event_id
    assert @recipient.email_delivery_blocked?
    assert ReceivedEmail.last.released?
  end

  test 'a production complaint can identify an untracked recipient from the ARF report' do
    assert_no_difference 'NotificationDeliveryEvent.count' do
      assert_difference 'EmailSuppression.count', 1 do
        receive_fixture('ses_complaint')
      end
    end
    record = EmailSuppression.for_address(@recipient.email).sole
    assert_equal 'complaint', record.reason
    assert_nil record.notification_delivery_event_id
    assert @recipient.email_delivery_blocked?
    assert ReceivedEmail.last.released?
  end

  test 'production format reports cannot block an address when the relay reports failed DKIM' do
    %w[ses_hard_bounce ses_complaint].each do |name|
      mail = fixture_mail(name)
      mail['Authentication-Results'] = mail['Authentication-Results'].decoded.gsub('dkim=pass', 'dkim=fail')
      assert_no_difference [ 'NotificationDeliveryEvent.count', 'EmailSuppression.count' ] do
        receive_inbound_email_from_source(mail.encoded)
      end
      refute @recipient.email_delivery_blocked?
      assert ReceivedEmail.last.released?
    end
  end

  private

  def delivery_for(name)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email',
      email_address: @recipient.email, email_message_id: "local-#{name}@loomio.test", provider_message_id: "#{name}-original")
  end

  def fixture_mail(name)
    source = File.binread(Rails.root.join("test/fixtures/files/email_feedback/#{name}.eml"))
    Mail.read_from_string(source).tap { |mail| mail.to = ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS }
  end

  def receive_fixture(name)
    receive_inbound_email_from_source(fixture_mail(name).encoded)
  end
end

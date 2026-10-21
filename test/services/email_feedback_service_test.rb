require 'test_helper'

class EmailFeedbackServiceTest < ActiveSupport::TestCase
  setup do
    @recipient = users(:member_normal)
    @notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin),
      recipient_user_ids: [@recipient.id])
    @delivery = NotificationDelivery.create!(notification: @notification, recipient: @recipient, channel: 'email',
      email_address: @recipient.email, email_message_id: 'local-message@loomio.test', provider_message_id: 'ses-message')
  end

  test 'an authenticated regional SES bounce to notifications links to the exact delivery' do
    email, mail = feedback
    assert_difference -> { @recipient.reload.bounces_count }, 1 do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        ReceivedEmailService.route(email, mail: mail)
      end
    end
    event = @delivery.events.sole
    assert_equal 'bounced', event.kind
    assert_includes event.detail, '550 unknown mailbox'
    assert email.reload.released?
    assert_no_difference ['NotificationDeliveryEvent.count', '@recipient.reload.bounces_count'] do
      ReceivedEmailService.route(email, mail: mail)
    end
  end

  test 'a delay is recorded without permanently suppressing the recipient' do
    email, mail = feedback(action: 'delayed')
    assert_no_difference -> { @recipient.reload.bounces_count } do
      ReceivedEmailService.route(email, mail: mail)
    end
    assert_equal 'delayed', @delivery.events.sole.kind
  end

  test 'a complaint with a redacted recipient can be linked by SES message ID' do
    email, mail = feedback(complaint: true)
    assert_difference -> { @recipient.reload.complaints_count }, 1 do
      ReceivedEmailService.route(email, mail: mail)
    end
    assert_equal 'complained', @delivery.events.sole.kind
  end

  test 'the local message ID also links feedback for a non SES SMTP transport' do
    email, mail = feedback(message_id: @delivery.email_message_id)
    ReceivedEmailService.route(email, mail: mail)
    assert_equal 'bounced', @delivery.events.sole.kind
  end

  test 'another email to the same recipient never inherits this bounce' do
    other = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    other_delivery = NotificationDelivery.create!(notification: other, recipient: @recipient, channel: 'email',
      email_address: @recipient.email, provider_message_id: 'other-message')
    email, mail = feedback
    ReceivedEmailService.route(email, mail: mail)
    assert_equal 1, @delivery.events.count
    assert_empty other_delivery.events
  end

  test 'unknown message IDs and mismatched recipients cannot be attached to a delivery' do
    email, mail = feedback(message_id: 'unknown@amazonses.com')
    ReceivedEmailService.route(email, mail: mail)
    assert_empty @delivery.events

    email, mail = feedback(address: users(:alien).email)
    ReceivedEmailService.route(email, mail: mail)
    assert_empty @delivery.events
  end

  test 'forged or failed authentication cannot change delivery history or suppression' do
    [nil, 'mx.loomio.test; dkim=fail header.d=amazonses.com',
     'mx.loomio.test; dkim=pass header.d=amazonses.com.evil.test',
     'mx.loomio.test; dkim=pass header.d=evil.test'].each do |authentication|
      email, mail = feedback(authentication: authentication)
      assert_no_difference ['NotificationDeliveryEvent.count', '@recipient.reload.bounces_count'] do
        ReceivedEmailService.route(email, mail: mail)
      end
      assert email.reload.released?
    end
  end

  test 'failure to save linked feedback rolls back suppression and release state' do
    email, mail = feedback
    NotificationDeliveryEvent.stub(:new, ->(*) { raise 'storage failure' }) do
      assert_raises RuntimeError do
        ReceivedEmailService.route(email, mail: mail)
      end
    end
    refute email.reload.released?
    assert_equal 0, @recipient.reload.bounces_count
  end

  private

  def feedback(action: 'failed', complaint: false, message_id: 'ses-message@amazonses.com',
               address: @recipient.email, authentication: 'mx.loomio.test; dkim=pass header.d=amazonses.com')
    sender = complaint ? 'complaints@email-abuse.amazonses.com' : 'MAILER-DAEMON@us-east-1.amazonses.com'
    mail = Mail.new
    mail.from = sender
    mail.to = ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS
    mail.content_type = 'multipart/report'
    report = Mail::Part.new
    report.content_type = complaint ? 'message/feedback-report' : 'message/delivery-status'
    report.body = complaint ? "Feedback-Type: abuse\r\n" :
      "Reporting-MTA: dns; amazonses.com\r\n\r\nFinal-Recipient: rfc822; #{address}\r\nAction: #{action}\r\nStatus: 5.1.1\r\nDiagnostic-Code: smtp; 550 unknown mailbox\r\n"
    mail.add_part(report)
    original = Mail::Part.new
    original.content_type = 'text/rfc822-headers'
    original.body = "Message-ID: <#{message_id}>\r\nTo: #{address}\r\nSubject: Invitation\r\n"
    mail.add_part(original)
    email = ReceivedEmail.create!(message_id: "#{SecureRandom.uuid}@feedback.test",
      headers: {'From' => sender, 'To' => ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS,
                'Authentication-Results' => authentication})
    [email, mail]
  end
end

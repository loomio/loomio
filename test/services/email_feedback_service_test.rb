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
    assert_difference -> { EmailSuppression.for_address(@recipient.email).count }, 1 do
      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        ReceivedEmailService.route(email, mail: mail)
      end
    end
    event = @delivery.events.sole
    assert_equal 'bounced', event.kind
    assert_includes event.detail, '550 unknown mailbox'
    assert email.reload.released?
    assert_no_difference ['NotificationDeliveryEvent.count', 'EmailSuppression.count'] do
      ReceivedEmailService.route(email, mail: mail)
    end
  end

  test 'a delay is recorded without permanently suppressing the recipient' do
    email, mail = feedback(action: 'delayed')
    assert_no_difference -> { EmailSuppression.for_address(@recipient.email).count } do
      ReceivedEmailService.route(email, mail: mail)
    end
    assert_equal 'delayed', @delivery.events.sole.kind
  end

  test 'a transient or unclassified bounce records evidence without a permanent block' do
    ['4.2.2', 'unknown'].each do |status|
      email, mail = feedback(status: status)
      ReceivedEmailService.route(email, mail: mail)
      refute @recipient.email_delivery_blocked?
    end
    assert_equal %w[Transient Undetermined], @delivery.events.order(:id).pluck(:bounce_type)
  end

  test 'a multi recipient DSN cannot transfer a permanent failure to a delayed recipient' do
    other = users(:alien)
    email, mail = feedback
    report = mail.all_parts.find { |part| part.mime_type == 'message/delivery-status' }
    report.body = report.body.decoded + "\r\nFinal-Recipient: rfc822; #{other.email}\r\nAction: delayed\r\nStatus: 4.2.2\r\n"
    ReceivedEmailService.route(email, mail: mail)
    assert @recipient.email_delivery_blocked?
    refute other.email_delivery_blocked?
    assert_equal 'bounced', @delivery.events.sole.kind
  end

  test 'a complaint with a redacted recipient can be linked by SES message ID' do
    email, mail = feedback(complaint: true)
    assert_difference -> { EmailSuppression.for_address(@recipient.email).count }, 1 do
      ReceivedEmailService.route(email, mail: mail)
    end
    assert_equal 'complained', @delivery.events.sole.kind
  end

  test 'an explicit ARF recipient can block an address without a tracked message' do
    email, mail = feedback(complaint: true, message_id: 'untracked-message@amazonses.com')
    report = mail.all_parts.find { |part| part.mime_type == 'message/feedback-report' }
    report.body = "Feedback-Type: abuse\r\nOriginal-Rcpt-To: rfc822; #{@recipient.email}\r\n"
    ReceivedEmailService.route(email, mail: mail)
    assert @recipient.email_delivery_blocked?
    assert_nil EmailSuppression.for_address(@recipient.email).sole.notification_delivery_event_id
    assert_empty @delivery.events
  end

  test 'duplicate reports for an untracked original message do not reinstate a cleared block' do
    2.times do |index|
      email, mail = feedback(complaint: true, message_id: 'untracked-message@amazonses.com')
      report = mail.all_parts.find { |part| part.mime_type == 'message/feedback-report' }
      report.body = "Feedback-Type: abuse\r\nOriginal-Rcpt-To: rfc822; #{@recipient.email}\r\n"
      ReceivedEmailService.route(email, mail: mail)
      EmailSuppressionService.clear!(user: @recipient, actor: @recipient, method: 'sign_in') if index.zero?
    end
    refute @recipient.email_delivery_blocked?
    assert_equal 1, EmailSuppression.for_address(@recipient.email).count
  end

  test 'nested attachments cannot add other recipients to a complaint report' do
    other_recipient = users(:alien)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    other = NotificationDelivery.create!(notification: notification, recipient: other_recipient, channel: 'email',
      email_address: other_recipient.email, provider_message_id: 'other-message')
    email, mail = feedback(complaint: true)
    attachment = Mail::Part.new(content_type: 'multipart/mixed')
    attachment.add_part(Mail::Part.new(content_type: 'text/rfc822-headers',
      body: "Message-ID: <other-message@amazonses.com>\r\nTo: #{other_recipient.email}\r\n"))
    mail.add_part(attachment)
    ReceivedEmailService.route(email, mail: mail)
    assert @recipient.email_delivery_blocked?
    refute other_recipient.email_delivery_blocked?
    assert_empty other.events
  end

  test 'ambiguous feedback is reported without guessing a recipient from a From header' do
    email, mail = feedback(complaint: true, message_id: 'untracked-message@amazonses.com')
    report = mail.all_parts.find { |part| part.mime_type == 'message/feedback-report' }
    report.body = "Feedback-Type: abuse\r\nFrom: #{users(:alien).email}\r\n"
    warnings = []
    Rails.logger.stub(:warn, ->(message) { warnings << message }) do
      assert_no_difference 'EmailSuppression.count' do
        ReceivedEmailService.route(email, mail: mail)
      end
    end
    assert_empty @delivery.events
    assert_equal 1, warnings.size
    assert_includes warnings.first, "received_email_id=#{email.id}"
    assert email.reload.released?
  end

  test 'the local message ID also links feedback for a non SES SMTP transport' do
    email, mail = feedback(message_id: @delivery.email_message_id)
    ReceivedEmailService.route(email, mail: mail)
    assert_equal 'bounced', @delivery.events.sole.kind
  end

  test 'a configured non SES feedback sender works with SMTP message IDs and no provider API' do
    previous_address = ENV['BOUNCE_ADDRESS']
    ENV['BOUNCE_ADDRESS'] = 'bounce@postoffice.test'
    email, mail = feedback(sender: ENV['BOUNCE_ADDRESS'], message_id: @delivery.email_message_id,
      authentication: 'mx.loomio.test; dkim=pass header.d=postoffice.test')
    SesEmailSuppressionService.stub(:client, -> { raise 'feedback must not depend on SES' }) do
      ReceivedEmailService.route(email, mail: mail)
    end
    assert_equal 'bounced', @delivery.events.sole.kind
    assert @recipient.email_delivery_blocked?
    assert_equal @delivery.events.sole.id, EmailSuppression.for_address(@recipient.email).sole.notification_delivery_event_id
  ensure
    previous_address.nil? ? ENV.delete('BOUNCE_ADDRESS') : ENV['BOUNCE_ADDRESS'] = previous_address
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
      assert_no_difference ['NotificationDeliveryEvent.count', 'EmailSuppression.count'] do
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
    refute @recipient.email_delivery_blocked?
  end

  private

  def feedback(action: 'failed', complaint: false, message_id: 'ses-message@amazonses.com',
               address: @recipient.email, status: '5.1.1', sender: nil, authentication: 'mx.loomio.test; dkim=pass header.d=amazonses.com')
    sender ||= complaint ? 'complaints@email-abuse.amazonses.com' : 'MAILER-DAEMON@us-east-1.amazonses.com'
    mail = Mail.new
    mail.from = sender
    mail.to = ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS
    mail.content_type = 'multipart/report'
    report = Mail::Part.new
    report.content_type = complaint ? 'message/feedback-report' : 'message/delivery-status'
    report.body = complaint ? "Feedback-Type: abuse\r\n" :
      "Reporting-MTA: dns; amazonses.com\r\n\r\nFinal-Recipient: rfc822; #{address}\r\nAction: #{action}\r\nStatus: #{status}\r\nDiagnostic-Code: smtp; 550 unknown mailbox\r\n"
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

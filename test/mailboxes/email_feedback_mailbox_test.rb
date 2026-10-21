require 'test_helper'

class EmailFeedbackMailboxTest < ActionMailbox::TestCase
  setup do
    @recipient = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    @delivery = NotificationDelivery.create!(notification: notification, recipient: @recipient, channel: 'email',
      provider_message_id: 'ses-mailbox-message')
  end

  test 'multipart bounce parts without filenames survive the full mailbox path and stop subsequent email' do
    assert_difference -> { EmailSuppression.for_address(@recipient.email).count }, 1 do
      receive_inbound_email_from_source(feedback.to_s)
    end
    assert_equal 'bounced', @delivery.events.sole.kind
    assert_equal @delivery.events.sole.id, EmailSuppression.for_address(@recipient.email).sole.notification_delivery_event_id
    assert ReceivedEmail.last.released?
    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      UserMailer.redacted(@recipient.email, 'en').deliver_now
    end
  end

  test 'complaint feedback without a report recipient records its status without guessing an address block' do
    mail = feedback(complaint: true)
    report = mail.parts.find { |part| part.mime_type == 'message/feedback-report' }
    report.body = "Feedback-Type: abuse\r\n"
    assert_no_difference 'EmailSuppression.count' do
      receive_inbound_email_from_source(mail.to_s)
    end
    assert_equal 'complained', @delivery.events.sole.kind
    refute @recipient.email_delivery_blocked?
    assert ReceivedEmail.last.released?
  end

  test 'temporary failure and forged feedback cannot permanently block the address' do
    receive_inbound_email_from_source(feedback(status: '4.2.2').to_s)
    refute @recipient.email_delivery_blocked?
    assert_equal 'Transient', @delivery.events.sole.bounce_type
    assert_no_difference 'NotificationDeliveryEvent.count' do
      receive_inbound_email_from_source(feedback(authentication: 'mx.loomio.test; dkim=fail header.d=amazonses.com').to_s)
    end
    refute @recipient.email_delivery_blocked?
  end

  test 'replaying feedback cannot duplicate evidence or reinstate a cleared block' do
    mail = feedback
    receive_inbound_email_from_source(mail.to_s)
    EmailSuppressionService.clear!(user: @recipient, actor: @recipient, method: 'sign_in')
    assert_no_difference [ 'NotificationDeliveryEvent.count', 'EmailSuppression.count' ] do
      ActionMailbox::InboundEmail.find_by!(message_id: mail.message_id).route
    end
    refute @recipient.email_delivery_blocked?
  end

  test 'failed feedback is visible and can resume from a persisted inbound record' do
    mail = feedback
    source = ->(uuid) do
      mail['harakadata'] = { rcpt_to: [ ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS ], uuid: uuid }.to_json
      mail.to_s
    end
    NotificationEmailEventService.stub(:record!, ->(**) { raise 'storage unavailable' }) do
      assert_raises RuntimeError do
        receive_inbound_email_from_source(source.call('first-attempt'))
      end
    end
    email = ReceivedEmail.find_by!(message_id: mail.message_id)
    refute email.released?
    assert ActionMailbox::InboundEmail.find_by!(message_id: mail.message_id).failed?
    refute @recipient.email_delivery_blocked?

    assert_no_difference 'ReceivedEmail.count' do
      receive_inbound_email_from_source(source.call('retry-attempt'))
    end
    assert @recipient.email_delivery_blocked?
    assert email.reload.released?
    assert_equal 1, @delivery.events.count
  end

  test 'a forged duplicate cannot replace the authenticated body of pending feedback' do
    original = feedback
    original.add_file(filename: 'original.txt', content: 'Original feedback attachment')
    NotificationEmailEventService.stub(:record!, ->(**) { raise 'storage unavailable' }) do
      assert_raises(RuntimeError) { receive_inbound_email_from_source(original.to_s) }
    end
    email = ReceivedEmail.find_by!(message_id: original.message_id)
    source_id = email.header(EmailFeedbackService::SOURCE_INBOUND_HEADER)
    assert_equal original.message_id, ActionMailbox::InboundEmail.find(source_id).message_id

    forged = feedback
    forged.message_id = original.message_id
    forged['Authentication-Results'] = 'mx.loomio.test; dkim=fail header.d=amazonses.com'
    forged['X-Loomio-Inbound-Email-Id'] = '123456'
    forged.add_file(filename: 'forged.txt', content: 'Forged attachment')
    report = forged.all_parts.find { |part| part.mime_type == 'message/delivery-status' }
    report.body = "Final-Recipient: rfc822; #{users(:alien).email}\r\nAction: failed\r\nStatus: 5.1.1\r\n"
    receive_inbound_email_from_source(forged.to_s)

    assert @recipient.email_delivery_blocked?
    refute users(:alien).email_delivery_blocked?
    assert_equal source_id, email.reload.header(EmailFeedbackService::SOURCE_INBOUND_HEADER)
    assert_equal 'bounced', @delivery.events.sole.kind
    assert_equal [ 'original.txt' ], email.attachments.map { |attachment| attachment.filename.to_s }
  end

  private

  def feedback(complaint: false, status: '5.1.1', authentication: 'mx.loomio.test; dkim=pass header.d=amazonses.com')
    mail = Mail.new
    mail.message_id = "#{SecureRandom.uuid}@feedback.test"
    mail.from = complaint ? 'complaints@email-abuse.amazonses.com' : 'MAILER-DAEMON@us-east-1.amazonses.com'
    mail.to = ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS
    mail['Authentication-Results'] = authentication
    mail.content_type = complaint ? 'multipart/report; report-type=feedback-report' : 'multipart/report; report-type=delivery-status'
    mail.add_part(Mail::Part.new(content_type: 'text/plain', body: 'Email feedback'))
    if complaint
      mail.add_part(Mail::Part.new(content_type: 'message/feedback-report', body: "Feedback-Type: abuse\r\nOriginal-Rcpt-To: #{@recipient.email}\r\n"))
    else
      mail.add_part(Mail::Part.new(content_type: 'message/delivery-status', body:
        "Final-Recipient: rfc822; #{@recipient.email}\r\nAction: failed\r\nStatus: #{status}\r\n"))
    end
    mail.add_part(Mail::Part.new(content_type: 'text/rfc822-headers', body:
      "Message-ID: <ses-mailbox-message@amazonses.com>\r\nTo: #{@recipient.email}\r\n"))
    mail
  end
end

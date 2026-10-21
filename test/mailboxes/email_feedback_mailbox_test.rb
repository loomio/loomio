require 'test_helper'

class EmailFeedbackMailboxTest < ActionMailbox::TestCase
  test 'multipart feedback parts without filenames survive the full mailbox path' do
    recipient = users(:member_normal)
    notification = Notification.create!(kind: 'membership_created', subject: groups(:group), actor: users(:admin))
    delivery = NotificationDelivery.create!(notification: notification, recipient: recipient, channel: 'email',
      email_address: recipient.email, provider_message_id: 'ses-mailbox-message')
    mail = Mail.new
    mail.from = 'MAILER-DAEMON@us-east-1.amazonses.com'
    mail.to = ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS
    mail['Authentication-Results'] = 'mx.loomio.test; dkim=pass header.d=amazonses.com'
    mail.content_type = 'multipart/report; report-type=delivery-status'
    mail.add_part(Mail::Part.new(content_type: 'text/plain', body: 'Delivery failed'))
    mail.add_part(Mail::Part.new(content_type: 'message/delivery-status', body:
      "Final-Recipient: rfc822; #{recipient.email}\r\nAction: failed\r\nStatus: 5.1.1\r\n"))
    mail.add_part(Mail::Part.new(content_type: 'text/rfc822-headers', body:
      "Message-ID: <ses-mailbox-message@amazonses.com>\r\nTo: #{recipient.email}\r\n"))

    assert_difference -> { recipient.reload.bounces_count }, 1 do
      receive_inbound_email_from_source(mail.to_s)
    end
    assert_equal 'bounced', delivery.events.sole.kind
    assert ReceivedEmail.last.released?
  end
end

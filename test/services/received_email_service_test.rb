require 'test_helper'

class ReceivedEmailServiceTest < ActiveSupport::TestCase

  # -- Splitting replies --

  test "splits spanish text reply" do
    input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a. m., Deborah Mowesley (via Loomio) <\nnotifications@loomio.com> escribió:\n\n> \n>\n> [image: DM] sondeo cerrará en 24 horas\n>"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Me aparece que cumpla con los Criterio?", output_body
  end

  test "splits spanish html reply" do
    input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a.Â m., Deborah Mowesley (via Loomio) <notifications@loomio.com> escribiÃ³:\n\nï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿\n\nDM\n\n---------------------------\nsondeo cerrarÃ¡ en 24 horas\n---------------------------"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Me aparece que cumpla con los Criterio?", output_body
  end

  test "splits reply on wrote line" do
    input_body = "Yep, I'm happy for folks to jump in this week\nJ\n\nOn Tue, 7 Mar 2023 at 3:51 PM, jon g (via Loomio) <notifications@loomio.com> wrote:\n\nsome quoted text"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Yep, I'm happy for folks to jump in this week\nJ", output_body
  end

  test "splits on Loomio notifications address" do
    input_body = "Hi I'm the bit you want\n      On someday (Loomio) #{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS} said:\n      This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on reply delimiter" do
    input_body = "Hi I'm the bit you want\n      #{EventMailer::REPLY_DELIMITER}\n      This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on signature" do
    input_body = "Hi I'm the bit you want\n      --\n      This is the bit that you don't want"
    output_body = ReceivedEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on author name signature" do
    author_name = "Charles Barclay"
    input_body = "Hi I'm the bit you want\n\n      Charles Barclay\n      CEO\n      Some company\n      +35 223333333\n      \"Massive email signatures mean youre very professional\"\n      "
    output_body = ReceivedEmailService.extract_reply_body(input_body, author_name)
    assert_equal "Hi I'm the bit you want", output_body
  end

  # -- Subject stripping --

  test "strips re and fwd prefixes from subject lines" do
    subjects = [
      "Re: repairing the is fwd software",
      "Fwd: repairing the is fwd software",
      "RE: FW: repairing the is fwd software",
      "FW: RE: RE: repairing the is fwd software",
      " FW repairing the is fwd software",
      "RE repairing the is fwd software",
      "RE FWD: repairing the is fwd software",
      "RE: FW repairing the is fwd software",
    ]
    subjects.each do |line|
      assert_equal "repairing the is fwd software", line.gsub(/^( *(re|fwd?)(:| ) *)+/i, ''),
        "Failed to strip: #{line}"
    end
  end

  # -- Email routing integration --

  test "creates a comment for personal email-to-thread route" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'EmailUser', email: "emailuser#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "emailuser#{SecureRandom.hex(4)}")
    group = Group.create!(name: 'Email Group', handle: "emailgroup#{SecureRandom.hex(4)}")
    group.add_member!(user)
    discussion = create_discussion(group: group, author: user)

    route_local = "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
    to = "#{route_local}@#{ENV['REPLY_HOSTNAME']}"
    from = "\"#{user.name}\" <#{user.email}>"

    email = ReceivedEmail.create!(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Test Subject' },
      body_text: "Hello from email"
    )

    assert_difference 'Comment.count', 1 do
      ReceivedEmailService.route(email)
    end

    assert email.reload.released
    comment = Comment.last
    assert_equal discussion.id, comment.discussion_id
    assert_equal user.id, comment.user_id
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "creates a discussion for group handle" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'GroupEmailUser', email: "groupemail#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "groupemail#{SecureRandom.hex(4)}")
    handle = "grp#{SecureRandom.hex(4)}"
    group = Group.create!(name: 'Group Email', handle: handle)
    group.add_member!(user)

    from = "\"#{user.name}\" <#{user.email}>"
    to = "#{handle}@#{ENV['REPLY_HOSTNAME']}"

    email = ReceivedEmail.create!(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'New thread via email' },
      body_text: "Thread body"
    )

    assert_difference 'Discussion.count', 1 do
      ReceivedEmailService.route(email)
    end

    discussion = Discussion.order(:id).last
    assert_equal group.id, discussion.group_id
    assert_equal 'New thread via email', discussion.title
    assert email.reload.released
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "forwards using a forward rule" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    rule = ForwardEmailRule.create!(handle: "fwd#{SecureRandom.hex(4)}", email: 'target@example.com')

    user = User.create!(name: 'FwdUser', email: "fwduser#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "fwduser#{SecureRandom.hex(4)}")
    from = "\"#{user.name}\" <#{user.email}>"
    to = "#{rule.handle}@#{ENV['REPLY_HOSTNAME']}"

    email = ReceivedEmail.create!(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Forward me' },
      body_text: "Forward body text",
      body_html: "<p>Forward body html</p>"
    )

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      ReceivedEmailService.route(email)
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_includes delivered.to, rule.email
    assert_equal 'Forward me', delivered.subject

    assert_not ReceivedEmail.where(id: email.id).exists?
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  # -- Bounce handling --

  test "bounce email increments bounces_count" do
    bounce_address = ENV.fetch('BOUNCE_ADDRESS', "bounce@email-abuse.amazonses.com")
    hex = SecureRandom.hex(4)
    user = User.create!(name: "BounceUser#{hex}", email: "bounceuser#{hex}@example.com",
                        email_verified: true, username: "bounceuser#{hex}")

    dsn_body = <<~DSN
      Reporting-MTA: dns; a27-24.smtp-out.us-west-2.amazonses.com
      Arrival-Date: Wed, 08 Apr 2026 12:00:00 +0000

      Final-Recipient: rfc822; #{user.email}
      Original-Recipient: rfc822; #{user.email}
      Action: failed
      Status: 5.1.1
      Diagnostic-Code: smtp; 550 5.1.1 user unknown
      Last-Attempt-Date: Wed, 08 Apr 2026 12:00:05 +0000
    DSN

    email = ReceivedEmail.create!(
      headers: { from: bounce_address, to: "anything@example.com" },
      body_text: "The following message was undeliverable."
    )
    email.attachments.attach(
      io: StringIO.new(dsn_body),
      filename: "delivery-status.txt",
      content_type: "message/delivery-status"
    )

    assert_difference -> { user.reload.bounces_count }, 1 do
      ReceivedEmailService.route(email)
    end
    assert email.reload.released
  end

  test "bounce email excludes notifications address and finds recipient" do
    bounce_address = ENV.fetch('BOUNCE_ADDRESS', "bounce@email-abuse.amazonses.com")
    hex = SecureRandom.hex(4)
    user = User.create!(name: "BounceUser#{hex}", email: "bounceuser#{hex}@example.com",
                        email_verified: true, username: "bounceuser#{hex}")

    # DSN contains both the notifications address and the bounced user address
    dsn_body = <<~DSN
      From: #{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS}
      To: #{user.email}
      Final-Recipient: rfc822; #{user.email}
    DSN

    email = ReceivedEmail.create!(
      headers: { from: bounce_address, to: "anything@example.com" },
      body_text: "Delivery failed"
    )
    email.attachments.attach(
      io: StringIO.new(dsn_body),
      filename: "delivery-status.txt",
      content_type: "message/delivery-status"
    )

    assert_difference -> { user.reload.bounces_count }, 1 do
      ReceivedEmailService.route(email)
    end
  end

  test "bounce email without matching user still marks released" do
    bounce_address = ENV.fetch('BOUNCE_ADDRESS', "bounce@email-abuse.amazonses.com")

    email = ReceivedEmail.create!(
      headers: { from: bounce_address, to: "anything@example.com" },
      body_text: "Delivery failed"
    )
    email.attachments.attach(
      io: StringIO.new("Final-Recipient: rfc822; nonexistent@example.com"),
      filename: "delivery-status.txt",
      content_type: "message/delivery-status"
    )

    ReceivedEmailService.route(email)
    assert email.reload.released
  end

  test "complaint email increments complaints_count" do
    complaints_address = ENV.fetch('COMPLAINTS_ADDRESS', "complaints@email-abuse.amazonses.com")
    user = User.create!(name: 'ComplaintUser', email: "complaintuser#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "complaintuser#{SecureRandom.hex(4)}")

    email = ReceivedEmail.create!(
      headers: { from: complaints_address, to: "anything@example.com" },
      body_text: "Complaint received"
    )
    email.attachments.attach(
      io: StringIO.new("From: #{user.email}\nTo: notifications@loomio.com"),
      filename: "complaint-report.txt",
      content_type: "message/feedback-report"
    )

    assert_difference -> { user.reload.complaints_count }, 1 do
      ReceivedEmailService.route(email)
    end
    assert email.reload.released
  end
end

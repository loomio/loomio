require 'test_helper'

class InboundEmailServiceTest < ActiveSupport::TestCase
  inline_jobs 'releases personal email-to-thread route when reply exceeds comment length limit',
    'an empty emailed reply reports its actual validation error',
    'a comment validation exception reports its messages',
    'forwards using a forward rule',
    'forwards from an SMTP envelope recipient and replies to the original sender'

  test "failed routing-rule refresh preserves the previous rules" do
    rule = ForwardEmailRule.create!(handle: "keep", email: "keep@example.com")
    ForwardEmailRule.stub(:insert_all!, ->(*) { raise "insert failed" }) do
      assert_raises(RuntimeError) { InboundEmailService.refresh_forward_email_rules }
    end
    assert ForwardEmailRule.exists?(rule.id)
  end

  test "unknown sender assignment rolls back when notification creation fails" do
    group = groups(:group)
    email = build_inbound_email(headers: {from: 'unknown@example.test', to: "#{group.handle}@#{ENV.fetch('REPLY_HOSTNAME')}"}, body_text: 'Unknown sender')
    NotificationService.stub(:create!, ->(**) { raise 'notification failed' }) do
      assert_raises(RuntimeError) { InboundEmailService.process(email) }
    end
    assert_empty PendingEmail.where(inbound_email: email)
    assert_nil email.reload.processing_completed_at
  end

  # -- Splitting replies --

  test 'emailed attachments obey the topic restriction for members and thread admins' do
    topic = topics(:discussion_topic)
    topic.update!(attachments_admin_only: true)

    %i[member_normal guest_admin_normal].each do |role|
      user = users(role)
      mail = Mail.new
      mail.from = user.email
      mail.to = "d=#{topic.topicable_id}&u=#{user.id}&k=#{user.email_api_key}@#{ENV.fetch('REPLY_HOSTNAME')}"
      mail.subject = 'Supporting document'
      mail.body = 'Please see the attached document'
      mail.attachments['document.txt'] = 'Supporting document'
      email = store_inbound_mail(mail)

      assert_difference 'Comment.count', role == :guest_admin_normal ? 1 : 0 do
        assert_equal role == :guest_admin_normal ? :delivered : :bounced, InboundEmailService.process(email)
      end
      assert email.reload.processing_completed_at
    end
  end

  test "splits spanish text reply" do
    input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a. m., Deborah Mowesley (via Loomio) <\nnotifications@loomio.com> escribió:\n\n> \n>\n> [image: DM] sondeo cerrará en 24 horas\n>"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Me aparece que cumpla con los Criterio?", output_body
  end

  test "splits spanish html reply" do
    input_body = "Me aparece que cumpla con los Criterio?\n\nEl lun, 3 de jun. de 2024 7:03 a.Â m., Deborah Mowesley (via Loomio) <notifications@loomio.com> escribiÃ³:\n\nï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿ï»¿\n\nDM\n\n---------------------------\nsondeo cerrarÃ¡ en 24 horas\n---------------------------"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Me aparece que cumpla con los Criterio?", output_body
  end

  test "splits reply on wrote line" do
    input_body = "Yep, I'm happy for folks to jump in this week\nJ\n\nOn Tue, 7 Mar 2023 at 3:51 PM, jon g (via Loomio) <notifications@loomio.com> wrote:\n\nsome quoted text"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Yep, I'm happy for folks to jump in this week\nJ", output_body
  end

  test "splits on Loomio notifications address" do
    input_body = "Hi I'm the bit you want\n      On someday (Loomio) #{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS} said:\n      This is the bit that you don't want"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on reply delimiter" do
    input_body = "Hi I'm the bit you want\n      #{NotificationMailer::REPLY_DELIMITER}\n      This is the bit that you don't want"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on signature" do
    input_body = "Hi I'm the bit you want\n      --\n      This is the bit that you don't want"
    output_body = InboundEmailService.extract_reply_body(input_body)
    assert_equal "Hi I'm the bit you want", output_body
  end

  test "splits on author name signature" do
    author_name = "Charles Barclay"
    input_body = "Hi I'm the bit you want\n\n      Charles Barclay\n      CEO\n      Some company\n      +35 223333333\n      \"Massive email signatures mean youre very professional\"\n      "
    output_body = InboundEmailService.extract_reply_body(input_body, author_name)
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
    discussion = DiscussionService.create(params: { title: "Test", group_id: group.id }, actor: user)

    route_local = "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
    to = "#{route_local}@#{ENV['REPLY_HOSTNAME']}"
    from = "\"#{user.name}\" <#{user.email}>"

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Test Subject' },
      body_text: "Hello from email"
    )

    assert_difference 'Comment.count', 1 do
      InboundEmailService.process(email)
    end

    assert email.reload.processing_completed_at.present?
    comment = Comment.last
    assert_equal discussion.id, comment.topic.topicable_id
    assert_equal user.id, comment.user_id
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "releases personal email-to-thread route when reply exceeds comment length limit" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'LongReplyUser', email: "longreply#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "longreply#{SecureRandom.hex(4)}")
    group = Group.create!(name: 'Long Reply Group', handle: "longreplygroup#{SecureRandom.hex(4)}")
    group.add_member!(user)
    discussion = DiscussionService.create(params: { title: "Test", group_id: group.id, comment_length_max: 10 }, actor: user)

    route_local = "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
    to = "#{route_local}@#{ENV['REPLY_HOSTNAME']}"
    from = "\"#{user.name}\" <#{user.email}>"

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Test Subject' },
      body_text: "This reply is too long"
    )

    assert_no_difference 'Comment.count' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        InboundEmailService.process(email)
      end
    end

    assert email.reload.processing_completed_at.present?
    delivered = ActionMailer::Base.deliveries.last
    assert_includes delivered.to, user.email
    assert_equal 'Your reply was not posted', delivered.subject
    assert_includes delivered.text_part.body.to_s, I18n.t("comment_form.messages.too_long", count: 10)
    refute_includes delivered.text_part.body.to_s, "longer than the thread"
    assert_includes delivered.text_part.body.to_s, discussion.key
    assert_includes delivered.html_part.body.to_s, "open the thread"
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test 'an empty emailed reply reports its actual validation error' do
    email = build_comment_reply(body_text: '')

    assert_no_difference 'Comment.count' do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        InboundEmailService.process(email)
      end
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_equal [users(:admin).email], delivered.to
    assert_includes delivered.text_part.body.to_s, "Body can't be blank"
    assert_includes delivered.html_part.body.to_s, "Body can't be blank"
    refute_includes delivered.text_part.body.to_s, 'character limit'
    assert email.reload.processing_completed_at.present?
  end

  test 'a comment validation exception reports its messages' do
    email = build_comment_reply(body_text: 'Reply')
    reject_comment = ->(comment:, actor:) do
      comment.errors.add(:body, '<validation detail>')
      raise ActiveRecord::RecordInvalid, comment
    end

    CommentService.stub(:create, reject_comment) do
      assert_no_difference 'Comment.count' do
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          InboundEmailService.process(email)
        end
      end
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_includes delivered.text_part.body.to_s, 'Body <validation detail>'
    assert_includes delivered.html_part.body.to_s, '&lt;validation detail&gt;'
    refute_includes delivered.html_part.body.to_s, '<validation detail>'
  end

  test 'validation failures in dependent records retry without sending a comment rejection' do
    email = build_comment_reply(body_text: 'Valid reply')
    invalid_item = TopicItem.new
    invalid_item.errors.add(:base, 'Internal timeline error')

    TopicItems::NewComment.stub(:create!, ->(**) { raise ActiveRecord::RecordInvalid, invalid_item }) do
      assert_no_difference ['Comment.count', 'TopicItem.count'] do
        assert_no_enqueued_jobs only: InboundEmailDeliveryJob do
          error = assert_raises(ActiveRecord::RecordInvalid) { InboundEmailService.process(email) }
          assert_same invalid_item, error.record
        end
      end
    end
    assert_nil email.reload.processing_completed_at
  end

  test 'validation rejection emails remain limited to one per sender per hour' do
    emails = 2.times.map { build_comment_reply(body_text: '') }

    assert_no_difference 'Comment.count' do
      assert_enqueued_jobs 1, only: InboundEmailDeliveryJob do
        emails.each { |email| InboundEmailService.process(email) }
      end
    end
    emails.each { |email| assert email.reload.processing_completed_at.present? }
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

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'New thread via email' },
      body_text: "Thread body"
    )

    assert_difference 'Discussion.count', 1 do
      InboundEmailService.process(email)
    end

    discussion = Discussion.order(:id).last
    assert_equal group.id, discussion.group_id
    assert_equal 'New thread via email', discussion.title
    assert email.reload.processing_completed_at.present?
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "does not attribute a DMARC failure to a group member" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'SpoofedEmailUser', email: "spoofed#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "spoofed#{SecureRandom.hex(4)}")
    handle = "spoofed#{SecureRandom.hex(4)}"
    group = Group.create!(name: 'Spoofed Email Group', handle: handle)
    group.add_member!(user)

    email = build_inbound_email(
      headers: {
        'From' => "\"#{user.name}\" <#{user.email}>",
        'To' => "#{handle}@#{ENV['REPLY_HOSTNAME']}",
        'Subject' => 'Spoofed thread',
        'Authentication-Results' => 'mx.test.host; spf=fail; dkim=none; dmarc=fail header.from=example.com'
      },
      body_text: 'This must not be attributed to the member'
    )

    assert_no_difference 'Discussion.count' do
      assert_difference -> { Notification.where(kind: "unknown_sender").count }, 1 do
        InboundEmailService.process(email)
      end
    end

    assert email.reload.processing_completed_at
    assert_equal group.id, PendingEmail.find_by!(inbound_email: email).group_id
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

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Forward me' },
      body_text: "Forward body text",
      body_html: "<p>Forward body html</p>"
    )

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      InboundEmailService.process(email)
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_includes delivered.to, rule.email
    assert_equal 'Forward me', delivered.subject

    assert email.reload.processing_completed_at.present?
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "forwards from an SMTP envelope recipient and replies to the original sender" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    rule = ForwardEmailRule.create!(handle: "staff#{SecureRandom.hex(4)}", email: 'staff@example.net')
    sender_email = "sender#{SecureRandom.hex(4)}@example.com"
    email = build_inbound_email(
      headers: {
        'From' => "Original Sender <#{sender_email}>",
        'To' => 'Public address <hello@example.org>',
        'Subject' => 'Forwarded staff message',
        'harakadata' => {
          mail_from: 'list-bounces@example.org',
          rcpt_to: ["#{rule.handle}@#{ENV['REPLY_HOSTNAME']}"]
        }.to_json
      },
      body_text: 'Forwarded message body'
    )

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      InboundEmailService.process(email)
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_equal [rule.email], delivered.to
    assert_equal [sender_email], delivered.reply_to
    assert email.reload.processing_completed_at.present?
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  # -- Handle redirect routing --

  test "routes email to group via retired handle" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'RedirectEmailUser', email: "redirectemail#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "redirectemail#{SecureRandom.hex(4)}")
    old_handle = "oldhandle#{SecureRandom.hex(4)}"
    new_handle = "newhandle#{SecureRandom.hex(4)}"
    group = Group.create!(name: 'Redirect Group', handle: old_handle)
    group.add_admin!(user)
    group.add_member!(user)
    GroupService.update_handle(group: group, handle: new_handle, actor: user)

    from = "\"#{user.name}\" <#{user.email}>"
    to = "#{old_handle}@#{ENV['REPLY_HOSTNAME']}"

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Thread via retired handle' },
      body_text: "Thread body"
    )

    assert_difference 'Discussion.count', 1 do
      InboundEmailService.process(email)
    end

    discussion = Discussion.order(:id).last
    assert_equal group.id, discussion.group_id
    assert email.reload.processing_completed_at.present?
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  test "routes personal email-to-group via retired handle" do
    original_reply = ENV['REPLY_HOSTNAME']
    ENV['REPLY_HOSTNAME'] = 'test.host'

    user = User.create!(name: 'PersRedirectUser', email: "persredirect#{SecureRandom.hex(4)}@example.com",
                        email_verified: true, username: "persredirect#{SecureRandom.hex(4)}")
    old_handle = "persold#{SecureRandom.hex(4)}"
    new_handle = "persnew#{SecureRandom.hex(4)}"
    group = Group.create!(name: 'PersRedirect Group', handle: old_handle)
    group.add_admin!(user)
    group.add_member!(user)
    GroupService.update_handle(group: group, handle: new_handle, actor: user)

    from = "\"#{user.name}\" <#{user.email}>"
    to = "#{old_handle}+u=#{user.id}&k=#{user.email_api_key}@#{ENV['REPLY_HOSTNAME']}"

    email = build_inbound_email(
      headers: { 'From' => from, 'To' => to, 'Subject' => 'Personal thread via retired handle' },
      body_text: "Personal thread body"
    )

    if AppConfig.app_features[:thread_from_mail]
      assert_difference 'Discussion.count', 1 do
        InboundEmailService.process(email)
      end

      discussion = Discussion.order(:id).last
      assert_equal group.id, discussion.group_id
      assert email.reload.processing_completed_at.present?
    end
  ensure
    ENV['REPLY_HOSTNAME'] = original_reply
  end

  private

  def build_comment_reply(body_text:)
    user = users(:admin)
    discussion = discussions(:discussion)
    route = "d=#{discussion.id}&u=#{user.id}&k=#{user.email_api_key}"
    build_inbound_email(
      headers: {from: user.email, to: "#{route}@#{ENV.fetch('REPLY_HOSTNAME')}"},
      body_text: body_text
    )
  end
end

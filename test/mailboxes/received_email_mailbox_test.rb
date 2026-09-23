require 'test_helper'

class ReceivedEmailMailboxTest < ActionMailbox::TestCase
  inline_jobs "email from alias creates notification",
              "mailing list envelope recipient creates an unknown sender notification"
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "mboxuser#{hex}", email: "mboxuser#{hex}@example.com", username: "mboxuser#{hex}", email_verified: true)
    @alien = User.create!(name: "mboxother#{hex}", email: "mboxother#{hex}@example.com", username: "mboxother#{hex}", email_verified: true)
    @group = Group.new(name: "mboxgroup#{hex}", group_privacy: 'secret', handle: "mboxgroup#{hex}")
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)
    @group.add_member!(@alien)

    @discussion = DiscussionService.create(params: { title: "Mbox Discussion #{hex}", group_id: @group.id }, actor: @user)

    @poll = PollService.create(params: {
      title: "Mbox Poll #{hex}",
      poll_type: 'proposal',
      topic_id: @discussion.topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @user)

    @comment = Comment.new(parent: @discussion, body: "parent comment")
    CommentService.create(comment: @comment, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  test "ignores emails from reply_hostname" do
    ForwardEmailRule.create!(handle: 'homer', email: "homer@simpson.com")

    receive_inbound_email_from_mail(
      to: "homer@reply.loomio.test",
      from: "someone@reply.loomio.test",
      subject: "anything in the subject",
      body: "body example"
    )

    assert_empty ActionMailer::Base.deliveries
  end

  test "decodes RFC 2047 encoded subject headers" do
    to_address = "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}"

    raw_email = Mail.new do
      from    "mboxuser@example.com"
      to      to_address
      subject "=?UTF-8?Q?Caf=C3=A9_discussion_about_na=C3=AFve_approach?="
      body    "Test body with encoded subject"
    end
    # Set from to match the user's email for routing
    raw_email.from = @user.name_and_email

    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_source(raw_email.to_s)
    end

    email = ReceivedEmail.last
    assert_equal 'Café discussion about naïve approach', email.headers['Subject']
    assert_equal 'Café discussion about naïve approach', Discussion.last.title
  end

  test "decodes RFC 2047 encoded from headers" do
    to_address = "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}"

    raw_email = Mail.new do
      to      to_address
      subject "Test subject"
      body    "Test body"
    end
    raw_email.from = "=?UTF-8?Q?Bj=C3=B6rk?= <#{@user.email}>"

    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_source(raw_email.to_s)
    end

    email = ReceivedEmail.last
    assert_includes email.headers['From'], 'Björk'
  end

  test "creates a reply to comment via email" do
    assert_difference 'Comment.count', 1 do
      receive_inbound_email_from_mail(
        to: "c=#{@comment.id}&d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        from: "someone@gmail.com",
        body: "reply to comment via email"
      )
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @comment, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal 'reply to comment via email', c.body
  end

  test "creates a comment on a poll via email" do
    assert_difference 'Comment.count', 1 do
      receive_inbound_email_from_mail(
        from: "hello@example.com",
        to: "pt=p&pi=#{@poll.id}&d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        body: "comment on a poll via email"
      )
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @poll, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal "comment on a poll via email", c.body
  end

  test "creates a comment via email without a parent" do
    assert_difference 'Comment.count', 1 do
      receive_inbound_email_from_mail(
        from: "hello@example.com",
        to: "d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
        body: "comment via email without a parent"
      )
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @discussion, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal 'comment via email without a parent', c.body
  end

  test "invalid group handle" do
    assert_no_difference 'Discussion.count' do
      receive_inbound_email_from_mail(
        from: @user.name_and_email,
        to: "invalid@#{ENV['REPLY_HOSTNAME']}",
        subject: "the topic at hand",
        body: "greetings earthlings"
      )
    end
  end

  test "member email starts a discussion" do
    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_mail(
        from: @user.name_and_email,
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        subject: "the topic at hand",
        body: "greetings earthlings"
      )
    end
    d = Discussion.last
    assert_equal @user, d.author
    assert_equal @group.handle, d.group.handle
    assert_equal "greetings earthlings", d.body
    e = ReceivedEmail.last
    assert_equal true, e.released
    assert_equal @group.id, e.group_id
  end

  test "duplicate Message-ID creates one discussion" do
    message_id = "duplicate-#{SecureRandom.hex(4)}@example.com"
    sender = @user.name_and_email
    recipient = "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}"
    source = ->(uuid) do
      raw_email = Mail.new do
        from       sender
        to         recipient
        subject    'Retried inbound email'
        message_id message_id
        body       'This message must create one thread'
      end
      raw_email['harakadata'] = {
        rcpt_to: [recipient],
        uuid: uuid
      }.to_json
      raw_email.to_s
    end

    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_source(source.call('first-delivery'))
      receive_inbound_email_from_source(source.call('retried-delivery'))
    end

    assert_equal 1, ReceivedEmail.where(message_id: message_id).count
    assert_equal ['delivered', 'delivered'], ActionMailbox::InboundEmail.where(message_id: message_id).order(:id).map(&:status)
  end

  test "duplicate Message-ID forwards one copy to a staff mailbox" do
    rule = ForwardEmailRule.create!(handle: "staff#{SecureRandom.hex(4)}", email: 'staff@example.net')
    message_id = "duplicate-forward-#{SecureRandom.hex(4)}@example.com"
    recipient = "#{rule.handle}@#{ENV['REPLY_HOSTNAME']}"
    sender = 'original-sender@example.com'
    source = ->(uuid) do
      raw_email = Mail.new do
        from       sender
        to         'Public address <hello@example.org>'
        subject    'Retried staff email'
        message_id message_id
        body       'This message must be forwarded once'
      end
      raw_email['harakadata'] = { rcpt_to: [recipient], uuid: uuid }.to_json
      raw_email.to_s
    end

    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      receive_inbound_email_from_source(source.call('first-delivery'))
      receive_inbound_email_from_source(source.call('retried-delivery'))
    end

    delivered = ActionMailer::Base.deliveries.last
    assert_equal [rule.email], delivered.to
    assert_equal [sender], delivered.reply_to
    assert ReceivedEmail.find_by!(message_id: message_id).released
  end

  test "email from alias creates notification" do
    receive_inbound_email_from_mail(
      from: 'alias@gmail.com',
      to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
      subject: "the topic at hand",
      body: "greetings earthlings"
    )

    email = ReceivedEmail.last
    assert_equal false, email.released
    assert_equal @group.id, email.group_id
    notification = Notification.find_by!(kind: "unknown_sender", subject: email)
    assert_equal @group.admins.pluck(:id), notification.notification_deliveries.pluck(:recipient_id)
  end

  test "mailing list envelope recipient creates an unknown sender notification" do
    raw_email = Mail.new do
      from    'mailing-list-sender@example.com'
      to      'Mailing list <list@example.com>'
      subject 'Mailing list message'
      body    'Message delivered through a mailing list'
    end
    raw_email['harakadata'] = {
      mail_from: 'list-bounces@example.com',
      rcpt_to: ["#{@group.handle}@#{ENV['REPLY_HOSTNAME']}"]
    }.to_json

    assert_difference -> { Notification.where(kind: "unknown_sender").count }, 1 do
      receive_inbound_email_from_source(raw_email.to_s)
    end

    email = ReceivedEmail.last
    assert_equal false, email.released
    assert_equal @group.id, email.group_id
    assert_equal 'mailing-list-sender@example.com', email.sender_email
    notification = Notification.find_by!(kind: "unknown_sender", subject: email)
    assert_equal @group.admins.pluck(:id), notification.notification_deliveries.pluck(:recipient_id)
  end

  test "validated member alias starts a discussion" do
    MemberEmailAlias.create!(
      user_id: @user.id,
      email: 'memberalias@example.com',
      group_id: @group.id,
      author_id: @group.admins.first.id
    )

    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_mail(
        from: 'memberalias@example.com',
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        subject: "the topic at hand",
        body: "greetings earthlings"
      )
    end
    d = Discussion.last
    assert_equal @user, d.author
    assert_equal @group.handle, d.group.handle
    assert_equal "greetings earthlings", d.body
    e = ReceivedEmail.last
    assert_equal true, e.released
    assert_equal @group.id, e.group_id
  end

  test "blocked member alias does not start discussion" do
    MemberEmailAlias.create!(
      user_id: nil,
      email: 'blockedalias@example.com',
      group_id: @group.id,
      author_id: @group.admins.first.id
    )

    assert_no_difference 'Discussion.count' do
      receive_inbound_email_from_mail(
        from: 'blockedalias@example.com',
        to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
        subject: "the topic at hand",
        body: "greetings earthlings"
      )
    end
    e = ReceivedEmail.last
    assert_equal false, e.released
    assert_nil e.group_id
  end
end

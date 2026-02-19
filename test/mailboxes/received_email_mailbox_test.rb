require 'test_helper'

class ReceivedEmailMailboxTest < ActionMailbox::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "mboxuser#{hex}", email: "mboxuser#{hex}@example.com", username: "mboxuser#{hex}", email_verified: true)
    @another_user = User.create!(name: "mboxother#{hex}", email: "mboxother#{hex}@example.com", username: "mboxother#{hex}", email_verified: true)
    @group = Group.new(name: "mboxgroup#{hex}", group_privacy: 'secret', handle: "mboxgroup#{hex}")
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)
    @group.add_member!(@another_user)

    @discussion = Discussion.new(title: "Mbox Discussion #{hex}", group: @group, author: @user)
    DiscussionService.create(discussion: @discussion, actor: @user)

    @poll = Poll.new(
      title: "Mbox Poll #{hex}",
      poll_type: 'proposal',
      group: @group,
      discussion: @discussion,
      author: @user,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    PollService.create(poll: @poll, actor: @user)

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
    assert_equal @discussion, c.discussion
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
    assert_equal @discussion, c.discussion
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
    assert_equal @discussion, c.discussion
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
    assert_equal 1, Event.where(kind: 'unknown_sender').count
    assert_equal 1, Notification.where(user_id: @group.admins.pluck(:id)).count
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

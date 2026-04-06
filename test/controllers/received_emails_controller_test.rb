require 'test_helper'

class ReceivedEmailsControllerTest < ActionController::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "reuser#{hex}", email: "reuser#{hex}@example.com", username: "reuser#{hex}", email_verified: true)
    @alien = User.create!(name: "reother#{hex}", email: "reother#{hex}@example.com", username: "reother#{hex}", email_verified: true)
    @group = Group.new(name: "regroup#{hex}", group_privacy: 'secret', handle: "regroup#{hex}")
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)
    @group.add_member!(@alien)

    @discussion = DiscussionService.create(params: { title: "RE Discussion #{hex}", group_id: @group.id }, actor: @user)

    @poll = PollService.create(params: {
      title: "RE Poll #{hex}",
      poll_type: 'proposal',
      topic_id: @discussion.topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @user)

    @comment = Comment.new(parent: @discussion, body: "parent comment")
    CommentService.create(comment: @comment, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  private

  def mailin_params(token: "handle+u=123&k=123",
                    to: nil,
                    from: 'Suzy Senderson <sender@gmail.com>',
                    subject: "re: an important discussion",
                    body: "Hi everybody, this is my message!")
    to ||= "Loomio Group <#{token}@#{ENV['REPLY_HOSTNAME']}>"
    {
      mailinMsg: {
        html: "<html><body>#{body}</body></html>",
        text: body,
        headers: {
          from: from,
          to: to,
          subject: subject
        }
      }.to_json
    }
  end

  public

  test "ignores emails from reply_hostname" do
    ForwardEmailRule.create!(handle: 'homer', email: "homer@loomio.com")
    h = mailin_params(
      to: "homer@#{ENV['REPLY_HOSTNAME']}",
      body: "yo this is for contact",
      from: "homer@#{ENV['REPLY_HOSTNAME']}"
    )
    post :create, params: h
    assert_empty ActionMailer::Base.deliveries
  end

  test "forwards specific emails to contact" do
    ForwardEmailRule.create!(handle: 'homer', email: "homer@simpson.com")
    h = mailin_params(
      to: "homer@#{ENV['REPLY_HOSTNAME']}",
      body: "yo this is for contact"
    )
    post :create, params: h
    last_email = ActionMailer::Base.deliveries.last
    assert_includes last_email.to, "homer@simpson.com"
  end

  test "creates a reply to comment via email" do
    h = mailin_params(
      to: "c=#{@comment.id}&d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
      body: "yo"
    )
    assert_difference 'Comment.count', 1 do
      post :create, params: h
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @comment, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal 'yo', c.body
  end

  test "creates a comment on a poll via email" do
    h = mailin_params(
      to: "pt=p&pi=#{@poll.id}&d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
      body: "yo"
    )
    assert_difference 'Comment.count', 1 do
      post :create, params: h
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @poll, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal "yo", c.body
  end

  test "creates a comment via email without a parent" do
    h = mailin_params(
      to: "d=#{@discussion.id}&u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
      body: "yo"
    )
    assert_difference 'Comment.count', 1 do
      post :create, params: h
    end
    c = Comment.last
    assert_equal @user, c.author
    assert_equal @discussion, c.parent
    assert_equal @discussion, c.topic.discussion
    assert_equal 'yo', c.body
  end

  test "starts a discussion in a group" do
    h = mailin_params(
      to: "#{@group.handle}+u=#{@user.id}&k=#{@user.email_api_key}@#{ENV['REPLY_HOSTNAME']}",
      body: "yo I am a discussion"
    )
    assert_difference 'Discussion.count', 1 do
      post :create, params: h
    end
    d = Discussion.last
    assert_equal @user, d.author
    assert_equal "yo I am a discussion", d.body
  end

  test "invalid group handle" do
    h = mailin_params(
      from: @user.name_and_email,
      to: "invalid@#{ENV['REPLY_HOSTNAME']}",
      subject: "the topic at hand",
      body: "greetings earthlings"
    )
    assert_no_difference 'Discussion.count' do
      post :create, params: h
    end
  end

  test "member email starts a discussion" do
    h = mailin_params(
      from: @user.name_and_email,
      to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
      subject: "the topic at hand",
      body: "greetings earthlings"
    )
    assert_difference 'Discussion.count', 1 do
      post :create, params: h
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
    post :create, params: mailin_params(
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

    h = mailin_params(
      from: 'memberalias@example.com',
      to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
      subject: "the topic at hand",
      body: "greetings earthlings"
    )
    assert_difference 'Discussion.count', 1 do
      post :create, params: h
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

    h = mailin_params(
      from: 'blockedalias@example.com',
      to: "#{@group.handle}@#{ENV['REPLY_HOSTNAME']}",
      subject: "the topic at hand",
      body: "greetings earthlings"
    )
    assert_no_difference 'Discussion.count' do
      post :create, params: h
    end
    e = ReceivedEmail.last
    assert_equal false, e.released
    assert_nil e.group_id
  end
end

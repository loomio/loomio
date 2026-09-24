require 'test_helper'

class DigestMailerTest < ActionMailer::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "mailuser#{hex}", email: "mailuser#{hex}@example.com", username: "mailuser#{hex}", email_verified: true)
    @inviter = User.create!(name: "mailinviter#{hex}", email: "mailinviter#{hex}@example.com", username: "mailinviter#{hex}", email_verified: true)
    @group = Group.new(name: "Mailgroup #{hex}", group_privacy: 'secret', handle: "mailgroup#{hex}")
    @group.creator = @inviter
    @group.save!
    @group.add_admin!(@inviter)
    ActionMailer::Base.deliveries.clear
  end

  test "sends a digest email when there is unread content" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    author = @inviter
    discussion = DiscussionService.create(params: { title: "Digest #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
    comment = Comment.new(parent: discussion, body: "digest comment")
    CommentService.create(comment: comment, actor: author)
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      DigestMailer.digest(@user.id).deliver_now
    end
  end

  test "digest email leads with unseen notifications and uses an actionable subject" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    discussion_body = "Full discussion content #{SecureRandom.hex(4)}"
    discussion = DiscussionService.create(
      params: {
        title: "Mentioned digest #{SecureRandom.hex(4)}",
        description: discussion_body,
        group_id: @group.id
      },
      actor: @inviter
    )
    notification = Notification.create!(
      kind: "user_mentioned",
      subject: discussion.created_topic_item,
      actor: @inviter
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: notification.created_at,
      translation_values: {
        name: @inviter.name,
        title: discussion.title
      }
    )
    ActionMailer::Base.deliveries.clear

    mail = DigestMailer.digest(@user.id).deliver_now
    body = mail.body.encoded
    document = mail_document(mail)

    assert_equal "1 person mentioned you", mail.subject
    assert_includes document.at_css("main > h1").text, "Your #{AppConfig.theme[:site_name]} catch-up"
    assert_nil document.at_css(".email-header-logo")
    assert document.at_css(".email-footer-logo")
    assert document.at_css('a[href*="email_actions/catch_up"]')
    assert_operator body.index("Notifications"), :<, body.index("Unread threads")
    assert_nil document.at_css(".email-notification-content")
    assert_equal 1, document.text.scan(discussion_body).count
    assert_includes body, discussion.title
    assert_includes body, "Mark catch-up as read"
    assert_not_includes body, "empty.gif"
  end

  test "digest notification shows its headline while comment content appears once in the unread thread" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    discussion = DiscussionService.create(
      params: { title: "Comment digest #{SecureRandom.hex(4)}", group_id: @group.id },
      actor: @inviter
    )
    comment_body = "Complete notified comment #{SecureRandom.hex(8)}"
    topic_item = nil
    CommentService.create(
      comment: Comment.new(parent: discussion, body: comment_body),
      actor: @inviter
    ) { |item| topic_item = item }
    create_digest_notification(kind: "user_mentioned", subject: topic_item)

    mail = DigestMailer.digest(@user.id).deliver_now
    notification_heading = mail_document(mail).css(".email-notification").find { |element| element.text.include?(@inviter.name) }
    notification = notification_heading.parent

    assert_equal @inviter.name, notification_heading.at_css(".email-avatar")["alt"]
    assert_nil notification.at_css(".email-notification-content")
    assert_equal 1, mail_document(mail).text.scan(comment_body).count
  end

  test "digest renders an unknown sender notification" do
    @user.update!(email_catch_up_day: 7)
    @group.add_admin!(@user)
    received_email = ReceivedEmail.create!(
      group: @group,
      headers: { "From" => "Unknown Sender <unknown@example.com>" }
    )
    notification = Notification.create!(kind: "unknown_sender", subject: received_email, actor: nil)
    NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: notification.created_at,
      translation_values: { title: @group.full_name }
    )

    mail = DigestMailer.digest(@user.id).deliver_now
    notification_text = mail_document(mail).at_css(".email-notification").text

    assert_includes notification_text, "Please review email from unrecognised sender"
  end

  test "digest notification shows its headline while poll details appear once in the unread thread" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    poll_details = "Complete proposal details #{SecureRandom.hex(8)}"
    poll = PollService.create(
      params: {
        title: "Digest proposal #{SecureRandom.hex(4)}",
        details: poll_details,
        poll_type: "proposal",
        group_id: @group.id,
        poll_option_names: %w[agree disagree],
        closing_at: 5.days.from_now,
        notify_on_open: false
      },
      actor: @inviter
    )
    create_digest_notification(kind: "poll_announced", subject: poll.created_topic_item || poll)

    mail = DigestMailer.digest(@user.id).deliver_now
    document = mail_document(mail)

    assert_nil document.at_css(".email-notification-content")
    assert_equal 1, document.text.scan(poll_details).count
  end

  test "digest email includes discussions the user is a guest of" do
    @user.update!(email_catch_up_day: 7)
    # @user is NOT a member of @group — only a guest on the discussion
    title = "Guest digest #{SecureRandom.hex(4)}"
    discussion = DiscussionService.create(params: { title: title, group_id: @group.id }, actor: @inviter)
    discussion.topic.add_guest!(@user, @inviter)
    CommentService.create(comment: Comment.new(parent: discussion, body: "a comment"), actor: @inviter)
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      DigestMailer.digest(@user.id).deliver_now
    end

    assert_includes ActionMailer::Base.deliveries.last.body.encoded, title
  end

  test "digest email includes unread discussion and comment content from a followed group" do
    @user.update!(email_catch_up_day: 7)
    @group.update!(group_privacy: "open")
    GroupFollow.create!(group: @group, user: @user)
    discussion_body = "Followed discussion body #{SecureRandom.hex(4)}"
    comment_body = "Followed comment body #{SecureRandom.hex(4)}"
    discussion = DiscussionService.create(
      params: { title: "Followed digest #{SecureRandom.hex(4)}", description: discussion_body, group_id: @group.id },
      actor: @inviter
    )
    CommentService.create(comment: Comment.new(parent: discussion, body: comment_body), actor: @inviter)
    ActionMailer::Base.deliveries.clear

    mail = DigestMailer.digest(@user.id).deliver_now

    assert_includes mail.body.encoded, discussion_body
    assert_includes mail.body.encoded, comment_body
  end

  test "does not send digest when there is no unread content" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    ActionMailer::Base.deliveries.clear

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      DigestMailer.digest(@user.id).deliver_now
    end
  end

  test "does not send digest if unsubscribed" do
    @user.update!(email_catch_up_day: nil, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      DiscussionService.create(params: { title: "DigestUnsub #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDigestEmailWorker.new.perform
      end
    end
  end

  test "emails daily when digest schedule is 7" do
    @user.update!(email_catch_up_day: 7, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      DiscussionService.create(params: { title: "DigestDaily #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        SendDigestEmailWorker.new.perform
      end
    end
  end

  test "emails mondays when digest schedule is 1 at 6am" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      DiscussionService.create(params: { title: "DigestMon #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        SendDigestEmailWorker.new.perform
      end
    end
  end

  test "does not email mondays when digest schedule is 1 at 5am" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 5) do
      DiscussionService.create(params: { title: "DigestNo5am #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDigestEmailWorker.new.perform
      end
    end
  end

  test "does not email mondays when tuesday" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:tuesday).change(hour: 6) do
      DiscussionService.create(params: { title: "DigestTues #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDigestEmailWorker.new.perform
      end
    end
  end

  private

  def mail_document(mail)
    Nokogiri::HTML(mail.html_part&.body&.decoded || mail.body.decoded)
  end

  def create_digest_notification(kind:, subject:)
    itemable = subject.is_a?(TopicItem) ? subject.itemable : subject
    notification = Notification.create!(kind: kind, subject: subject, actor: @inviter)
    NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      delivered_at: notification.created_at,
      translation_values: {name: @inviter.name, title: itemable.title_model.title}
    )
    notification
  end
end

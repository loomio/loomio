require "test_helper"

class DigestQueryTest < ActiveSupport::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "digestuser#{hex}", email: "digestuser#{hex}@example.com", username: "digestuser#{hex}", email_verified: true)
    @actor = User.create!(name: "digestactor#{hex}", email: "digestactor#{hex}@example.com", username: "digestactor#{hex}", email_verified: true)
    @other_actor = User.create!(name: "digestother#{hex}", email: "digestother#{hex}@example.com", username: "digestother#{hex}", email_verified: true)
    @group = Group.new(name: "Digest group #{hex}", group_privacy: "secret", handle: "digestgroup#{hex}")
    @group.creator = @actor
    @group.save!
    @group.add_admin!(@actor)
    @group.add_member!(@user)
    @group.add_member!(@other_actor)
    @discussion = DiscussionService.create(params: { title: "Digest discussion #{hex}", group_id: @group.id }, actor: @actor)
    @time_start = 1.day.ago
    @time_finish = 1.minute.from_now
  end

  test "subject counts each vote to cast once" do
    polls = [create_poll, create_poll]
    create_notification(kind: "poll_announced", subject: polls.first)
    create_notification(kind: "poll_reminder", subject: polls.first)
    create_notification(kind: "poll_announced", subject: polls.second)

    assert_equal "You have 2 votes to cast", digest.subject(frequency: "daily", site_name: "Loomio")

    polls.each do |poll|
      poll.stances.latest.find_by!(participant: @user).update_column(:cast_at, Time.current)
    end

    assert_equal "Yesterday on Loomio", build_digest.subject(frequency: "daily", site_name: "Loomio")
  end

  test "subject counts votes for any decision tool type" do
    create_notification(kind: "poll_announced", subject: create_poll(poll_type: "dot_vote"))

    assert_equal "You have 1 vote to cast", digest.subject(frequency: "daily", site_name: "Loomio")
  end

  test "subject combines votes across decision tool types" do
    create_notification(kind: "poll_announced", subject: create_poll)
    create_notification(kind: "poll_announced", subject: create_poll(poll_type: "dot_vote"))

    assert_equal "You have 2 votes to cast", digest.subject(frequency: "daily", site_name: "Loomio")
  end

  test "subject counts distinct people who mentioned or replied to the user" do
    create_notification(kind: "user_mentioned", subject: @discussion.created_topic_item)
    create_notification(kind: "comment_replied_to", subject: @discussion.created_topic_item)
    create_notification(kind: "group_mentioned", subject: @discussion.created_topic_item, actor: @other_actor)

    assert_equal "2 people mentioned you", digest.subject(frequency: "daily", site_name: "Loomio")
  end

  test "subject counts distinct active polls closing soon" do
    poll = create_poll(specified_voters_only: true)
    create_notification(kind: "poll_closing_soon", subject: poll)
    create_notification(kind: "poll_closing_soon", subject: poll)

    assert_equal "1 poll closes soon", digest.subject(frequency: "daily", site_name: "Loomio")

    poll.update_columns(closed_at: Time.current, closing_at: Time.current)

    assert_equal "Yesterday on Loomio", build_digest.subject(frequency: "daily", site_name: "Loomio")
  end

  test "subject orders vote, mention, and closing clauses" do
    create_notification(kind: "poll_announced", subject: create_poll)
    create_notification(kind: "user_mentioned", subject: @discussion.created_topic_item)
    create_notification(kind: "poll_closing_soon", subject: create_poll(specified_voters_only: true))

    assert_equal(
      "You have 1 vote to cast · 1 person mentioned you · 1 poll closes soon",
      digest.subject(frequency: "daily", site_name: "Loomio")
    )
  end

  test "subject falls back when unseen notifications are not actionable" do
    create_notification(kind: "discussion_edited", subject: @discussion.created_topic_item)

    assert_equal "Recently on Loomio", digest.subject(frequency: "other", site_name: "Loomio")
  end

  test "notifications include only unseen delivered occurrences for this user and window" do
    included = create_notification(kind: "discussion_edited", subject: @discussion.created_topic_item)
    create_notification(kind: "user_mentioned", subject: @discussion.created_topic_item, viewed_at: Time.current)
    create_notification(kind: "user_mentioned", subject: @discussion.created_topic_item, created_at: 2.days.ago)
    create_notification(kind: "user_mentioned", subject: @discussion.created_topic_item, recipient: @other_actor)

    assert_equal [included], digest.notifications
  end

  test "notifications are excluded when the user has lost current access" do
    notification = create_notification(kind: "discussion_edited", subject: @discussion.created_topic_item)
    Membership.find_by!(group: @group, user: @user).update!(revoked_at: Time.current)

    assert_not_includes digest.notifications, notification
  end

  private

  def digest
    @digest ||= build_digest
  end

  def build_digest
    DigestQuery.new(user: @user, time_start: @time_start, time_finish: @time_finish)
  end

  def create_poll(**overrides)
    PollService.create(
      params: {
        title: "Digest proposal #{SecureRandom.hex(4)}",
        poll_type: "proposal",
        group_id: @group.id,
        poll_option_names: %w[agree disagree],
        closing_at: 5.days.from_now,
        notify_on_open: false
      }.merge(overrides),
      actor: @actor
    )
  end

  def create_notification(kind:, subject:, actor: @actor, recipient: @user, viewed_at: nil, created_at: Time.current)
    notification = Notification.create!(
      kind: kind,
      subject: subject,
      actor: actor,
      created_at: created_at
    )
    NotificationDelivery.create!(
      notification: notification,
      recipient: recipient,
      channel: "in_app",
      delivered_at: notification.created_at,
      viewed_at: viewed_at
    )
    notification
  end
end

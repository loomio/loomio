require 'test_helper'

class EmailActionsControllerTest < ActionController::TestCase
  inline_jobs "marks the discussion as read at topic_item created_at",
              "marks a comment as read"
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "eauser#{hex}", email: "eauser#{hex}@example.com", username: "eauser#{hex}", email_verified: true)
    @author = User.create!(name: "eaauthor#{hex}", email: "eaauthor#{hex}@example.com", username: "eaauthor#{hex}", email_verified: true)
    @group = Group.new(name: "eagroup#{hex}", group_privacy: 'secret')
    @group.creator = @author
    @group.save!
    @group.add_member!(@user)
    @group.add_member!(@author)
    @membership = Membership.find_by(group: @group, user: @user)

    @discussion = DiscussionService.create(params: { title: "Discussion #{hex}", group_id: @group.id }, actor: @author)
    @topic = @discussion.topic
    @topic_item = @discussion.created_topic_item
    @topic_reader = TopicReader.for(user: @user, topic: @topic)
    ActionMailer::Base.deliveries.clear
  end

  # unsubscribe page rendering
  test "unsubscribe renders with topic reader" do
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    get :unsubscribe, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response :success
    assert_select "input[name=delivery_channel][value=email][checked]"
    assert_select "select[name=volume_email] option[value=loud][selected]"
  end

  test "unsubscribe renders with stance and topic reader" do
    poll = PollService.create(params: {
      title: "Unsub Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      topic_id: @topic.id,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    }, actor: @author)

    get :unsubscribe, params: {
      topic_id: @topic.id,
      unsubscribe_token: @user.unsubscribe_token
    }
    assert_response :success
  end

  # set_volume tests
  test "unsubscribes membership" do
    @membership.set_volume!(email: :loud, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_group_volume, params: {
      group_id: @group.id,
      unsubscribe_token: @user.unsubscribe_token,
      delivery_channel: :push,
      volume_email: :normal,
      volume_push: :normal
    }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'quiet', @membership.volume_email
    assert_equal 'quiet', @topic_reader.volume_email
    assert_equal 'normal', @membership.volume_push
    assert_equal 'normal', @topic_reader.volume_push
  end

  test "quiets membership" do
    @membership.set_volume!(email: :loud, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :quiet }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'quiet', @membership.volume_email
    assert_equal 'quiet', @topic_reader.volume_email
  end

  test "unsubscribes discussion" do
    @membership.set_volume!(email: :normal, push: :quiet)
    @topic_reader.set_volume!(email: :loud, push: :quiet)

    put :set_discussion_volume, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'normal', @membership.volume_email
    assert_equal 'normal', @topic_reader.volume_email
  end

  # mark_discussion_as_read tests
  test "marks the discussion as read at topic_item created_at" do
    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, topic_item_id: @topic_item.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta @topic_item.created_at.to_f, reader.last_read_at.to_f, 1.0
  end

  test "does not error when discussion not found" do
    get :mark_discussion_as_read, params: { discussion_id: :notathing, topic_item_id: @topic_item.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response 200
  end

  test "does not error when discussion has since been discarded" do
    notification = Notification.create!(
      actor: @author,
      kind: "new_discussion",
      subject: @discussion
    )
    delivery = NotificationDelivery.create!(notification: notification, recipient: @user, channel: "in_app", status: "delivered")
    TopicService.discard(topic: @topic, actor: @author)

    get :mark_discussion_as_read, params: {
      discussion_id: @discussion.id,
      topic_item_id: @topic_item.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response 200
    assert_predicate delivery.reload, :viewed?
  end

  test "marks a comment as read" do
    comment_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "hello"), actor: @author)
    reader = TopicReader.for(user: @user, topic: @topic)
    refute reader.has_read?(comment_event.sequence_id)

    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, topic_item_id: comment_event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta Time.now.to_f, reader.last_read_at.to_f, 2.0
    assert reader.has_read?(comment_event.sequence_id)
  end

  # mark_notification_as_read test
  test "marks notification as viewed" do
    notification = Notification.create!(
      actor: @author,
      kind: "new_discussion",
      subject: @discussion
    )
    delivery = NotificationDelivery.create!(notification: notification, recipient: @user, channel: "in_app", status: "delivered")
    get :mark_notification_as_read, params: { id: notification.id, unsubscribe_token: @user.unsubscribe_token }
    assert_predicate delivery.reload, :viewed?
  end

  test "marks only the authenticated recipient's global in-app delivery as viewed" do
    notification = Notification.create!(
      actor: @author,
      kind: "discussion_edited",
      subject: @discussion
    )
    user_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @user,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )
    author_delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: @author,
      channel: "in_app",
      status: "delivered",
      delivered_at: Time.current
    )

    get :mark_notification_as_read, params: {
      id: notification.id,
      unsubscribe_token: @user.unsubscribe_token
    }

    assert_response :success
    assert_not_nil user_delivery.reload.viewed_at
    assert_nil author_delivery.reload.viewed_at
  end

  # mark_summary_email_as_read test
  test "marks content as read" do
    time_start = 1.hour.ago
    comment = Comment.new(parent: @discussion, body: "summary test", created_at: time_start)
    CommentService.create(comment: comment, actor: @author)

    get :mark_summary_email_as_read, params: {
      time_start: time_start.to_i,
      time_finish: 30.minutes.ago.to_i,
      unsubscribe_token: @user.unsubscribe_token,
      format: :gif
    }
    assert_response 200
  end
end

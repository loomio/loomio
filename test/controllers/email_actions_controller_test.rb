require 'test_helper'

class EmailActionsControllerTest < ActionController::TestCase
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
    @event = @discussion.created_event
    @topic_reader = TopicReader.for(user: @user, topic: @topic)
    ActionMailer::Base.deliveries.clear
  end

  # unsubscribe page rendering
  test "unsubscribe renders with topic reader" do
    @topic_reader.set_volume!(:loud)

    get :unsubscribe, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response :success
    assert_select "select[name=value]"
    assert_select "option[value=loud][selected]"
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
    @membership.set_volume!(:loud)
    @topic_reader.set_volume!(:loud)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'normal', @membership.volume
    assert_equal 'normal', @topic_reader.volume
  end

  test "quiets membership" do
    @membership.set_volume!(:loud)
    @topic_reader.set_volume!(:loud)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :quiet }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'quiet', @membership.volume
    assert_equal 'quiet', @topic_reader.volume
  end

  test "unsubscribes discussion" do
    @membership.set_volume!(:normal)
    @topic_reader.set_volume!(:loud)

    put :set_discussion_volume, params: { topic_id: @topic.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @topic_reader.reload

    assert_equal 'normal', @membership.volume
    assert_equal 'normal', @topic_reader.volume
  end

  # mark_discussion_as_read tests
  test "marks the discussion as read at event created_at" do
    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta @event.created_at.to_f, reader.last_read_at.to_f, 1.0
  end

  test "does not error when discussion not found" do
    get :mark_discussion_as_read, params: { discussion_id: :notathing, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response 200
  end

  test "marks a comment as read" do
    comment_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "hello"), actor: @author)
    reader = TopicReader.for(user: @user, topic: @topic)
    refute reader.has_read?(comment_event.sequence_id)

    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: comment_event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = TopicReader.for(user: @user, topic: @topic)
    assert_in_delta Time.now.to_f, reader.last_read_at.to_f, 2.0
    assert reader.has_read?(comment_event.sequence_id)
  end

  # mark_notification_as_read test
  test "marks notification as viewed" do
    notification = Notification.create!(event_id: @event.id, user_id: @user.id, viewed: false)
    get :mark_notification_as_read, params: { id: notification.id, unsubscribe_token: @user.unsubscribe_token }
    assert notification.reload.viewed
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

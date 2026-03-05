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

    @discussion = Discussion.new(title: "Discussion #{hex}", group: @group, author: @author)
    @event = DiscussionService.create(discussion: @discussion, actor: @author)
    @discussion_reader = DiscussionReader.for(discussion: @discussion, user: @user)
    ActionMailer::Base.deliveries.clear
  end

  # unsubscribe page rendering
  test "unsubscribe renders with discussion reader" do
    @discussion_reader = DiscussionReader.for(discussion: @discussion, user: @user)
    @discussion_reader.set_email_volume!(:loud)

    get :unsubscribe, params: { discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response :success
    assert_select "select[name=value]"
    assert_select "option[value=loud][selected]"
  end

  test "unsubscribe renders with stance and discussion reader" do
    poll = Poll.create!(
      title: "Unsub Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      group: @group,
      discussion: @discussion,
      author: @author,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.create_missing_created_event!
    stance = Stance.create!(poll: poll, participant: @user, latest: true)
    stance.set_email_volume!(:normal)

    get :unsubscribe, params: {
      discussion_id: @discussion.id,
      poll_id: poll.id,
      unsubscribe_token: @user.unsubscribe_token
    }
    assert_response :success
  end

  # set_volume tests
  test "unsubscribes membership" do
    @membership.set_email_volume!(:loud)
    @discussion_reader.set_email_volume!(:loud)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @discussion_reader.reload

    assert_equal 'normal', @membership.email_volume
    assert_equal 'normal', @discussion_reader.email_volume
  end

  test "quiets membership" do
    @membership.set_email_volume!(:loud)
    @discussion_reader.set_email_volume!(:loud)

    put :set_group_volume, params: { group_id: @group.id, unsubscribe_token: @user.unsubscribe_token, value: :quiet }
    assert_response 302

    @membership.reload
    @discussion_reader.reload

    assert_equal 'quiet', @membership.email_volume
    assert_equal 'quiet', @discussion_reader.email_volume
  end

  test "unsubscribes discussion" do
    @membership.set_email_volume!(:normal)
    @discussion_reader.set_email_volume!(:loud)

    put :set_discussion_volume, params: { discussion_id: @discussion.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    @discussion_reader.reload

    assert_equal 'normal', @membership.email_volume
    assert_equal 'normal', @discussion_reader.email_volume
  end

  test "unsubscribes stance" do
    @membership.set_email_volume!(:loud)
    poll = Poll.new(
      title: "EA Poll #{SecureRandom.hex(4)}",
      poll_type: 'proposal',
      group: @group,
      author: @author,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    poll.save!
    poll.create_missing_created_event!
    stance = Stance.create!(poll: poll, participant: @user, latest: true)
    stance.set_email_volume!(:loud)

    put :set_poll_volume, params: { stance_id: stance.id, unsubscribe_token: @user.unsubscribe_token, value: :normal }
    assert_response 302

    @membership.reload
    stance.reload

    assert_equal 'loud', @membership.email_volume
    assert_equal 'normal', stance.email_volume
  end

  # mark_discussion_as_read tests
  test "marks the discussion as read at event created_at" do
    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = DiscussionReader.for(discussion: @discussion, user: @user)
    assert_in_delta @event.created_at.to_f, reader.last_read_at.to_f, 1.0
  end

  test "does not error when discussion not found" do
    get :mark_discussion_as_read, params: { discussion_id: :notathing, event_id: @event.id, unsubscribe_token: @user.unsubscribe_token }
    assert_response 200
  end

  test "marks a comment as read" do
    comment_event = CommentService.create(comment: Comment.new(discussion: @discussion, body: "hello"), actor: @author)
    reader = DiscussionReader.for(discussion: @discussion, user: @user)
    refute reader.has_read?(comment_event.sequence_id)

    get :mark_discussion_as_read, params: { discussion_id: @discussion.id, event_id: comment_event.id, unsubscribe_token: @user.unsubscribe_token }
    reader = DiscussionReader.for(discussion: @discussion, user: @user)
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
    comment = Comment.new(discussion: @discussion, body: "summary test", created_at: time_start)
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

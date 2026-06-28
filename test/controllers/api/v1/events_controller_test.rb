require 'test_helper'

class Api::V1::EventsControllerTest < ActionController::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)
    @public_group = groups(:public_group)

    @discussion = discussions(:discussion)
    @public_discussion = discussions(:public_discussion)
  end

  test "pin event pins an event" do
    sign_in @admin
    comment = Comment.new(parent: @discussion, body: "Test comment")
    event = CommentService.create(comment: comment, actor: @user)

    patch :pin, params: { id: event.id }

    assert_response :success
    assert event.reload.pinned
  end

  test "index returns events for a discussion" do
    sign_in @user
    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)
    assert_includes json.keys, 'events'
  end

  test "index serializes without record cache fallbacks" do
    sign_in @user
    CommentService.create(comment: Comment.new(parent: @discussion, body: "Cache test comment"), actor: @user)

    assert_no_record_cache_fallbacks do
      get :index, params: { discussion_id: @discussion.id }, format: :json
    end

    assert_response :success
  end

  test "index filters by discussion" do
    sign_in @user
    comment = Comment.new(parent: @discussion, body: "Test comment")
    event = CommentService.create(comment: comment, actor: @user)

    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
    event_ids = json['events'].map { |v| v['id'] }
    assert_includes event_ids, event.id
  end

  test "comment returns events from a comment" do
    sign_in @user
    comment = Comment.new(parent: @discussion, body: "Test comment")
    event = CommentService.create(comment: comment, actor: @user)

    get :comment, params: { discussion_id: @discussion.id, comment_id: event.eventable.id }
    json = JSON.parse(response.body)
    event_ids = json['events'].map { |v| v['id'] }

    assert_includes event_ids, event.id
  end

  test "comment returns 404 when comment not found" do
    sign_in @user
    get :comment, params: { discussion_id: @discussion.id, comment_id: 999999 }
    assert_response :not_found
  end

  test "index responds to per parameter" do
    sign_in @user
    3.times { CommentService.create(comment: Comment.new(parent: @discussion, body: "Test comment"), actor: @user) }

    get :index, params: { discussion_id: @discussion.id, per: 2 }
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
  end

  test "index responds to from parameter" do
    sign_in @user
    3.times { CommentService.create(comment: Comment.new(parent: @discussion, body: "Test comment"), actor: @user) }

    get :index, params: { discussion_id: @discussion.id, from: 1 }
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
  end

  test "index unread_or_newest returns unread events by discussion key" do
    sign_in @user
    read_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "Read comment"), actor: @admin)
    unread_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "Unread comment"), actor: @admin)
    TopicReader.for(user: @user, topic: @discussion.topic).viewed!([0, read_event.sequence_id])

    get :index, params: { discussion_key: @discussion.key, unread_or_newest: 1, per: 10 }, format: :json
    json = JSON.parse(response.body)
    sequence_ids = json['events'].map { |e| e['sequence_id'] }

    assert_equal [unread_event.sequence_id], sequence_ids
    assert_includes json['topics'].map { |t| t['id'] }, @discussion.topic.id
  end

  test "index unread_or_newest includes root event when unread" do
    sign_in @user
    event = CommentService.create(comment: Comment.new(parent: @discussion, body: "Unread comment"), actor: @admin)

    get :index, params: { discussion_key: @discussion.key, unread_or_newest: 1, per: 10 }, format: :json
    json = JSON.parse(response.body)
    sequence_ids = json['events'].map { |e| e['sequence_id'] }

    assert_equal [0, event.sequence_id], sequence_ids
  end

  test "index unread_or_newest returns newest events when fully read" do
    sign_in @user
    first_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "First comment"), actor: @admin)
    second_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "Second comment"), actor: @admin)
    third_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "Third comment"), actor: @admin)
    TopicReader.for(user: @user, topic: @discussion.topic).viewed!(@discussion.topic.reload.items.pluck(:sequence_id))

    get :index, params: { discussion_key: @discussion.key, unread_or_newest: 1, per: 2 }, format: :json
    json = JSON.parse(response.body)
    sequence_ids = json['events'].map { |e| e['sequence_id'] }

    assert_equal [third_event.sequence_id, second_event.sequence_id], sequence_ids
    refute_includes sequence_ids, first_event.sequence_id
  end

  test "index unread_or_newest returns poll_created event for in-thread poll key" do
    sign_in @user
    poll = PollService.create(params: {
      title: "POLL!",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      group_id: @group.id,
      poll_option_names: %w[agree disagree],
      closing_at: 3.days.from_now
    }, actor: @admin)
    later_event = CommentService.create(comment: Comment.new(parent: @discussion, body: "After poll"), actor: @admin)

    get :index, params: { poll_key: poll.key, unread_or_newest: 1, per: 10 }, format: :json
    json = JSON.parse(response.body)
    sequence_ids = json['events'].map { |e| e['sequence_id'] }

    assert_equal [poll.created_event.sequence_id, later_event.sequence_id], sequence_ids
    assert_includes json['topics'].map { |t| t['id'] }, @discussion.topic.id
    assert_includes json['polls'].map { |p| p['id'] }, poll.id
  end

  test "index handles parent_id parameter with correct filtering" do
    sign_in @user
    parent_comment = Comment.new(parent: @discussion, body: "Parent comment")
    parent_event = CommentService.create(comment: parent_comment, actor: @user)

    child_comment = Comment.new(body: "Child comment", parent: parent_comment)
    child_event = CommentService.create(comment: child_comment, actor: @user)

    unrelated_comment = Comment.new(parent: @discussion, body: "Unrelated comment")
    unrelated_event = CommentService.create(comment: unrelated_comment, actor: @user)

    get :index, params: { discussion_id: @discussion.id, parent_id: parent_event.id }
    json = JSON.parse(response.body)

    event_ids = json['events'].concat(json['parent_events'] || []).map { |e| e['id'] }
    assert_includes event_ids, child_event.id
    assert_includes event_ids, parent_event.id
    refute_includes event_ids, unrelated_event.id
  end

  # -- Logged out access control --

  test "logged out user can see events for public discussion" do
    @public_group.add_member!(@user)
    event = CommentService.create(
      comment: Comment.new(body: "Public comment", parent: @public_discussion),
      actor: @user
    )

    get :index, params: { discussion_id: @public_discussion.id }, format: :json
    assert_response :success

    json = JSON.parse(response.body)
    event_ids = json['events'].map { |e| e['id'] }
    assert_includes event_ids, event.id
  end

  test "logged out user gets 403 for private discussion" do
    get :index, params: { discussion_id: @discussion.id }, format: :json
    assert_response :forbidden
  end

  # -- Cross-discussion isolation --

  test "index does not leak events from other discussions" do
    # Create a second private discussion for cross-isolation test
    other_discussion = discussions(:discussion_in_subgroup)

    sign_in @user
    event1 = CommentService.create(
      comment: Comment.new(body: "In first discussion", parent: @discussion),
      actor: @user
    )
    event2 = CommentService.create(
      comment: Comment.new(body: "In other discussion", parent: other_discussion),
      actor: @user
    )

    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)
    event_ids = json['events'].map { |e| e['id'] }
    assert_includes event_ids, event1.id
    refute_includes event_ids, event2.id
  end

  # -- Outcome comment serialization --

  test "index serializes comment with outcome parent without raising NoMethodError on topic_id" do
    # Regression: Outcome lacked topic_id delegation, so comment.topic_id
    # (which delegates to parent.topic_id) raised NoMethodError for Outcome parents.
    sign_in @user
    @discussion.topic.update!(allow_concurrent_polls: true)

    poll = PollService.create(params: {
      title: "Test proposal",
      poll_type: "proposal",
      topic_id: @discussion.topic_id,
      specified_voters_only: true,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: @user)
    poll.update!(closed_at: 1.day.ago)

    outcome = Outcome.new(poll: poll, author: @user, statement: "We decided")
    OutcomeService.create(outcome: outcome, actor: @user)

    comment = Comment.new(parent: outcome, body: "Comment on outcome", user: @user)
    comment.save!
    comment.create_missing_created_event!

    get :index, params: { discussion_id: @discussion.id }, format: :json
    assert_response :success

    json = JSON.parse(response.body)
    comment_json = json['comments']&.find { |c| c['id'] == comment.id }
    assert comment_json, "Expected comment in response"
    assert_equal poll.topic_id, comment_json['topic_id']
  end

  # -- Discussion reader in response --

  test "responds with discussion and topic with reader" do
    sign_in @user
    # Create an event so the response includes discussion data
    CommentService.create(
      comment: Comment.new(body: "Reader test", parent: @discussion),
      actor: @user
    )
    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)
    assert json['discussions'].present?, "Expected discussions in response"
    assert json['topics'][0]['topic_reader_id'].present?
  end
end

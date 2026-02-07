require 'test_helper'

class Api::V1::EventsControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @public_group = groups(:public_group)

    @group.add_admin!(@user)
    @group.add_member!(@another_user)
    @public_group.add_admin!(@user)

    @discussion = create_discussion(group: @group, author: @user, private: true)
    @public_discussion = create_discussion(group: @public_group, author: @user, private: false)
  end

  test "pin event pins an event" do
    sign_in @user
    comment = Comment.new(discussion: @discussion, body: "Test comment")
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

  test "index filters by discussion" do
    sign_in @user
    comment = Comment.new(discussion: @discussion, body: "Test comment")
    event = CommentService.create(comment: comment, actor: @user)

    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
    event_ids = json['events'].map { |v| v['id'] }
    assert_includes event_ids, event.id
  end

  test "comment returns events from a comment" do
    sign_in @user
    comment = Comment.new(discussion: @discussion, body: "Test comment")
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
    3.times { CommentService.create(comment: Comment.new(discussion: @discussion, body: "Test comment"), actor: @user) }

    get :index, params: { discussion_id: @discussion.id, per: 2 }
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
  end

  test "index responds to from parameter" do
    sign_in @user
    3.times { CommentService.create(comment: Comment.new(discussion: @discussion, body: "Test comment"), actor: @user) }

    get :index, params: { discussion_id: @discussion.id, from: 1 }
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
  end

  test "index handles parent_id parameter with correct filtering" do
    sign_in @user
    parent_comment = Comment.new(discussion: @discussion, body: "Parent comment")
    parent_event = CommentService.create(comment: parent_comment, actor: @user)

    child_comment = Comment.new(discussion: @discussion, body: "Child comment", parent: parent_comment)
    child_event = CommentService.create(comment: child_comment, actor: @user)

    unrelated_comment = Comment.new(discussion: @discussion, body: "Unrelated comment")
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
    event = CommentService.create(
      comment: Comment.new(body: "Public comment", discussion: @public_discussion),
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
    other_discussion = create_discussion(group: @group, author: @user, private: true)

    sign_in @user
    event1 = CommentService.create(
      comment: Comment.new(body: "In first discussion", discussion: @discussion),
      actor: @user
    )
    event2 = CommentService.create(
      comment: Comment.new(body: "In other discussion", discussion: other_discussion),
      actor: @user
    )

    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)
    event_ids = json['events'].map { |e| e['id'] }
    assert_includes event_ids, event1.id
    refute_includes event_ids, event2.id
  end

  # -- Discussion reader in response --

  test "responds with discussion reader" do
    sign_in @user
    # Create an event so the response includes discussion data
    CommentService.create(
      comment: Comment.new(body: "Reader test", discussion: @discussion),
      actor: @user
    )
    get :index, params: { discussion_id: @discussion.id }, format: :json
    json = JSON.parse(response.body)
    assert json['discussions'].present?, "Expected discussions in response"
    assert json['discussions'][0]['discussion_reader_id'].present?
  end
end

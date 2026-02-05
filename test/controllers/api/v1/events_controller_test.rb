require 'test_helper'

class Api::V1::EventsControllerTest < ActionController::TestCase
  setup do
    @user = users(:normal_user)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = create_discussion(group: @group, author: @user, private: false)
    @another_discussion = create_discussion(group: @group, author: @user, private: true)

    @group.add_member!(@user) unless @group.members.include?(@user)
    @group.add_member!(@another_user) unless @group.members.include?(@another_user)
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

  test "index handles parent_id parameter" do
    sign_in @user
    parent_comment = Comment.new(discussion: @discussion, body: "Parent comment")
    parent_event = CommentService.create(comment: parent_comment, actor: @user)

    child_comment = Comment.new(discussion: @discussion, body: "Child comment", parent: parent_comment)
    child_event = CommentService.create(comment: child_comment, actor: @user)

    get :index, params: { discussion_id: @discussion.id, parent_id: parent_event.id }
    json = JSON.parse(response.body)

    assert_includes json.keys, 'events'
  end
end
